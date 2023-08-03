----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.05.2023 13:14:46
-- Design Name: 
-- Module Name: test_wb_eth - Behavioral
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

entity test_wb_eth is
--  Port ( );
end test_wb_eth;

architecture Behavioral of test_wb_eth is

component wb_ethernet is
port (
    clk_i  : in  std_logic;
    rstn_i  : in  std_logic;
    --
    -- Whishbone Interface
    --
    wb_dat_i  : in  std_logic_vector(31 downto 0);
    wb_dat_o  : out std_logic_vector(31 downto 0);
    wb_adr_i  : in  std_logic_vector(31 downto 0);
    wb_cyc_i  : in  std_logic;
    wb_lock_i : in  std_logic;
    wb_sel_i  : in  std_logic;
    wb_we_i   : in  std_logic;
    wb_ack_o  : out std_logic;
    wb_err_o  : out std_logic;
    wb_rty_o  : out std_logic;
    wb_stall_o: out std_logic;
    wb_stb_i  : in  std_logic;
    
    -- Ethernet --
    eth_o_txd : out std_logic_vector(1 downto 0);
    eth_o_txen : out std_logic;
    eth_io_rxd : in std_logic_vector(1 downto 0); -- Change to in
    eth_i_rxderr : out std_logic;
    eth_o_refclk : out std_logic;
    eth_i_refclk : in std_logic;
    eth_i_intn   : in std_logic;
    
    eth_io_crs_dv   : in std_logic;
    eth_io_mdc   : inout std_logic;
    eth_io_mdio   : inout std_logic;
    eth_o_rstn   : out std_logic;
    eth_o_exti : out std_logic_vector(3 downto 0);    
    
    t_eth_io_rxd : out std_logic_vector(1 downto 0)
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
signal eth_o_txd : std_logic_vector(1 downto 0) := "00";
signal eth_i_crs_dv : std_logic := '0';
signal recv_irq : std_logic := '0';
signal eth_o_txen : std_logic := '0';

signal eth_i_rxderr : std_logic := '0';
signal eth_o_refclk : std_logic := '0';
signal eth_i_refclk : std_logic := '0';
signal eth_i_intn : std_logic := '0';

signal eth_io_mdc : std_logic := '0';
signal eth_io_mdio : std_logic := '0';
signal eth_o_rstn : std_logic := '0';
signal eth_o_exti : std_logic_vector(3 downto 0) := "0000";
signal t_eth_io_rxd : std_logic_vector(1 downto 0) := "00";


signal testInput : std_logic_vector(127 downto 0) := x"88776655443322115D55555555555555";

begin

rx : wb_ethernet
port map (
    wb_dat_i => wb_i_dat,
    wb_dat_o => wb_o_dat,
    wb_adr_i => wb_i_addr,
    wb_cyc_i => wb_i_cyc,
    wb_lock_i => wb_i_lock,
    wb_sel_i => wb_i_sel,
    wb_we_i => wb_i_we,
    wb_ack_o => wb_o_ack,
    wb_err_o => wb_o_err,
    wb_stall_o => wb_o_stall,
    wb_stb_i => wb_i_stb,
    
    clk_i => clk_i,
    rstn_i => rst_i,
    eth_io_rxd => eth_i_rxd,
    eth_io_crs_dv => eth_i_crs_dv,
    eth_o_txd => eth_o_txd,
    eth_o_txen => eth_o_txen,
    
    eth_i_rxderr => eth_i_rxderr,
    eth_o_refclk => eth_o_refclk,
    eth_i_refclk => eth_i_refclk,
    eth_i_intn => eth_i_intn,
    eth_io_mdc => eth_io_mdc,
    eth_io_mdio => eth_io_mdio,
    eth_o_rstn => eth_o_rstn,
    eth_o_exti => eth_o_exti,
    t_eth_io_rxd => t_eth_io_rxd    
    
);

eth_i_refclk <= clk_i;

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
    
    for i in 0 to 63 loop
        eth_i_rxd <= testInput(((i + 1) * 2) - 1 downto i * 2);
        wait for 1ps;
        clk_i <= '1';
        wait for 1ps;
        clk_i <= '0';
    end loop;
    
    
    
    
    
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    wait for 1ps;
    
    wait;
    
end process;



end Behavioral;
