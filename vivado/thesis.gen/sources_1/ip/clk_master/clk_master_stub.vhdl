-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
-- Date        : Wed May 10 07:05:27 2023
-- Host        : Squid running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/Matt/thesis/vivado/thesis.gen/sources_1/ip/clk_master/clk_master_stub.vhdl
-- Design      : clk_master
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_master is
  Port ( 
    clk_100 : out STD_LOGIC;
    clk_50 : out STD_LOGIC;
    clk_50p : out STD_LOGIC;
    clk_p50 : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end clk_master;

architecture stub of clk_master is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_100,clk_50,clk_50p,clk_p50,resetn,locked,clk_in";
begin
end;
