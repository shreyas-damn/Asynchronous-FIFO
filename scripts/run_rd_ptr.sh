#!/bin/bash
set -e
echo "Running Simulation"
mkdir -p sim/rd_ptr
iverilog -g2012 -o sim/rd_ptr/rd_ptr.out \
rtl/rd_ptr.sv \
tb/rd_ptr_tb.sv
vvp sim/rd_ptr/rd_ptr.out | tee sim/rd_ptr/rd_ptr.log
echo "Simulation Completed Successfully"