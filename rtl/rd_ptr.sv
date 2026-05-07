`timescale 1ns / 1ps
module rd_ptr #(parameter ADDR_WIDTH = 4)(
    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    input logic empty,
    output logic [ADDR_WIDTH:0] b_rd_ptr,
    output logic [ADDR_WIDTH:0] gr_rd_ptr
);

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        b_rd_ptr <= 0;
    end
    else if (rd_en && !empty) begin
        b_rd_ptr <= b_rd_ptr + 1;
    end
end
assign gr_rd_ptr = (b_rd_ptr >> 1) ^ b_rd_ptr;
endmodule
