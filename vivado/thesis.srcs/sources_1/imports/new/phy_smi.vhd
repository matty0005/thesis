----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2023 01:20:03
-- Design Name: 
-- Module Name: phy_smi - Behavioral
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

entity phy_smi is
    Generic (
        smi_address    : std_logic_vector(4 downto 0);
        device_address  : std_logic_vector(4 downto 0)
   );
   Port (
        rst		: in std_logic;

        clk_i    : in std_logic; -- Must be 1Mhz.
        clk_o    : out std_logic := '0';
        smi_io_dat     : inout std_logic;

        -- 00: Address
            -- 10: Read-Inc
        -- 11: Read
            -- 01: Write
        opcode  	: in std_logic_vector(1 downto 0);
    
        smi_o_dat       : out std_logic_vector(15 downto 0);
        smi_i_dat      : in std_logic_vector(15 downto 0);
        smi_i_start : in std_logic;
    
        smi_o_busy  : out std_logic;
        smi_o_err          : out std_logic_vector(2 downto 0)
   );
end phy_smi;

architecture Behavioral of phy_smi is

begin


end Behavioral;
