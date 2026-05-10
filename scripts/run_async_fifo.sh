#!/bin/bash
echo "Running Simulation"
set -e
mkdir -p sim/async_fifo
iverilog -g2012 -o sim/async_fifo/async_fifo.out \
rtl/async_fifo.sv \
tb/async_fifo_tb.sv \
rtl/ff_sync.sv \
rtl/rd_ptr.sv \
rtl/wr_ptr.sv
vvp sim/async_fifo/async_fifo.out | tee sim/async_fifo/async_fifo.log
echo "Successfully Completed Simulation"