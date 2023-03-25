vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master_clk_wiz.v" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master.v" \


vlog -work xil_defaultlib \
"glbl.v"

