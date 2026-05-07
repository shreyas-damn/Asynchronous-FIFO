`timescale 1ns / 1ps
`timescale 1ns / 1ps

module rd_ptr_tb;
parameter ADDR_WIDTH = 4;
logic clk;
logic rd_rst_n;
logic rd_en;
logic empty;

logic [ADDR_WIDTH:0] b_rd_ptr;
logic [ADDR_WIDTH:0] gr_rd_ptr;

rd_ptr #(.ADDR_WIDTH(ADDR_WIDTH)) UUT(
    .clk(clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),
    .empty(empty),
    .b_rd_ptr(b_rd_ptr),
    .gr_rd_ptr(gr_rd_ptr)
);

always #5 clk = ~clk;
initial begin
    clk = 0;
    rd_rst_n = 0;
    rd_en = 0;
    empty = 1;
    #12 rd_rst_n = 1;
    #10 rd_en = 1;
    empty = 1;
    #20 empty = 0;
    #10 rd_en = 1;
    #40 rd_en = 1;
    #40 rd_en = 1;
    #20 rd_en = 0;

    $finish;
end

endmodule