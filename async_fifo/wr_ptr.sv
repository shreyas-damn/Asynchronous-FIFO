`timescale 1ns / 1ps

module wr_ptr #(parameter ADDR_WIDTH = 4)(
    input logic wr_clk,
    input logic wr_rst,
    input logic wr_en,
    input logic full,
    output logic [ADDR_WIDTH:0] b_wr_ptr,     //using addr_width + 1 to handle full logic
    output logic [ADDR_WIDTH:0] gr_wr_ptr
    );

always_ff @(posedge wr_clk or negedge wr_rst) begin
    if (!wr_rst) begin
        b_wr_ptr <= 0;
    end
    else if (wr_en && !full) begin              //logical operator used for comparing than arithmetic which multiplies
        b_wr_ptr <= b_wr_ptr + 1;
    end
end
assign gr_wr_ptr = (b_wr_ptr >> 1) ^ b_wr_ptr;          //converting to btog using right shift and XOR operations
endmodule
