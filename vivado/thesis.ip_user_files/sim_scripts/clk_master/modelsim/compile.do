vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master_clk_wiz.v" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master.v" \


vlog -work xil_defaultlib \
"glbl.v"

