# Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk_i }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_i}];

# Allow TRNG
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets <myHier/myNet>]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets neorv32_top_inst/neorv32_trng_inst_true.neorv32_trng_inst/neoTRNG_inst/neoTRNG_cell_inst[0].neoTRNG_cell_inst_i/enable_sreg_l_reg[0]_0]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets neorv32_top_inst/neorv32_trng_inst_true.neorv32_trng_inst/neoTRNG_inst/neoTRNG_cell_inst[0].neoTRNG_cell_inst_i/real_hardware.inv_chain_s_reg[2]_i_1]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets neorv32_top_inst/neorv32_trng_inst_true.neorv32_trng_inst/neoTRNG_inst/neoTRNG_cell_inst[2].neoTRNG_cell_inst_i/real_hardware.inv_chain_s_reg[2]_i_3]

# Allow SRLAtch
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets neorv32_top_inst/neorv32_gpio_inst_true.neorv32_gpio_inst/din[13]_i_2_n_0]

#CPU Reset Button
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn_i }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn



# LEDs
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[1] }]; #IO_L24P_T3_RS1_15 Sch=led[1]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[2] }]; #IO_L17N_T2_A25_15 Sch=led[2]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[3] }]; #IO_L8P_T1_D11_14 Sch=led[3]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[4] }]; #IO_L7P_T1_D09_14 Sch=led[4]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[5] }]; #IO_L18N_T2_A11_D27_14 Sch=led[5]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[6] }]; #IO_L17P_T2_A14_D30_14 Sch=led[6]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { gpio_io[7] }]; #IO_L18P_T2_A12_D28_14 Sch=led[7]


set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[0] }]; #IO_L16N_T2_A15_D31_14 Sch=led[8]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[1] }]; #IO_L14N_T2_SRCC_14 Sch=led[9]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[2] }]; #IO_L22P_T3_A05_D21_14 Sch=led[10]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[3] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[11]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[4] }]; #IO_L16P_T2_CSI_B_14 Sch=led[12]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[5] }]; #IO_L22N_T3_A04_D20_14 Sch=led[13]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[6] }]; #IO_L20N_T3_A07_D23_14 Sch=led[14]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { gpio_o2[7] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=led[15]

#USB-RS232 Interface
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { uart0_rxd_i }]; #IO_L7P_T1_AD6P_35 Sch=uart_txd_in
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { uart0_txd_o }]; #IO_L11N_T1_SRCC_35 Sch=uart_rxd_out




##Pmod Header JD
set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { eth1_o_txd[0] }]; #IO_L21N_T3_DQS_35 Sch=jd[1]
set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { eth1_io_rxd[1] }]; #IO_L17P_T2_35 Sch=jd[2]
set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { eth1_io_crs_dv }]; #IO_L17N_T2_35 Sch=jd[3]
set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { eth1_io_mdc }]; #IO_L20N_T3_35 Sch=jd[4]
set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { eth1_o_txen }]; #IO_L15P_T2_DQS_35 Sch=jd[7]
set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { eth1_io_rxd[0] }]; #IO_L20P_T3_35 Sch=jd[8]
set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { eth1_o_refclk }]; #IO_L15N_T2_DQS_35 Sch=jd[9]
set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { eth1_io_mdio }]; #IO_L13N_T2_MRCC_35 Sch=jd[10]

set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { eth1_o_txd[1] }]; #IO_L19P_T3_35 Sch=jc[4]


#set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { eth_o_txd[0] }]; #IO_L21N_T3_DQS_35 Sch=jd[1]
#set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { eth_io_rxd[1] }]; #IO_L17P_T2_35 Sch=jd[2]
#set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { eth_io_crs_dv }]; #IO_L17N_T2_35 Sch=jd[3]
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { eth_io_mdc }]; #IO_L20N_T3_35 Sch=jd[4]
#set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { eth_o_txen }]; #IO_L15P_T2_DQS_35 Sch=jd[7]
#set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { eth_io_rxd[0] }]; #IO_L20P_T3_35 Sch=jd[8]
#set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { eth_o_refclk }]; #IO_L15N_T2_DQS_35 Sch=jd[9]
#set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { eth_io_mdio }]; #IO_L13N_T2_MRCC_35 Sch=jd[10]
#set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { eth_o_txd[1] }]; #IO_L23N_T3_35 Sch=jc[1]


##SMSC Ethernet PHY
set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { eth_io_mdc }]; #IO_L11P_T1_SRCC_16 Sch=eth_mdc
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { eth_io_mdio }]; #IO_L14N_T2_SRCC_16 Sch=eth_mdio
set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { eth_o_rstn }]; #IO_L10P_T1_AD15P_35 Sch=eth_rstn
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { eth_io_crs_dv }]; #IO_L6N_T0_VREF_16 Sch=eth_crsdv
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { eth_i_rxerr }]; #IO_L13N_T2_MRCC_16 Sch=eth_rxerr
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { eth_io_rxd[0] }]; #IO_L13P_T2_MRCC_16 Sch=eth_rxd[0]
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { eth_io_rxd[1] }]; #IO_L19N_T3_VREF_16 Sch=eth_rxd[1]
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { eth_o_txen }]; #IO_L11N_T1_SRCC_16 Sch=eth_txen
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { eth_o_txd[0] }]; #IO_L14P_T2_SRCC_16 Sch=eth_txd[0]
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { eth_o_txd[1] }]; #IO_L12N_T1_MRCC_16 Sch=eth_txd[1]
set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { eth_o_refclk }]; #IO_L11P_T1_SRCC_35 Sch=eth_refclk
set_property -dict { PACKAGE_PIN B8    IOSTANDARD LVCMOS33 } [get_ports { eth_i_intn }]; #IO_L12P_T1_MRCC_16 Sch=eth_intn


#Buttons
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { t_btnc }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { t_btnr }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { t_btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl


#Micro SD Connector
set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS33 } [get_ports { sd_o_rst }]; #IO_L14P_T2_SRCC_35 Sch=sd_reset
set_property -dict { PACKAGE_PIN A1    IOSTANDARD LVCMOS33 } [get_ports { sd_i_cd }]; #IO_L9N_T1_DQS_AD7N_35 Sch=sd_cd
set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports { sd_o_sck }]; #IO_L9P_T1_DQS_AD7P_35 Sch=sd_sck
set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports { sd_o_cmd }]; #IO_L16N_T2_35 Sch=sd_cmd
set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { sd_i_miso }]; #IO_L16P_T2_35 Sch=sd_dat[0]
#set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { sd_io_dat[1] }]; #IO_L18N_T2_35 Sch=sd_dat[1]
#set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { sd_io_dat[2] }]; #IO_L18P_T2_35 Sch=sd_dat[2]
set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports { sd_o_csn }]; #IO_L14N_T2_SRCC_35 Sch=sd_dat[3]

#7 segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { ssd[0] }]; 
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { ssd[1] }];
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { ssd[2] }]; 
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { ssd[3] }];
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { ssd[4] }]; 
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { ssd[5] }]; 
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { ssd[6] }];

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { anode[0] }]; 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { anode[1] }]; 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { anode[2] }]; 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { anode[3] }]; 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { anode[4] }]; 
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { anode[5] }]; 
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { anode[6] }]; 
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { anode[7] }]; 


