-- #################################################################################################
-- # << NEORV32 - Test Setup using the default UART-Bootloader to upload and run executables >>    #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2023, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32                           #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library neorv32;
use neorv32.neorv32_package.all;

entity hardware_top is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 75000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 256*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 128*1024;     -- size of processor-internal data memory in bytes
    CUSTOM_ID : std_ulogic_vector(31 downto 0) := x"00000000" -- custom user-defined ID
  );
  port (
    -- Global control --
    clk_i       : in  std_ulogic; -- global clock, rising edge
    rstn_i      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    gpio_io      : inout std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic;  -- UART0 receive data
    
    -- Test Ethernet outof PMOD JD --
    pmod_o : out std_logic_vector(7 downto 0);
    sw : in std_logic_vector(7 downto 0);
--    pmod_i : in std_logic_vector(3 downto 0);
    
    
    -- Phy Chip Nexys
    eth_io_mdc: inout std_logic;
    eth_io_mdio: inout std_logic;
    eth_o_rstn: out std_logic;
    eth_io_crs_dv: in std_logic;
    eth_i_rxerr: in std_logic;
    eth_io_rxd: in std_logic_vector(1 downto 0);
    eth_o_txen: out std_logic;
    eth_o_txd: out std_logic_vector(1 downto 0);
    eth_o_refclk: out std_logic;
    eth_i_intn: in std_logic;
    
    
    t_btnc : in std_logic;
    t_btnl : in std_logic;
    t_btnr : in std_logic;
    
    sd_o_rst: out std_logic;
    sd_i_cd : in std_logic; -- card detect
    sd_o_sck : out std_logic; -- clock
    sd_o_cmd : out std_logic; -- MOSI
    sd_i_miso: in std_logic;
    sd_o_csn: out std_logic;
    
    ssd : out std_logic_vector (6 downto 0);
    anode : out std_logic_vector (7 downto 0)

  );
end entity;






architecture neorv32_test_setup_bootloader_rtl of hardware_top is

  signal gpio_o : std_ulogic_vector(63 downto 0);
  signal gpio_i : std_ulogic_vector(63 downto 0);


component packet_classifier is 
  Port (
    clk:  in std_logic;
    rst:  in std_logic;
    valid: out std_logic; -- Output "forward" is valid when 1. 
    forward: out std_logic;
    ignore_count: out std_logic;
    
    packet_in: in std_logic_vector(1 downto 0);
    packet_valid: in std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic;
    
    test_out: out std_logic_vector(7 downto 0)
   );
end component; 

component wb_ethernet 
port (
    clk_i  : in  std_logic;
    clk_50  : in  std_logic;
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
    --
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

component clk_master is
  Port ( 
    clk_100 : out std_logic;
    clk_50 : out std_logic;
    clk_75 : out std_logic;
    clk_50p : out std_logic; -- 270deg = 15ns
    clk_p50 : out std_logic; -- 90 deg = 5ns
    resetn : in std_logic;
    locked : out std_logic;
    clk_in : in std_logic
  );
end component;

component sevensegdisplay is
    Port ( 
        value : in STD_LOGIC_VECTOR (3 downto 0);
        display : out STD_LOGIC_VECTOR (6 downto 0)
    );
end component;
  
  

signal wb_lock : std_logic := '0';
signal wb_rty : std_logic := '0';
signal wb_stall : std_logic := '0';
signal wb_cyc : std_logic;
signal wb_stb : std_logic;
signal wb_write : std_logic;
signal wb_ack : std_logic;
signal wb_err : std_logic;

signal wb_addr : std_ulogic_vector(31 downto 0);
signal wb_dat_i : std_ulogic_vector(31 downto 0);
signal wb_dat_o : std_logic_vector(31 downto 0);

signal wb_sel : std_ulogic_vector(3 downto 0);


signal wb_eth_o_tx : std_logic_vector(1 downto 0);
signal wb_eth_i_rx : std_logic_vector(1 downto 0);

signal wb_eth_o_txen : std_logic;
signal wb_eth_i_rxderr : std_logic;
signal wb_eth_i_txen : std_logic;
signal wb_eth_o_refclk : std_logic;

signal spi_csn :  std_ulogic_vector(07 downto 0);

-- Clock master signals
signal clk_100 : std_logic := '0';
signal clk_75 : std_logic := '0';
signal clk_50 : std_logic := '0';
signal clk_p50 : std_logic := '0';
signal clk_50p : std_logic := '0';
signal clk_locked : std_logic := '0';



-- Test Signals for Phy and Pmod
signal eth_txd : std_logic_vector(1 downto 0);
signal eth_rxd : std_logic_vector(1 downto 0);
signal eth_txen : std_logic;
signal eth_rxerr : std_logic;
signal eth_crs_dv : std_logic;


signal exti_lines : std_ulogic_vector(31 downto 0);
signal eth_exti_lines : std_logic_vector(3 downto 0);


signal test_eth : std_logic_vector(1 downto 0);

signal spi_clk_o : std_logic;
signal spi_dat_o : std_logic;
signal spi_dat_i : std_logic;
signal spi_csn_o : std_ulogic_vector(07 downto 0);

signal pc_valid : std_logic;
signal pc_forward : std_logic;
signal pc_valid_counter: std_logic_vector(3 downto 0) := "0000";
signal pc_invalid_counter: std_logic_vector(3 downto 0) := "0000";

constant FILTER_DELAY_TICKS : integer := 224;
signal rxd_reg : std_logic_vector((FILTER_DELAY_TICKS * 2) - 1 downto 0) := (others => '0');
signal crs_dv_reg : std_logic_vector(FILTER_DELAY_TICKS - 1 downto 0) := (others => '0');
signal crs_dv_allow : std_logic := '0';
signal pf_allow : std_logic := '0';
signal pf_ignore_count : std_logic := '0';

signal rst : std_logic;




begin

rst <= not rstn_i;

-- Connections
eth_o_txd <= eth_txd;
eth_o_txen <= eth_txen;
eth_rxerr <= eth_i_rxerr;

eth_rxd <= eth_io_rxd;

sd_o_csn <= spi_csn(0);

exti_lines(3 downto 0) <= t_btnl & t_btnc & t_btnr & std_ulogic_vector(eth_exti_lines(0 downto 0));

ethernet_mac : wb_ethernet
    port map (
        clk_i  => clk_75,
        clk_50 => clk_50,
        rstn_i  => rstn_i,
        --
        -- Whishbone Interface
        --
        wb_dat_i    => std_logic_vector(wb_dat_i),
        wb_dat_o    => wb_dat_o,
        wb_adr_i    => std_logic_vector(wb_addr),
        wb_cyc_i    => wb_cyc,
        wb_lock_i   => wb_lock,
        wb_sel_i    => wb_sel(0),
        wb_we_i     => wb_write,
        wb_ack_o    => wb_ack,
        wb_err_o    => wb_err,
        wb_rty_o    => wb_rty,
        wb_stall_o  => wb_stall,
        wb_stb_i    => wb_stb,

         -- Ethernet --
        eth_o_txd => eth_txd,
        eth_o_txen => eth_txen,
--        eth_io_rxd => eth_io_rxd,
        eth_io_rxd => rxd_reg((FILTER_DELAY_TICKS * 2) - 1 downto (FILTER_DELAY_TICKS * 2) - 2),
        t_eth_io_rxd => test_eth,
        eth_i_rxderr => eth_rxerr,
        eth_i_refclk => clk_p50,
        eth_o_refclk => eth_o_refclk,
        
        eth_o_rstn => eth_o_rstn,
        eth_io_crs_dv => crs_dv_allow,
        eth_i_intn => eth_i_intn,
        
        eth_io_mdc => open,
        eth_io_mdio => open,
        
        eth_o_exti => eth_exti_lines
    );
    
    
    
    pc: packet_classifier 
    port map(
        clk => clk_50,
        rst => rst,
        valid => pc_valid,
        forward => pc_forward,
        ignore_count => pf_ignore_count,
        
        packet_in => eth_rxd,
        packet_valid => eth_io_crs_dv,
        
        spi_clk => spi_clk_o,
        spi_mosi => spi_dat_o,
        spi_miso => spi_dat_i,
        spi_csn => spi_csn_o(1),
        
        test_out => open
   );
    
    
   clk_control : clk_master
    port map (
        clk_100 => clk_100,
        clk_75 => clk_75,
        clk_50 => clk_50,
        clk_50p => clk_50p,
        clk_p50 => clk_p50,
        resetn => rstn_i,
        locked => clk_locked,
        clk_in => clk_i
    );
    
    
    pc_ssd: sevensegdisplay
    port map (
        display => ssd,
        value => pc_valid_counter
    );
    anode <= "11111110";
    
    pmod_o(2) <= crs_dv_allow;
    pmod_o(5) <= pc_valid;
    pmod_o(6) <= pc_forward;
    pmod_o(3) <= pf_allow;
    
    pmod_o(1 downto 0) <= rxd_reg((FILTER_DELAY_TICKS * 2) - 1 downto (FILTER_DELAY_TICKS * 2) - 2);
    
    pmod_o(7) <= clk_50;

    
    pc_coutner: process(clk_50)
    begin
--        if rstn_i = '0' then
--            pc_valid_counter <= "0000";
        if rising_edge(clk_50) then
            if pc_valid = '1' then
                
                if pc_forward = '1' then
                    pf_allow <= '1';
                    if pf_ignore_count = '0'  then
                        pc_valid_counter <= pc_valid_counter + 1;
                    end if;
                elsif sw(0) = '1' then
                    pf_allow <= '1';
                else
                    pf_allow <= '0';
                    pc_invalid_counter <= pc_invalid_counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    crs_dv_allow <= crs_dv_reg(FILTER_DELAY_TICKS - 1) when pf_allow = '1' else '0';
    
    pf_registers: process(clk_p50)
    begin
        if rising_edge(clk_p50) then
            rxd_reg <= rxd_reg((FILTER_DELAY_TICKS * 2) - 3 downto 0) & eth_rxd;
            crs_dv_reg <= crs_dv_reg(FILTER_DELAY_TICKS - 2 downto 0) & eth_io_crs_dv;
        end if;
    end process;
  
  
  
 
    
  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CUSTOM_ID                    => x"beefcafe",
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => true,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C        => true,              -- implement compressed extension?
    CPU_EXTENSION_RISCV_M        => true,              -- implement mul/div extension?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    
    FAST_MUL_EN                  => true,             -- use DSPs for M extension's multiplier
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => true,              -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM                  => 64,                -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    IO_SPI_EN                    => true,              -- implement serial peripheral interface (SPI)?
    IO_TRNG_EN                   => true,              -- implement true random number generator (TRNG)?
    
    -- Wishbone interface --
    MEM_EXT_EN                   => true,              -- implement external memory bus interface?
    MEM_EXT_TIMEOUT              => 255,               -- cycles after a pending bus access auto-terminates (0 = disabled)
    MEM_EXT_PIPE_MODE            => false,             -- protocol: false=classic/standard wishbone mode, true=pipelined wishbone mode
    MEM_EXT_BIG_ENDIAN           => false,             -- byte order: true=big-endian, false=little-endian
    MEM_EXT_ASYNC_RX             => false,             -- use register buffer for RX data when false
    MEM_EXT_ASYNC_TX             => false,             -- use register buffer for TX data when false
    
    -- External Interrupts Controller (XIRQ) --
    XIRQ_NUM_CH                  => 4,                 -- number of external IRQ channels (0..32)
    XIRQ_TRIGGER_TYPE            =>  x"ffffffff",      -- trigger type: 0=level, 1=edge
    XIRQ_TRIGGER_POLARITY        => x"ffffffff"        -- trigger polarity: 0=low-level/falling-edge, 1=high-level/rising-edge
    
    
  )
  port map (
    -- Global control --
    clk_i       => clk_75,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o      => gpio_o,  -- parallel output
    gpio_i      => gpio_i,  -- parallel input
    
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart0_txd_o, -- UART0 send data
    uart0_rxd_i => uart0_rxd_i,  -- UART0 receive data
    
    -- SPI (available if IO_SPI_EN = true) --
    spi_clk_o      => spi_clk_o,
    spi_dat_o      => spi_dat_o, -- MOSI
    spi_dat_i      => spi_dat_i, -- MISO
    spi_csn_o      => spi_csn_o, -- chip-select
    
    -- Wishbone bus interface (available if MEM_EXT_EN = true) --
--    wb_tag_o       : out std_ulogic_vector(02 downto 0); -- request tag
    wb_adr_o       => wb_addr, -- address
    wb_dat_i       => std_ulogic_vector(wb_dat_o), -- read data
    wb_dat_o       => wb_dat_i, -- write data
    wb_we_o        => wb_write, -- read/write
    wb_sel_o       => wb_sel, -- byte enable
    wb_stb_o       => wb_stb, -- strobe
    wb_cyc_o       => wb_cyc, -- valid cycle
    wb_ack_i       => wb_ack, -- transfer acknowledge
    wb_err_i       => wb_err, -- transfer error
    
    -- External platform interrupts (available if XIRQ_NUM_CH > 0) --
    xirq_i         => exti_lines -- IRQ channels
  );

  -- GPIO output --
  GPIO_TRISTATE: for i in 0 to 6 generate
      gpio_io(i) <= gpio_o(i) when gpio_o(i + 32) = '1' else 'Z';
  end generate;
  
  gpio_io(7) <= std_ulogic(eth_exti_lines(0));
    
  eth_io_mdc <= gpio_o(8) when gpio_o(40) = '1' else 'Z';
  eth_io_mdio <= gpio_o(9) when gpio_o(41) = '1' else 'Z';
  
  gpio_i <= x"000000000000" & "00000" & sd_i_cd & eth_io_mdio & eth_io_mdc & gpio_io(7 downto 0);
  
  sd_o_rst <= gpio_o(11);
  
  
  sd_o_sck  <= spi_clk_o; -- clock
  sd_o_cmd <= spi_dat_o; -- MOSI
  spi_dat_i <= sd_i_miso;
  sd_o_csn <= spi_csn_o(0);   


end architecture;
