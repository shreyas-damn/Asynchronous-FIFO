#!/bin/bash
set -e
echo "Running Simulation"
mkdir -p sim/wr_ptr
iverilog -g2012 -o sim/wr_ptr/wr_ptr.out \
rtl/wr_ptr.sv \
tb/wr_ptr_tb.sv
vvp sim/wr_ptr/wr_ptr.out | tee sim/wr_ptr/wr_ptr.log
echo "Simulaton Complete. Outputs stored in sim"