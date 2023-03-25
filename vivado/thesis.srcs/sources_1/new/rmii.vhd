--------------------------------------------------------------------------------
-- RMII interface between 8bits to 2bit RMII 
-- Uses FIFOs
--
-- IO DESCRIPTION
--           
--
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rmii is
  Port (
    rmii_i_rst      : in std_logic;
    -- From ethernet MAC
    rmii_i_tx_ready : in std_logic;
    rmii_i_tx_dat   : in std_logic_vector(7 downto 0);
    rmii_i_tx_clk   : in std_logic;
    
    
    -- RMII interface itself
    rmii_o_txd      : out std_logic_vector(1 downto 0);
    rmii_o_txen     : out std_logic; 
    rmii_i_clk      : in std_logic  
  );
end rmii;

architecture Behavioral of rmii is

constant FIFO_DEPTH : natural := 1526 - 1;

component fifo is
    Generic (
        w : integer := 8; -- width
        d : integer := 64 -- depth
    );
    Port (  
        clk_i_read        :   in  std_logic;
        clk_i_wrtie       :   in  std_logic;
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
signal tx_fifo_output : std_logic_vector(7 downto 0) := x"00";
signal tx_fifo_read_clk : std_logic := '0';


-- Output shift register
signal tx_sr : std_logic_vector(7 downto 0);

begin

    tx_fifo : fifo
    generic map (
        w => 8,
        d => FIFO_DEPTH
    )
    port map (
        clk_i_read      => tx_fifo_read_clk,
        clk_i_wrtie     => rmii_i_tx_clk,
        i_rst           => rst,
        i_read          => tx_fifo_read,
        i_write         => tx_fifo_write,
        o_full          => tx_fifo_full,
        o_empty         => tx_fifo_empty,
        i_datIn         => rmii_i_tx_dat,
        o_datOut        => tx_fifo_output
    );
    
    
-- To div clk by 4, you can simply just toggle the output every 2 clocks
clk_div_4 : process(rmii_i_clk) 
variable toggle : std_logic := '0';
begin
    if rising_edge(rmii_i_clk) then
        if toggle = '0' then
            toggle := '1';
        elsif toggle = '1' then
            toggle := '0';
            tx_fifo_read_clk <= not tx_fifo_read_clk;
        end if;
    end if;
end process;


-- Shift register 
rmii_tx_out_set : process(tx_fifo_read_clk)
begin
    if rising_edge(tx_fifo_read_clk) then
        tx_sr <= tx_fifo_output;
    end if;
end process;

rmii_tx_out : process(rmii_i_clk) 
begin
    if rising_edge(rmii_i_clk) then
        tx_sr(1 downto 0) <= tx_sr(3 downto 2);
        tx_sr(3 downto 2) <= tx_sr(5 downto 4);
        tx_sr(5 downto 4) <= tx_sr(7 downto 6);
        tx_sr(7 downto 6) <= "00";
        
        rmii_o_txd <= tx_sr(1 downto 0);  
    end if;
end process;


rst <= not rmii_i_rst;

end Behavioral;
