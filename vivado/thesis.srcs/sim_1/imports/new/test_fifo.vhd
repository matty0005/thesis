----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2023 23:29:52
-- Design Name: 
-- Module Name: test_fifo - Behavioral
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

entity test_fifo is
--  Port ( );
end test_fifo;

architecture Behavioral of test_fifo is

component fifo is
    Generic (
        w : integer := 8; -- width
        d : integer := 64 -- depth
    );
    Port (  
        clk_i_read        :   in  std_logic;
        clk_i_write       :   in  std_logic;
        i_rst             :   in  std_logic;
        i_read            :   in  std_logic;
        i_write           :   in  std_logic;
        o_full            :   out  std_logic;
        o_empty           :   out  std_logic;
        i_datIn           :   in  std_logic_vector(w - 1 downto 0);
        o_datOut          :   out  std_logic_vector(w - 1 downto 0) := (others => '0')
     );
end component;
         
         
signal rst : std_logic := '0';

signal tx_fifo_read : std_logic := '0';
signal tx_fifo_write : std_logic := '0';
signal tx_fifo_full : std_logic := '0';
signal tx_fifo_empty : std_logic := '0';
signal tx_fifo_input : std_logic_vector(7 downto 0) := x"00";
signal tx_fifo_output : std_logic_vector(7 downto 0) := x"00";
signal tx_fifo_read_clk : std_logic := '0';

signal readclk : std_logic := '0';
signal writeclk : std_logic := '0';


-- Output shift register
signal tx_sr : std_logic_vector(7 downto 0) := x"00";

begin

    tx_fifo : fifo
    generic map (
        w => 8,
        d => 8
    )
    port map (
        clk_i_read      => readclk,
        clk_i_write     => writeclk,
        i_rst           => rst,
        i_read          => tx_fifo_read,
        i_write         => tx_fifo_write,
        o_full          => tx_fifo_full,
        o_empty         => tx_fifo_empty,
        i_datIn         => tx_fifo_input,
        o_datOut        => tx_fifo_output
    );

test : process
begin

    -- Write
    tx_fifo_write <= '1';
    tx_fifo_input <= x"BE";
    wait for 1ps;
    writeclk <= '1';
    wait for 1ps;
    tx_fifo_write <= '0';
    writeclk <= '0';
    wait for 1ps;
    
    tx_fifo_input <= x"EF";
    tx_fifo_write <= '1';
    wait for 1ps;
    writeclk <= '1';
    wait for 1ps;
    writeclk <= '0';
    tx_fifo_write <= '0';
    wait for 1ps;
    
    --Clocks
    
    wait for 1ps;
    writeclk <= '1';
    readclk <= '1';
    wait for 1ps;
    writeclk <= '0';
    readclk <= '0';
    wait for 1ps;
    
    
    
    -- Read
    
    wait for 1ps;
    tx_fifo_read <= '1';
    readclk <= '1';
    wait for 1ps;
    tx_fifo_read <= '0';
    readclk <= '0';
    wait for 1ps;
    
    
       wait for 1ps;
    tx_fifo_read <= '1';
    readclk <= '1';
    wait for 1ps;
    tx_fifo_read <= '0';
    readclk <= '0';
    wait for 1ps;
    
    
    

    wait;
end process;


end Behavioral;
