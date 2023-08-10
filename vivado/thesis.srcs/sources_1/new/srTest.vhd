----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2023 20:04:15
-- Design Name: 
-- Module Name: srTest - Behavioral
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

entity srlatch is
    Port ( S : in STD_LOGIC;
           R : in STD_LOGIC;
           Q : buffer STD_LOGIC;
           Qn : buffer STD_LOGIC);
end srlatch;

architecture Behavioural of srlatch is
begin
    Qn <= R nor Q;
    Q <= S nor Qn;
end Behavioural;