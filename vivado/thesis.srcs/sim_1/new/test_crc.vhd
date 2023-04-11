----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.02.2023 00:33:19
-- Design Name: 
-- Module Name: testcrc - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity testcrc is
--  Port ( );
end testcrc;

architecture Behavioral of testcrc is

signal clk :std_logic := '0';
signal rst :std_logic := '0';
signal crc_en :std_logic := '0';
signal crcIn : std_logic_vector(31 downto 0) := (others => '1');
signal crcOut : std_logic_vector(31 downto 0) := (others => '0');
signal data : std_logic_vector(7 downto 0);


signal datatocrc : std_logic_vector(479 downto 0) := x"000000000000000000000000000000000000000000000000000000000000ccbbaa998877665544332211fecaefbe0f00bebaefbeadde6655ddccbbaa";


component crc32
port (
    clk: in std_logic;
    data: in std_logic_vector(1 downto 0);
    crcOut: out std_logic_vector(31 downto 0)
);
end component;


component crc
port (
    CLOCK               :   in  std_logic;
    RESET               :   in  std_logic;
    DATA                :   in  std_logic_vector(7 downto 0);
    LOAD_INIT           :   in  std_logic;
    CALC                :   in  std_logic;
    D_VALID             :   in  std_logic;
    CRC                 :   out std_logic_vector(7 downto 0);
    CRC_REG             :   out std_logic_vector(31 downto 0);
    CRC_VALID           :   out std_logic
);
end component;


signal load_init : std_logic := '0';
signal calc : std_logic:= '0';
signal d_valid : std_logic:= '0';
signal crc_valid : std_logic:= '0';

signal crc8 : std_logic_vector(7 downto 0) := x"00";

begin


cres : crc
port map (
    clock => clk,
    reset => rst,
    data => data,
    load_init => load_init,
    calc => calc,
    d_valid => d_valid,
    crc_reg => crcOut,
    crc => crc8,
    crc_valid => crc_valid

);



process is 

begin
    data <= "00000000";
    rst <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    rst <= '0';
    clk <= '0';
     
    
    wait for 5ps;
    load_init <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    load_init <= '0';
    clk <= '0';
    wait for 5ps;
    
    
    
    
    
    
    
    calc <= '1';
    data <= x"aa";
    wait for 2ps;
    d_valid <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    d_valid <= '0';
    clk <= '0';
    wait for 4ps;
    
    calc <= '1';
    data <= x"bb";
    wait for 2ps;
    d_valid <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    d_valid <= '0';
    clk <= '0';
    wait for 4ps;
    
    
    d_valid <= '1';
    calc <= '0';
    
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    clk <= '0';
    wait for 4ps;
    
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    clk <= '0';
    wait for 4ps;
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    clk <= '0';
    wait for 4ps;
    
    wait for 1ps;
    clk <= '1';
    wait for 2ps;
    clk <= '0';
    wait for 4ps;
    
     
     
     
     
     
     
    
     
    calc <= '1';
    wait for 5ps;
    for i in 0 to 59 loop
        data <= datatocrc(i * 8 + 7 downto i * 8);
        wait for 2ps;
        d_valid <= '1';
        wait for 1ps;
        clk <= '1';
        wait for 2ps;
        d_valid <= '0';
        clk <= '0';
        wait for 4ps;
        
        
    end loop;
    
    wait for 5ps;
    load_init <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    load_init <= '0';
    clk <= '0';
    wait for 5ps;
    
    
    
    wait;
    
end process;


end Behavioral;
