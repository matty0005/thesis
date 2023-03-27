----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.03.2023 21:37:21
-- Design Name: 
-- Module Name: test_eth_tx_mac - Behavioral
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

entity test_eth_tx_mac is
--  Port ( );
end test_eth_tx_mac;

architecture Behavioral of test_eth_tx_mac is

component eth_tx_mac is
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
        start         : in std_logic := '0';
        dataPresent   : out std_logic := '0';
        dataOut       : out std_logic_vector(7 downto 0);
        status        : out std_logic_vector(1 downto 0);
        statusa        : out std_logic_vector(1 downto 0)  

    );
end component;

signal wb_o_dat, wb_i_dat, wb_i_addr : std_logic_vector(31 downto 0) := (others => '0');
signal wb_i_cyc, wb_i_lock, wb_i_sel,wb_i_we, wb_o_ack,wb_o_err,wb_o_rty, wb_o_stall, wb_i_stb  : std_logic := '0';

signal clk_i, rst_i , start, dataPresent : std_logic := '0';
signal dataOut : std_logic_vector(7 downto 0) := (others => '0');
signal status, statusa : std_logic_vector(1 downto 0) := (others => '0');



-- MAC COMMANDS
constant MAC_CONFIG             : std_logic_vector(31 downto 0) := x"13370000";

-- REGISTERS
constant MAC_DEST_ADDR_HIGH     : std_logic_vector(31 downto 0) := x"13371000";
constant MAC_DEST_ADDR_LOW      : std_logic_vector(31 downto 0) := x"13371001";
constant MAC_LEN                : std_logic_vector(31 downto 0) := x"13371002";


begin

eth : eth_tx_mac 
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
    wb_o_rty => wb_o_rty,
    wb_o_stall => wb_o_stall,
    wb_i_stb => wb_i_stb,
    clk_i => clk_i,
    rst_i => rst_i,
    start => start,
    dataPresent => dataPresent,
    dataOut => dataOut,
    status => status
--    statusa => statusa
);

test : process 
begin

    rst_i <= '1';
    clk_i <= '0';
    
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    
    
    wb_i_stb <= '1';
    wb_i_we <= '1';
    wb_i_addr <= MAC_CONFIG;
    wb_i_dat(0) <= '1';
    
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    

    wb_i_addr <= MAC_DEST_ADDR_HIGH;
    wb_i_dat <= x"deadbeef";
    
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    
    wb_i_addr <= x"13371003";
    wb_i_dat <= x"1337beef";
    
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    
    wait for 1ps;
    clk_i <= '1';
    wait for 1ps;
    clk_i <= '0';
    
    wb_i_addr <= MAC_CONFIG;
    wb_i_dat <= x"00000002";
    
    
    for i in 0 to 50 loop
        wait for 1ps;
        clk_i <= '1';
        wait for 1ps;
        clk_i <= '0';
    end loop;
    
    
    
    
    
    
    
    
  
    wait;
end process;

end Behavioral;
