----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.05.2023 01:02:32
-- Design Name: 
-- Module Name: test_eth_rx - Behavioral
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

entity test_eth_rx is
--  Port ( );
end test_eth_rx;

architecture Behavioral of test_eth_rx is

component eth_rx_mac is
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
        eth_i_rxd : in std_logic_vector(1 downto 0);
        eth_i_crs_dv : in std_logic;
        recv_irq : out std_logic
    
    );
end component;

signal wb_i_dat : std_logic_vector(31 downto 0) := x"00000000";
signal wb_o_dat : std_logic_vector(31 downto 0) := x"00000000";
signal wb_i_addr : std_logic_vector(31 downto 0) := x"00000000";
signal wb_i_cyc : std_logic := '0';
signal wb_i_lock : std_logic := '0';
signal wb_i_sel : std_logic := '0';
signal wb_i_we : std_logic := '0';
signal wb_o_ack : std_logic := '0';
signal wb_o_err : std_logic := '0';
signal wb_o_stall : std_logic := '0';
signal wb_i_stb : std_logic := '0';

signal clk_i : std_logic := '0';
signal rst_i : std_logic := '1';
signal eth_i_rxd : std_logic_vector(1 downto 0) := "00";
signal eth_i_crs_dv : std_logic := '0';
signal recv_irq : std_logic := '0';


signal testInput : std_logic_vector(191 downto 0) := x"ffeeddccbbaa009988776655443322115D55555555555555";


begin

rx : eth_rx_mac
port map (
    wb_i_dat => wb_i_dat,
    wb_o_dat => wb_o_dat,
    wb_i_addr => wb_i_addr,
    wb_i_cyc => wb_i_cyc,
    wb_i_lock => wb_i_lock,
    wb_i_sel => wb_i_sel,
    wb_i_we => wb_i_we,
    wb_o_ack => wb_o_ack,
    wb_o_err => wb_o_err,
    wb_o_stall => wb_o_stall,
    wb_i_stb => wb_i_stb,
    
    clk_i => clk_i,
    rst_i => rst_i,
    eth_i_rxd => eth_i_rxd,
    eth_i_crs_dv => eth_i_crs_dv,
    recv_irq => recv_irq
);

test: process
begin
    
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    
    eth_i_crs_dv <= '1';
    
    for i in 0 to 95 loop
        eth_i_rxd <= testInput(((i + 1) * 2) - 1 downto i * 2);
        wait for 1ps;
        clk_i <= '1';
        wait for 1ps;
        clk_i <= '0';
    end loop;
    
    eth_i_crs_dv <= '0';
    
    wb_i_stb <= '1';
    wb_i_addr <= x"13380000";
    wb_i_we <= '1';
--    wb_i_dat <= x"00000001";
--    clk_i <= '1';
--    wait for 1ps;
--    clk_i <= '0';
--    wait for 1ps;

    wb_i_addr <= x"13380004";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"13380008";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"1338000C";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    wb_i_addr <= x"13380010";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"13380014";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    
    wb_i_addr <= x"13380018";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"1338001C";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"13380020";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"13380024";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    wb_i_addr <= x"13380028";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wb_i_addr <= x"1338002C";
    wb_i_we <= '0';
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    
    
    
    
    
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    wb_i_dat <= x"00000000";
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    eth_i_crs_dv <= '1';
    
    for i in 0 to 63 loop
        eth_i_rxd <= testInput(((i + 1) * 2) - 1 downto i * 2);
        wait for 1ps;
        clk_i <= '1';
        wait for 1ps;
        clk_i <= '0';
    end loop;
    
    eth_i_crs_dv <= '0';
    
    
    
    
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wait;
    
end process;


end Behavioral;
