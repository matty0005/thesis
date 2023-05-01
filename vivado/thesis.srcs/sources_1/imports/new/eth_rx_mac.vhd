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
        dataPresent   : out std_logic := '0';
        dataOut       : out std_logic_vector(7 downto 0);
        status        : out std_logic_vector(1 downto 0);
--        statusa        : out std_logic_vector(1 downto 0);  
--        statusb        : out std_logic_vector(7 downto 0)
        eth_i_rxd : in std_logic_vector(1 downto 0);
        eth_i_crs_dv : in std_logic
    
    );
end eth_rx_mac;

architecture Behavioral of eth_rx_mac is

type state is (IDLE, DATA);
signal currentState : state := IDLE;

signal pipe : std_logic_vector((8 * 8) - 1 downto 0) := (others => '0');
constant preambleFormat : std_logic_vector(63 downto 0) := x"aaaaaaaaaaaaaaab";

-- FRAME BUFFER
type ramType is array (1526 - 1 downto 0) of std_logic_vector(8 - 1 downto 0);
shared variable FRAME_BUFFER : ramType;

begin

RECIEVE_PROCESS: process(clk_i) 
variable counter : integer range 0 to 1500 * 4 := 0; -- get 2 bits at a time. 
begin
    if rising_edge(clk_i) then
    
        -- Only recieve data on input. Need to sus out end case
        if eth_i_crs_dv = '1' then
            case currentState is 
                when IDLE =>
                    -- Wait for preamble to clear.
                    if pipe = preambleFormat then
                        currentState <= DATA;
                    end if;
                    
                when DATA => 
                    
                    -- Data here. 
                    if counter mod 8 = 0 and counter /= 0 then -- every 8 times and not including the first. 
                        FRAME_BUFFER(counter) := pipe(7 downto 0);
                    end if;
                    
                    counter := counter + 1;
                    
            end case;
        else
            counter := 0;
            currentState <= IDLE;
        end if;
        
        -- Shift register
        pipe <= pipe(pipe'length - 2 downto 2) & eth_i_rxd;
    
    end if;
end process;

end Behavioral;
