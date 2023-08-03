--------------------------------------------------------------------------------
-- Packet classifier for FPGA firewall.
-- Uses SPI to configure and monitor
--
-- IO DESCRIPTION
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
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

entity packet_classifier is
  Port (
    clk:  in std_logic;
    valid: out std_logic; -- Output "forward" is valid when 1. 
    forward: out std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic
   );
end packet_classifier;

architecture Behavioral of packet_classifier is

-- CONSTANTS
constant ruleSize : integer := 10;


-- Classifier rules memeory
type ramType is array (ruleSize - 1 downto 0) of std_logic_vector(104 - 1 downto 0);
shared variable RULES_MEMORY : ramType;

type spi_state is (IDLE, STORE);
signal spiState : spi_state := IDLE;

signal spi_mosi_data : std_logic_vector(111 downto 0); -- 13 bytes = 104 bits for data + 8 bits addr  (1byte)


begin

spi_input : process(spi_clk)
begin
    if rising_edge(spi_clk) and spi_csn = '0' then
        spi_mosi_data <= spi_mosi_data(110 downto 0) & spi_mosi;
    end if;
end process;

spi_control : process(spi_clk)

variable ruleAddr : std_logic_vector(7 downto 0) := x"00";
variable spiCounter : integer := 0;

begin
    if rising_edge(spi_clk) and spi_csn = '0' then
        
        spiCounter := spiCounter + 1;
                
        if spiCounter = 104 then
            -- Save the contents in the vector to the memory
            RULES_MEMORY(to_integer(unsigned(spi_mosi_data(111 downto 104)))) := spi_mosi_data(103 downto 0);
            spiCounter := 0;
        end if;
    end if;
end process;


end Behavioral;
