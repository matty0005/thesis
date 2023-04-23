-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../project_1.gen/sources_1/ip/clk_master/clk_master_clk_wiz.v" \
  "../../../../project_1.gen/sources_1/ip/clk_master/clk_master.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

