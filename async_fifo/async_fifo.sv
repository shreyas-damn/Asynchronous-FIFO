`timescale 1ns / 1ps
module async_fifo #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 9) (
    input logic wr_clk,
    input logic wr_rst,
    input logic wr_en,
    input logic [DATA_WIDTH-1:0] d_in,
    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    output logic [DATA_WIDTH-1:0] d_out,
    output logic full,
    output logic empty
);
logic [ADDR_WIDTH:0] wr_b_ptr, wr_g_ptr;
logic [ADDR_WIDTH:0] rd_b_ptr, rd_g_ptr;

logic [ADDR_WIDTH:0] wr_g_ptr_sync1, wr_g_ptr_sync2;
logic [ADDR_WIDTH:0] rd_g_ptr_sync1, rd_g_ptr_sync2;

logic [ADDR_WIDTH-1:0] wr_addr, rd_addr;
logic [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH) - 1];

rd_ptr #(ADDR_WIDTH) rd_block (
    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),
    .empty(empty),
    .b_rd_ptr(rd_b_ptr),
    .gr_rd_ptr(rd_g_ptr)

);

wr_ptr #(ADDR_WIDTH) wr_block (
    .wr_clk(wr_clk),
    .wr_rst(wr_rst),
    .wr_en(wr_en),
    .full(full),
    .b_wr_ptr(wr_b_ptr),
    .gr_wr_ptr(wr_g_ptr)
);

//SYNCHRONIZERS FOR WR_BLOCK
//SYNCS WR_BLOCK into read clock domain
ff_sync #(ADDR_WIDTH + 1) sync1 (

    .clk(rd_clk),
    .rst_n(rd_rst_n),
    .din(wr_g_ptr),
    .dout(wr_g_ptr_sync1)
);
ff_sync #(ADDR_WIDTH + 1) sync2 (
    .clk(rd_clk),
    .rst_n(rd_rst_n),
    .din(wr_g_ptr_sync1),
    .dout(wr_g_ptr_sync2)
);

//SYNCHRONIZERS FOR RD_BLOCK
//SYNCS RD_BLOCK into write clock domain
ff_sync #(ADDR_WIDTH + 1) sync3 (
    .clk(wr_clk),
    .rst_n(wr_rst),
    .din(rd_g_ptr),
    .dout(rd_g_ptr_sync1)
);
ff_sync #(ADDR_WIDTH + 1) sync4 (
    .clk(wr_clk),
    .rst_n(wr_rst),
    .din(rd_g_ptr_sync1),
    .dout(rd_g_ptr_sync2)
);

//getting binary address from read and write pointer
//binary addresses are easier to increment inside memory
assign wr_addr = wr_b_ptr[ADDR_WIDTH-1:0];
assign rd_addr = rd_b_ptr[ADDR_WIDTH-1:0];

//writing into the FIFO
always_ff @(posedge wr_clk) begin
    if (wr_en && !full) begin
        mem[wr_addr] <= d_in;
    end
end

//reading into the FIFO
always_ff @(posedge rd_clk) begin
    if (rd_en && !empty) begin
        d_out <= mem[rd_addr];
    end
end

//empty logic
//checking if gray read pointer is equal to synchronized gray write pointer 
assign empty = (rd_g_ptr == wr_g_ptr_sync2);

//full logic
/*  checks if the gray write pointer's first bit is not equal to gray read pointer's first bit
    && (logic operator)
    checks if rest of the gray write pointer's bits are equal to gray_rd pointer's remaining bits 
*/
assign full = (wr_g_ptr[ADDR_WIDTH] != rd_g_ptr_sync2[ADDR_WIDTH]) && ((wr_g_ptr[ADDR_WIDTH-1:0]) == (rd_g_ptr_sync2[ADDR_WIDTH-1:0]));
endmodule
