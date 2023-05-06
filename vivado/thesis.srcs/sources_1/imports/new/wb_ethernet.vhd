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
        
            status        : out std_logic_vector(1 downto 0);
        
        
            -- Interface
            clk_i  : in  std_logic;
            rst_i  : in  std_logic := '0';
            start         : out std_logic := '0';
            dataPresent   : out std_logic := '0';
            dataOut       : out std_logic_vector(7 downto 0)
            
        ); 
    end component;
    
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
    
    
    component rmii is
    port (
        rmii_i_rst      : in std_logic;
        -- From ethernet MAC
        rmii_i_tx_ready : in std_logic;
        rmii_i_tx_dat   : in std_logic_vector(7 downto 0);
        rmii_i_tx_start  : in std_logic;
        
        -- RMII interface itself
        rmii_o_txd      : out std_logic_vector(1 downto 0);
        rmii_o_txen     : out std_logic; 
        

        eth_i_rxderr    : out std_logic;
        
        -- From ethernet MAC
        
        clk_i_write : in STD_LOGIC;
        clk_i_read : in STD_LOGIC
    );
    end component; 
    
    
    -- Transmit FIFO 
    signal eth_tx_start : std_logic;
    signal eth_tx_dat_pres_o : std_logic;
    signal eth_tx_dat_o : std_logic_vector(7 downto 0);
    
    -- Rx FIFO 
--    signal eth_rx_dat_pres_o : std_logic;
--    signal eth_rx_dat_o : std_logic_vector(7 downto 0);

    -- Wishbone accessible Registers
    signal  reg_ena     : std_logic_vector(31 downto 0);
    signal  reg_mask    : std_logic_vector(31 downto 0);
        
        
    signal wb_tx_ack, wb_rx_ack, wb_ctrl_ack : std_logic;
    signal ctrl_start_rst : std_logic := '0';
    signal ctrl_rst_ack : std_logic := '0';

    -- Controller constants ---- 
    constant CTRL_PHY_MODE : std_logic_vector(31 downto 0) := x"13370100";
    
    type ctrl_state is (IDLE, RESET_START, RESET_1, RESET_2);
    signal currentCtrlState: ctrl_state := IDLE;
    
    signal recvIrq : std_logic;
    
    signal wb_tx_dat_o, wb_rx_dat_o: std_logic_vector(31 downto 0);
    signal wb_tx_err_o, wb_rx_err_o : std_logic;
    signal wb_tx_o_rty, wb_rx_o_rty : std_logic;
    signal wb_tx_o_stall, wb_rx_o_stall : std_logic;
    
    

    
begin

    wb_rty_o   <= '0';
    wb_err_o   <= '0';
    wb_stall_o <= '0';
    
    eth_o_refclk <= eth_i_refclk;
    
    
    eth_o_exti <= "000" & recvIrq;
       
    
    rmii_int : rmii
    port map (
        rmii_i_rst => rstn_i,
        
        rmii_i_tx_ready => eth_tx_dat_pres_o,
        rmii_i_tx_dat => eth_tx_dat_o,
        
        rmii_i_tx_start => eth_tx_start,
        
        rmii_o_txd => eth_o_txd,
        rmii_o_txen => eth_o_txen,
        
        clk_i_write => clk_i,
        clk_i_read => eth_i_refclk,
        
        
        eth_i_rxderr => eth_i_rxderr

    );
    
--    eth_o_txen <= eth_tx_dat_pres_o;
--    eth_o_txd <= eth_tx_dat_o(1 downto 0);
--    eth_tx : eth_tx_mac
--    port map (
--        wb_i_dat    => wb_dat_i,
--        wb_o_dat    => wb_tx_dat_o,
--        wb_i_addr   => wb_adr_i,
--        wb_i_cyc    => wb_cyc_i,
--        wb_i_lock   => wb_lock_i,
--        wb_i_sel    => wb_sel_i,
--        wb_i_we     => wb_we_i,
--        wb_o_ack    => wb_tx_ack,
--        wb_o_err    => wb_tx_err_o,
--        wb_o_rty    => wb_tx_o_rty,
--        wb_o_stall  => wb_tx_o_stall,
--        wb_i_stb    => wb_stb_i,
        
--        clk_i       => clk_i,
--        rst_i       => rstn_i,
--        start       => eth_tx_start,
--        dataPresent => eth_tx_dat_pres_o,
--        dataOut     => eth_tx_dat_o
--    );
    
    eth_rx : eth_rx_mac
    port map (
        wb_i_dat    => wb_dat_i,
        wb_o_dat    => wb_rx_dat_o,
        wb_i_addr   => wb_adr_i,
        wb_i_cyc    => wb_cyc_i,
        wb_i_lock   => wb_lock_i,
        wb_i_sel    => wb_sel_i,
        wb_i_we     => wb_we_i,
        wb_o_ack    => wb_rx_ack,
        wb_o_err    => wb_rx_err_o,
        wb_o_rty    => wb_rx_o_rty,
        wb_o_stall  => wb_rx_o_stall,
        wb_i_stb    => wb_stb_i,
        
        clk_i  => clk_i,
        rst_i  => rstn_i,
        eth_i_rxd => eth_io_rxd,
        eth_i_crs_dv => eth_io_crs_dv,
        recv_irq => recvIrq
    );
    
wb_ack_o <= wb_tx_ack or wb_rx_ack;
wb_dat_o <= wb_tx_dat_o or wb_rx_dat_o;

-------------------------------------------
-- Controller - looks after the Phy chip --
-------------------------------------------

--CONTROLLER : process(clk_i, rstn_i)
--begin
--    if rising_edge(clk_i) then
        
--        if ctrl_rst_ack = '1' then
--            ctrl_start_rst <= '0';
--        end if;
        
--        -- Only handle data when strobe
--        if wb_stb_i = '1' and wb_adr_i = CTRL_PHY_MODE then 
--            wb_ctrl_ack <= '1';
            
--            -- Ensure write enable is set.
--            if wb_we_i = '0' then -- Read
                

--            elsif wb_we_i = '1' then -- Write
            
--                if wb_dat_i(0) = '1' then --reset chip
--                    ctrl_start_rst <= '1';
                    
               
--                end if;
                
--            end if;
--        end if;
--    end if;

--end process;


--PHY_FSM : process(clk_i, rstn_i)
--variable timerCounter : natural range 0 to 200 := 0;
--begin 

--    if rising_edge(clk_i) then 
--        case currentCtrlState is
--            when IDLE =>
--                if ctrl_start_rst = '1' then
--                    ctrl_rst_ack <= '1';
--                    currentCtrlState <= RESET_START;
--                    timerCounter := 0;
--                else
--                    currentCtrlState <= IDLE;
--                    ctrl_rst_ack <= '0';
--                end if;
--                eth_o_rstn <= '1';
                
--            when RESET_START => 
--                eth_io_crs_dv <= '0'; 
--                eth_io_rxd <= "11"; -- Set mode to 011
--                eth_o_rstn <= '0'; -- active low
--                t_eth_io_rxd <= "11";
                
--                timerCounter := timerCounter + 1;
--                if timerCounter = 200 then
--                    currentCtrlState <= RESET_1;
--                    timerCounter := 0;
--                end if;
                
--            when RESET_1 =>
--                eth_o_rstn <= '0'; -- active low
--                currentCtrlState <= RESET_2;
                
--            when RESET_2 =>
--                eth_io_crs_dv <= 'Z'; -- Set to high impeadance - now this is an input.
--                eth_io_rxd <= "ZZ";
--                t_eth_io_rxd <= "00";
--                currentCtrlState <= IDLE;
--                eth_o_rstn <= '1';

--        end case;
--    end if;
    
--end process;


end Behavioral;

