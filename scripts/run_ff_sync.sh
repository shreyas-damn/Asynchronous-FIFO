#!/bin/bash
set -e
echo "Running Simulation"
#creating sim file if it doesn't already exist
mkdir -p sim/ff_sync
iverilog -g2012 -o sim/ff_sync/ff_sync.out \
rtl/ff_sync.sv \
tb/ff_sync_tb.sv
vvp sim/ff_sync/ff_sync.out |tee sim/ff_sync/ff_sync.log
echo "Simulation Complete. Outputs stored in sim"


