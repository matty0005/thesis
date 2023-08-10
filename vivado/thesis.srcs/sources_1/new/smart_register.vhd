----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.08.2023 00:17:28
-- Design Name: 
-- Module Name: smart_register - Behavioral
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

entity smart_register is
    Generic (
        len : integer := 1500 * 4;
        n : integer := 2
    );
    Port ( 
        clk_i : in std_logic;
        reg_in : in std_logic_vector(n - 1 downto 0);
        reg_out : out std_logic_vector(n - 1 downto 0);
        
        in_use : out std_logic;
        available : in std_logic
    );
end smart_register;

architecture Behavioral of smart_register is

signal REG : std_logic_vector(len * n - 1 downto 0);

begin


progress_reg: process(clk_i)
begin
    if rising_edge(clk_i) then
        REG <= REG(len * (n - 1) - 1 downto 0) & reg_in;
    end if;
end process;


process(clk_i)

begin
    if rising_edge(clk_i) then
    
        
        
    
    end if;
    
end process;


end Behavioral;
