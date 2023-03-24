--------------------------------------------------------------------------------
-- IEEE 802.3 Wishbone Ethernet MAC logic
-- This file connects all the parts of the MAC together
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

entity wb_ethernet is
port (
    clk_i  : in  std_logic;
    rst_i  : in  std_logic;
    --
    -- Whishbone Interface
    --
    dat_i  : in  std_logic_vector(31 downto 0);
    dat_o  : out std_logic_vector(31 downto 0);
    adr_i  : in  std_logic_vector(31 downto 0);
    cyc_i  : in  std_logic;
    lock_i : in  std_logic;
    sel_i  : in  std_logic;
    we_i   : in  std_logic;
    ack_o  : out std_logic;
    err_o  : out std_logic;
    rty_o  : out std_logic;
    stall_o: out std_logic;
    stb_i  : in  std_logic;
    
    -- Ethernet --
    eth_o_txd : out std_logic_vector(1 downto 0);
    eth_o_txen : out std_logic;
    eth_i_rxd : in std_logic_vector(1 downto 0);
    eth_i_rxderr : in std_logic;
    eth_o_refclk : out std_logic
);
end wb_ethernet;

architecture Behavioral of wb_ethernet is
    
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
            dataOut       : out std_logic_vector(7 downto 0)  
        ); 
    end component;

    -- Wishbone accessible Registers
    signal  reg_ena     : std_logic_vector(31 downto 0);
    signal  reg_mask    : std_logic_vector(31 downto 0);
begin

    rty_o   <= '0';
    err_o   <= '0';
    stall_o <= '0';
    
    

--    sync : process
--    begin
--        wait until rising_edge(clk_i);

--        if (stb_i = '1') then
--            ack_o <= '1';
            
            
--        else
--            ack_o <= '0';
--        end if;
--    end process sync;
end Behavioral;

