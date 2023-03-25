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
    eth_i_rxd : out std_logic_vector(1 downto 0); -- Change to in
    eth_i_rxderr : in std_logic;
    eth_i_refclk : in std_logic
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
            dataOut       : out std_logic_vector(7 downto 0);
            status        : out std_logic_vector(1 downto 0)        
        ); 
    end component;
    
    
    component rmii is
    port (
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
    end component; 
    
    
    -- Transmit FIFO 
    signal eth_tx_dat_pres_o : std_logic;
    signal eth_tx_dat_o : std_logic_vector(7 downto 0);

    -- Wishbone accessible Registers
    signal  reg_ena     : std_logic_vector(31 downto 0);
    signal  reg_mask    : std_logic_vector(31 downto 0);
    
    
begin

    wb_rty_o   <= '0';
    wb_err_o   <= '0';
    wb_stall_o <= '0';
       
    
    rmii_int : rmii
    port map (
        rmii_i_rst => rst_i,
        
        rmii_i_tx_ready => eth_tx_dat_pres_o,
        rmii_i_tx_dat => eth_tx_dat_o,
        rmii_i_tx_clk => clk_i,
        
        rmii_o_txd => eth_o_txd,
        rmii_o_txen => eth_o_txen,
        rmii_i_clk => eth_i_refclk
    );
    
  
    eth_tx : eth_tx_mac
    port map (
        wb_i_dat    => wb_dat_i,
        wb_o_dat    => wb_dat_o,
        wb_i_addr   => wb_adr_i,
        wb_i_cyc    => wb_cyc_i,
        wb_i_lock   => wb_lock_i,
        wb_i_sel    => wb_sel_i,
        wb_i_we     => wb_we_i,
        wb_o_ack    => wb_ack_o,
        wb_o_err    => wb_err_o,
        wb_o_rty    => wb_rty_o,
        wb_o_stall  => wb_stall_o,
        wb_i_stb    => wb_stb_i,
        
        clk_i       => clk_i,
        rst_i       => rst_i,
        start       => clk_i,
        dataPresent => eth_tx_dat_pres_o,
        dataOut     => eth_tx_dat_o,
        
        
        status => eth_i_rxd
    );
    
    

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

