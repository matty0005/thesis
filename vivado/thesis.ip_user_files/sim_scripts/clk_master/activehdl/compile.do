vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master_clk_wiz.v" \
"../../../../thesis.gen/sources_1/ip/clk_master/clk_master.v" \


vlog -work xil_defaultlib \
"glbl.v"

