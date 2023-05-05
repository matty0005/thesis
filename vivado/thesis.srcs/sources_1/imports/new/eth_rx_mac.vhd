----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.04.2023 11:37:28
-- Design Name: 
-- Module Name: eth_rx_mac - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity eth_rx_mac is
   Port ( 
    -- WISHBONE b4 classic
        wb_i_dat        : in  std_logic_vector(31 downto 0);
        wb_o_dat        : out std_logic_vector(31 downto 0);
        wb_i_addr       : in  std_logic_vector(31 downto 0);
        wb_i_cyc        : in  std_logic;
        wb_i_lock       : in  std_logic;
        wb_i_sel        : in  std_logic;
        wb_i_we         : in  std_logic;
        wb_o_ack        : out std_logic;
        wb_o_err        : out std_logic;
        wb_o_rty        : out std_logic;
        wb_o_stall      : out std_logic;
        wb_i_stb        : in  std_logic;
    
        -- Interface
        clk_i  : in  std_logic;
        rst_i  : in  std_logic := '0';
        start         : in std_logic := '0';

        eth_i_rxd : in std_logic_vector(1 downto 0);
        eth_i_crs_dv : in std_logic;
        recv_irq : out std_logic
    
    );
end eth_rx_mac;

architecture Behavioral of eth_rx_mac is

type state is (IDLE, DATA);
signal currentState : state := IDLE;

signal pipe : std_logic_vector((8 * 8) - 1 downto 0) := (others => '0');
constant preambleFormat : std_logic_vector(63 downto 0) := x"55555555555555D5";

constant READ_CONFIG : std_logic_vector(31 downto 0) := x"13380000";
constant MAC_DEST_ADDR_HIGH : std_logic_vector(31 downto 0) := x"13380004";
constant MAC_DEST_ADDR_LOW : std_logic_vector(31 downto 0) := x"13380008";
constant MAC_SRC_ADDR_HIGH : std_logic_vector(31 downto 0) := x"1338000C";
constant MAC_SRC_ADDR_LOW : std_logic_vector(31 downto 0) := x"13380010";
constant MAC_LEN : std_logic_vector(31 downto 0) := x"13380014";
constant MAC_DAT_SIZE : std_logic_vector(31 downto 0) := x"13380018";


-- FRAME BUFFER
type ramType is array (1526 - 1 downto 0) of std_logic_vector(8 - 1 downto 0);
shared variable FRAME_BUFFER : ramType;

signal payloadLen : integer range 0 to 1600 := 0;

signal irqAck : std_logic := '0';

begin

RECIEVE_PROCESS: process(clk_i) 
variable counter : integer range 0 to 1500 * 4 := 0; -- get 2 bits at a time. 
begin
    if rising_edge(clk_i) then
    
        -- Only recieve data on input. Need to sus out end case
        if irqAck = '1' then
            recv_irq <= '0';
        end if;
        
        if eth_i_crs_dv = '1' then
            case currentState is 
                when IDLE =>
                    -- Wait for preamble to clear.
                    if pipe = preambleFormat then
                        currentState <= DATA;
                        recv_irq <= '1';
                        payloadLen <= 0;
                    end if;
                    
                when DATA => 
                    
                    -- Data here. 
                    if counter mod 8 = 0 and counter /= 0 then -- every 8 times and not including the first. 
                        FRAME_BUFFER(payloadLen) := pipe(7 downto 0);
                        
                        payloadLen <= payloadLen + 1;
                    end if;
                    
                    counter := counter + 1;
                    
            end case;
            -- Shift register
            pipe <= pipe(pipe'length - 3 downto 0) & eth_i_rxd;
        else
            counter := 0;
            currentState <= IDLE;
            recv_irq <= '0';
        end if;
    end if;
end process;

WB_MAIN_RX : process(clk_i)
variable virtAddr : integer := 0;
begin
    if rising_edge(clk_i) then
--        wb_o_dat <= pipe(31 downto 0);
        -- Only handle data when strobe

        if wb_i_stb = '1' then 
            wb_o_ack <= '1';
            
            -- Ensure write enable is reset to read.
            if wb_i_we = '0' then
                
                case wb_i_addr is 
                    when MAC_DEST_ADDR_HIGH =>
                    
                        wb_o_dat <= FRAME_BUFFER(0) & FRAME_BUFFER(1) & FRAME_BUFFER(2) & FRAME_BUFFER(3);
                    
                    when MAC_DEST_ADDR_LOW =>
                        wb_o_dat <= FRAME_BUFFER(4) & FRAME_BUFFER(5) & x"0000";
                        
                    when MAC_SRC_ADDR_HIGH =>
                    
                        wb_o_dat <= FRAME_BUFFER(6) & FRAME_BUFFER(7) & FRAME_BUFFER(8) & FRAME_BUFFER(9);
                    
                    when MAC_SRC_ADDR_LOW =>
                        wb_o_dat <= FRAME_BUFFER(10) & FRAME_BUFFER(11) & x"0000";

                    when MAC_LEN =>
                    
                        wb_o_dat <= x"0000" & FRAME_BUFFER(12) & FRAME_BUFFER(13);
                        
                    when MAC_DAT_SIZE => 
                        wb_o_dat <= std_logic_vector(to_unsigned(payloadLen, 32));
                        
                    when others =>
                    
                        if wb_i_addr >= x"1338101C" and wb_i_addr <= x"133815F8" then
                            
                            -- 322375680 = 0x13371000.
                            virtAddr := to_integer((unsigned(wb_i_addr(15 downto 0)) - 4124));
                            
                            wb_o_dat <= FRAME_BUFFER(14 + virtAddr) &  FRAME_BUFFER(15 + virtAddr) & FRAME_BUFFER(16 + virtAddr) & FRAME_BUFFER(17 + virtAddr);
                            
                        end if;
                        
                end case;

            elsif wb_i_we = '1' then
                case wb_i_addr is 
                
                    -- Configure hardware.
                    when READ_CONFIG =>
                        
                        -- Initialise the buffers.
                        if wb_i_dat(0) = '1' then
                      
                            irqAck <= '1';
                        elsif wb_i_dat(0) = '0' then
                            irqAck <= '0';
                        end if;
                        
                        
                     when others => NULL; -- Dont do anything - we only care about strict values
                     
                       
                end case;
    
            end if;
        else
            wb_o_ack <= '0';
        end if;
    
    end if;
end process;




end Behavioral;
