// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun Apr 16 13:13:17 2023
// Host        : Squid running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Matt/thesis/vivado/thesis.gen/sources_1/ip/clk_master/clk_master_stub.v
// Design      : clk_master
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_master(clk_100, clk_50, resetn, locked, clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk_100,clk_50,resetn,locked,clk_in" */;
  output clk_100;
  output clk_50;
  input resetn;
  output locked;
  input clk_in;
endmodule
