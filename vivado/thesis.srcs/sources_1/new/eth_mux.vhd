--------------------------------------------------------------------------------
-- Essentially a multiplexor that handles the ethernet packets coming in and going out. 
-- Packets that have the 
--           
--
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity eth_mux is
    Port ( a : in STD_LOGIC);
end eth_mux;

architecture Behavioral of eth_mux is


component packet_classifier is 
  Port (
    clk:  in std_logic;
    rst:  in std_logic;
    valid: out std_logic; -- Output "forward" is valid when 1. 
    forward: out std_logic;
    
    packet_in: in std_logic_vector(31 downto 0);
    packet_valid: in std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic
   );
end component; 

begin


end Behavioral;
