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

library neorv32;
use neorv32.neorv32_package.all;

entity hardware_top is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 128*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 32*1024;     -- size of processor-internal data memory in bytes
    CUSTOM_ID : std_ulogic_vector(31 downto 0) := x"00000000" -- custom user-defined ID
  );
  port (
    -- Global control --
    clk_i       : in  std_ulogic; -- global clock, rising edge
    rstn_i      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic;  -- UART0 receive data
    
    -- Ethernet --
    eth_o_txd : out std_logic_vector(1 downto 0);
    eth_o_txen : out std_logic;
    eth_i_rxd : out std_logic_vector(1 downto 0); -- Change to in
    eth_i_rxderr : in std_logic;
    eth_o_refclk : out std_logic;
    eth_i_intn : in std_logic
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of hardware_top is

  signal con_gpio_o : std_ulogic_vector(63 downto 0);


component wb_ethernet 
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
    --
     -- Ethernet --
    eth_o_txd : out std_logic_vector(1 downto 0);
    eth_o_txen : out std_logic;
    eth_i_rxd : out std_logic_vector(1 downto 0); -- Change to in
    eth_i_rxderr : in std_logic;
    eth_o_refclk : out std_logic;
    eth_i_refclk : in std_logic
);
end component;

component clk_master is
  Port ( 
    clk_100 : out std_logic;
    clk_50 : out std_logic;
    resetn : in std_logic;
    locked : out std_logic;
    clk_in : in std_logic
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

-- Clock master signals
signal clk_100 : std_logic := '0';
signal clk_50 : std_logic := '0';
signal clk_locked : std_logic := '0';

begin

clk_control : clk_master
    port map (
        clk_100 => clk_100,
        clk_50 => clk_50,
        resetn => rstn_i,
        locked => clk_locked,
        clk_in => clk_i
    );

ethernet_mac : wb_ethernet
    port map (
        clk_i  => clk_100,
        rst_i  => rstn_i,
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
        --
        -- GPIO Interface
        --
         -- Ethernet --
        eth_o_txd => eth_o_txd,
        eth_o_txen => eth_o_txen,
        eth_i_rxd => eth_i_rxd,
        eth_i_rxderr => eth_i_rxderr,
        eth_i_refclk => clk_50,
        eth_o_refclk => eth_o_refclk
    );
    
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
    CPU_EXTENSION_RISCV_Zicsr    => true,              -- implement CSR system?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => true,              -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_EN                   => true,              -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    
    -- Wishbone interface --
    MEM_EXT_EN                   => true,              -- implement external memory bus interface?
    MEM_EXT_TIMEOUT              => 255,               -- cycles after a pending bus access auto-terminates (0 = disabled)
    MEM_EXT_PIPE_MODE            => false,             -- protocol: false=classic/standard wishbone mode, true=pipelined wishbone mode
    MEM_EXT_BIG_ENDIAN           => false,             -- byte order: true=big-endian, false=little-endian
    MEM_EXT_ASYNC_RX             => false,             -- use register buffer for RX data when false
    MEM_EXT_ASYNC_TX             => false              -- use register buffer for TX data when false
  )
  port map (
    -- Global control --
    clk_i       => clk_i,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o      => con_gpio_o,  -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart0_txd_o, -- UART0 send data
    uart0_rxd_i => uart0_rxd_i,  -- UART0 receive data
    
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
    wb_err_i       => wb_err -- transfer error
  );

  -- GPIO output --
  gpio_o <= con_gpio_o(7 downto 0);


end architecture;
