`timescale 1ns / 1ps

module wr_ptr_tb();
parameter ADDR_WIDTH = 4;
logic wr_clk;
logic wr_rst;
logic wr_en;
logic full;
logic [ADDR_WIDTH-1:0] b_wr_ptr;
logic [ADDR_WIDTH-1:0] gr_wr_ptr;

wr_ptr #(.ADDR_WIDTH(ADDR_WIDTH)) dut (
    .wr_clk(wr_clk),
    .wr_rst(wr_rst),
    .wr_en(wr_en),
    .full(full),
    .b_wr_ptr(b_wr_ptr),
    .gr_wr_ptr(gr_wr_ptr)
);

always #5 wr_clk = ~wr_clk;

initial begin
    wr_clk = 0;
    wr_rst = 0;
    wr_en  = 0;
    full   = 0;

    #12;
    wr_rst = 1;

    repeat (5) begin
        wr_en = 1;
        full  = 0;
        #10;
    end

    wr_en = 0;
    #20;

    full = 1;
    wr_en = 1;
    #30;

    full = 0;
    wr_en = 1;
    #30;

    $finish;
end

endmodule


