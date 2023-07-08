#!/bin/bash

#clear

#vcom -f vhdl.f
# vlog -timescale "1 ns / 1 ns"     -f verilog.f          | grep Error
# vlog -timescale "1 ns / 1 ns" -sv -f systemverilog.f    | grep Error

#iverilog -g2012 -ccmd.f -cverilog.f  -csystemverilog.f -s tb  -o a.out      
iverilog -g2012 -ccmd.f  -csystemverilog.f -s tb  -o a.out      
