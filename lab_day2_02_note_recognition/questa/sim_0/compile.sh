#!/bin/bash

clear

#vcom -f vhdl.f
# vlog -timescale "1 ns / 1 ns"     -f verilog.f          | grep Error
# vlog -timescale "1 ns / 1 ns" -sv -f systemverilog.f    | grep Error

#vlog -timescale "1 ns / 1 ns"     -f verilog.f          
vlog -timescale "1 ns / 1 ns" -sv -f systemverilog.f