----------------------------------------------------------------------------------
-- Engineer: Matthew Gilpin
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

        eth_i_rxd : in std_logic_vector(1 downto 0);
        eth_i_crs_dv : in std_logic;
        recv_irq : out std_logic
    
    );
end eth_rx_mac;

architecture Behavioral of eth_rx_mac is

type state is (IDLE, DATA);
signal currentState : state := IDLE;

signal pipe : std_logic_vector(31 downto 0) := (others => '0');
--constant preambleFormat : std_logic_vector(63 downto 0) := x"55555555555555D5";
constant preambleFormat : std_logic_vector(31 downto 0) := x"55555555";
constant preambleFormatIV : std_logic_vector(31 downto 0) := x"AAAAAAAA";
--constant preambleFormatIV : std_logic_vector(63 downto 0) := x"AAAAAAAAAAAAAAAB";

constant READ_CONFIG : std_logic_vector(15 downto 0) := x"0000";
constant MAC_DEST_ADDR_HIGH : std_logic_vector(15 downto 0) := x"0004";
constant MAC_DEST_ADDR_LOW : std_logic_vector(15 downto 0) := x"0008";
constant MAC_SRC_ADDR_HIGH : std_logic_vector(15 downto 0) := x"000C";
constant MAC_SRC_ADDR_LOW : std_logic_vector(15 downto 0) := x"0010";
constant MAC_LEN : std_logic_vector(15 downto 0) := x"0014";
constant MAC_DAT_SIZE : std_logic_vector(15 downto 0) := x"0004";


-- FRAME BUFFER
type ramType is array (1526 - 1 downto 0) of std_logic_vector(8 - 1 downto 0);
shared variable FRAME_BUFFER : ramType;

signal payloadLen : integer range 0 to 1600 := 0;

signal irqAck : std_logic := '0';

signal q : std_logic := '0';
signal r : std_logic := '0';
signal s : std_logic := '0';
signal notq : std_logic := '0';
signal trig : std_logic := '0';

begin

RECIEVE_PROCESS: process(clk_i) 
variable counter : integer range 0 to 1500 * 4 := 0; -- get 2 bits at a time. 
begin
    if rst_i = '0' then
        currentState <= IDLE;
        counter := 0;
        trig <= '0';
    elsif rising_edge(clk_i) then
    
--        -- Only recieve data on input. Need to sus out end case
--        if irqAck = '1' then
--            recv_irq <= '0';
--        end if;
        
        if eth_i_crs_dv = '1' then
            -- Shift register
            pipe <= pipe(pipe'length - 3 downto 0) & eth_i_rxd;
            
            case currentState is 
                when IDLE =>
                    if eth_i_rxd /= "00" then
                        currentState <= DATA;
                        payloadLen <= 0;
                        counter := 1;
                        trig <= '1';
                        recv_irq <= '1';
                    end if;
                    
                when DATA => 
                    
                    -- Data here. 
                    if counter mod 4 = 0 and counter /= 0 then -- every 8 times and not including the first. 
                        FRAME_BUFFER(payloadLen) := pipe(1 downto 0) & pipe(3 downto 2) & pipe(5 downto 4) & pipe(7 downto 6);
                        
                        payloadLen <= payloadLen + 1;
                    end if;
                    
                    if q = '1' then
                        trig <= '0';
                    end if;
                    recv_irq <= '0';
                    counter := counter + 1;
                    
            end case;
            
        else
            counter := 0;
            currentState <= IDLE;
        end if;
    end if;
end process;


--recv_irq <= q;

--IRQ: process(clk_i, rst_i)
--begin
--    if rst_i = '0' then
--        q <= '0';
--    elsif rising_edge(clk_i) then
    

--        if trig = '1' and irqAck = '0' then 
--            q <= '1';
--        elsif trig = '0' and irqAck = '1' then
--            q <= '0'; 
--        elsif trig = '0' and irqAck = '0' then
--            q <= q;
--        end if;

--    end if;
--end process;


WB_MAIN_RX : process(clk_i)
variable virtAddr : integer := 0;
begin
    if rst_i = '0' then
        wb_o_ack <= '0';
    elsif rising_edge(clk_i) then
        -- Only handle data when strobe
        if wb_i_stb = '1' and wb_i_addr(31 downto 16) = x"1338" then 
            wb_o_ack <= '1';
            
            -- Ensure write enable is reset to read.
            if wb_i_we = '0' then
                if wb_i_addr(15 downto 0) = MAC_DAT_SIZE then 
                    wb_o_dat <= std_logic_vector(to_unsigned(payloadLen, 32));
                elsif wb_i_addr(15 downto 0) >= x"0008" and wb_i_addr(15 downto 0) <= x"05F8" then
                            
                    -- 322375680 = 0x13371000.
                    virtAddr := to_integer((unsigned(wb_i_addr(15 downto 0)) - 8));
                    wb_o_dat <= FRAME_BUFFER(virtAddr) &  FRAME_BUFFER(1 + virtAddr) & FRAME_BUFFER(2 + virtAddr) & FRAME_BUFFER(3 + virtAddr);
                end if;
            elsif wb_i_we = '1' then
                if wb_i_addr(15 downto 0) = READ_CONFIG then
                    -- Initialise the buffers.
                    irqAck <= wb_i_dat(0);
                end if;
            end if;
        else
            wb_o_ack <= '0';
        end if;
    end if;
end process;

end Behavioral;
