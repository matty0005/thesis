----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.08.2023 01:44:37
-- Design Name: 
-- Module Name: test_packet_classifier - Behavioral
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

entity test_packet_classifier is
--  Port ( );
end test_packet_classifier;

architecture Behavioral of test_packet_classifier is

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
    spi_csn: in std_logic;
    
    test_port : out std_logic_vector(119 downto 0)
   );
end component;

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal valid : std_logic := '0';
signal forward : std_logic := '0';
signal packet_valid : std_logic := '0';
signal spi_clk : std_logic := '0';
signal spi_mosi : std_logic := '0';
signal spi_miso : std_logic := '0';
signal spi_csn : std_logic := '0';
signal packet_in : std_logic_vector(31 downto 0) := x"00000000";

signal test_port : std_logic_vector(119 downto 0);


signal RULE_1 : std_logic_vector(119 downto 0) :=    x"00150A00009F0A0000010050005001";

signal TEST_PACKET_1 : std_logic_vector(159 downto 0) := x"0000000A00009F0A000001005000500100000000"; -- Valid
signal TEST_PACKET_2 : std_logic_vector(159 downto 0) := x"0000000A00009F0A100001005000500100000000"; -- Invalid
signal TEST_PACKET_3 : std_logic_vector(159 downto 0) := x"0000000A0000240A000001013000501100000000"; -- Valid
signal TEST_PACKET_4 : std_logic_vector(159 downto 0) := x"0000000300909507750202003000100100000000"; -- Invalid


begin

pc : packet_classifier
port map (
    clk => clk,
    rst => rst,
    valid => valid,
    forward => forward,
    packet_valid => packet_valid,
    spi_clk => spi_clk,
    spi_mosi => spi_mosi,
    spi_miso => spi_miso,
    spi_csn => spi_csn,
    packet_in => packet_in,
    test_port => test_port
);

test : process
begin

    -- first set RAM
    for i in 0 to 119 loop
        spi_mosi <= RULE_1(119-i);
        wait for 1ps;
        spi_clk <= '1';
        wait for 1ps;
        spi_clk <= '0';
    end loop; 
    wait for 1ps;
        spi_clk <= '1';
        wait for 1ps;
        spi_clk <= '0';
    
    
    -- Test packet 1
    packet_valid <= '1';
    for i in 0 to 13 loop
        -- packet_in <= TEST_PACKET_3(103 - i * 8 downto 72 - i * 8);
        packet_in <= TEST_PACKET_1(159 - i * 8 downto 128 - i * 8);
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        clk <= '0';
    end loop; 
    packet_valid <= '0';
 
    wait for 1ps;
        clk <= '1';
        wait for 1ps;
        clk <= '0';
        
     -- Test packet 2
    packet_valid <= '1';
    for i in 0 to 13 loop
        -- packet_in <= TEST_PACKET_3(103 - i * 8 downto 72 - i * 8);
        packet_in <= TEST_PACKET_2(159 - i * 8 downto 128 - i * 8);
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        clk <= '0';
    end loop; 
    packet_valid <= '0';
    
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    clk <= '0';
    
    
        -- Test packet 3
    packet_valid <= '1';
    for i in 0 to 13 loop
        -- packet_in <= TEST_PACKET_3(103 - i * 8 downto 72 - i * 8);
        packet_in <= TEST_PACKET_3(159 - i * 8 downto 128 - i * 8);
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        clk <= '0';
    end loop; 
    packet_valid <= '0';
    
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    clk <= '0';
    
        -- Test packet 4
    packet_valid <= '1';
    for i in 0 to 13 loop
        -- packet_in <= TEST_PACKET_3(103 - i * 8 downto 72 - i * 8);
        packet_in <= TEST_PACKET_4(159 - i * 8 downto 128 - i * 8);
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        clk <= '0';
    end loop; 
    packet_valid <= '0';
    
    
    
    
    
    
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    clk <= '0';
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    clk <= '0';
    

    
    

    
    wait;    
end process;


end Behavioral;
