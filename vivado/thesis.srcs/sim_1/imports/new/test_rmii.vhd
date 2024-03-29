----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2023 16:48:44
-- Design Name: 
-- Module Name: test_rmii - Behavioral
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

entity test_rmii is
--  Port ( );
end test_rmii;

architecture Behavioral of test_rmii is

component rmii is
  Port (

    rmii_i_rst      : in std_logic;
    -- From ethernet MAC
    rmii_i_tx_ready : in std_logic;
    rmii_i_tx_dat   : in std_logic_vector(7 downto 0);
--    rmii_i_tx_clk   : in std_logic;
    rmii_i_tx_start   : in std_logic;
    
    
    -- RMII interface itself
    rmii_o_txd      : out std_logic_vector(1 downto 0) := "00";
    rmii_o_txen     : out std_logic; 
    clk_i_write : in STD_LOGIC;
    clk_i_read : in STD_LOGIC;
    
    eth_i_rxderr    : out std_logic

    
  );
end component;
  
  
signal rst : std_logic := '1';
signal tx_ready : std_logic := '0';
signal tx_dat : std_logic_vector(7 downto 0) := x"00";
signal test : std_logic_vector(7 downto 0) := x"00";
signal tx_clk : std_logic := '0';
signal rmii_o_txd : std_logic_vector(1 downto 0) := "00";
signal rmii_o_txen : std_logic := '0';
signal rmii_i_clk : std_logic := '0';
signal rmii_i_start : std_logic := '0';

begin

rmii_map : rmii 
port map (
    rmii_i_rst => rst,
    rmii_i_tx_ready => tx_ready,
    rmii_i_tx_dat => tx_dat,
    clk_i_write => tx_clk,
    
    rmii_o_txd => rmii_o_txd,
    rmii_o_txen => rmii_o_txen,
    clk_i_read => rmii_i_clk,
    rmii_i_tx_start => rmii_i_start
);


test_rmii : process 
begin
    tx_ready <= '1';
    tx_dat <= x"BE";
    wait for 1ps;
    tx_clk <= '1';
    wait for 1ps;
    tx_ready <= '0';
    tx_clk <= '0';
    wait for 1ps;
    
    tx_dat <= x"EF";
    tx_ready <= '1';
    wait for 1ps;
    tx_clk <= '1';
    wait for 1ps;
    tx_clk <= '0';
    tx_ready <= '0';
    wait for 1ps;
    
    tx_dat <= x"CA";
    tx_ready <= '1';
    wait for 1ps;
    tx_clk <= '1';
    wait for 1ps;
    tx_clk <= '0';
    tx_ready <= '0';
    wait for 1ps;
    
    tx_dat <= x"FE";
    tx_ready <= '1';
    wait for 1ps;
    tx_clk <= '1';
    wait for 1ps;
    tx_clk <= '0';
    tx_ready <= '0';
    wait for 1ps;
    
--     wait for 1ps;
--    tx_clk <= '1';
--    wait for 1ps;
--    tx_clk <= '0';
--    tx_ready <= '0';
--    wait for 1ps;
    
    for i in 20 downto 0 loop
    
        rmii_i_clk <= '1';
        wait for 1ps;
        rmii_i_clk <= '0';
        wait for 1ps;
    end loop;
    
    wait;
    
    
    
end process;


end Behavioral;
