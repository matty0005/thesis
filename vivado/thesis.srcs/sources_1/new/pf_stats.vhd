----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.09.2023 15:47:15
-- Design Name: 
-- Module Name: pf_stats - Behavioral
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

entity pf_stats is
    Port ( valid : in STD_LOGIC_VECTOR (63 downto 0);
           blocked : in STD_LOGIC_VECTOR (63 downto 0);
           total : in STD_LOGIC_VECTOR (63 downto 0);
           rst : in std_logic;
           counter_reset: out std_logic;
           spi_mosi : in STD_LOGIC;
           spi_miso : out STD_LOGIC;
           spi_clk : in STD_LOGIC;
           spi_csn : in STD_LOGIC);
end pf_stats;

architecture Behavioral of pf_stats is

signal spi_mosi_data : std_logic_vector(7 downto 0) := x"00";
signal spi_miso_data : std_logic_vector(63 downto 0) := x"11EE66AA22CC4488";

signal spiCounter : integer := 0;

begin

spi_miso <= spi_miso_data(spiCounter) when spi_csn = '0' else '0';

tx: process(spi_clk, rst, spi_csn) is
begin
    if rst = '1' or spi_csn = '1' then
        spiCounter <= 0;
    elsif falling_edge(spi_clk) and spi_csn = '0' then
       
        if spiCounter = 63 then
            spiCounter <= 0;
        else 
            spiCounter <= spiCounter + 1;
        end if;
    end if;
end process;

rx: process(spi_clk, rst) is
variable spiCounter : integer := 0;
begin
    counter_reset <= '0'; -- Always reset - max 1 clk cycle
    if rst = '1' then
        spiCounter := 0;
    elsif rising_edge(spi_clk) and spi_csn = '0' then
        counter_reset <= '0';
        spi_mosi_data <= spi_mosi_data(6 downto 0) & spi_mosi;
        
        case spi_mosi_data(6 downto 0) & spi_mosi is 
            when x"55" => -- Valid
                spi_miso_data <= valid; --x"11EE66AA22CC4488"; -- 1122334455667788
            when x"66" => -- Blocked
                spi_miso_data <= blocked; --x"880077BB33DD5599"; -- 99aabbccddee0011
            when x"77" => -- Blocked
                spi_miso_data <= total;
            when x"22" => -- Reset
                counter_reset <= '1';
            when others => -- Undefined
               null; --99aabbccddee0011   

        end case;
        
    end if;
end process;



end Behavioral;
