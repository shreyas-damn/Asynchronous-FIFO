`timescale 1ns / 1ps
module ff_sync #(parameter WIDTH = 4)(
    input logic clk,
    input logic rst_n,      //active low reset (resets when rst_n_n is 0)
    input logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);
logic [WIDTH-1:0]q1;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q1 <= 0;
    end
    else begin
        q1 <= din;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dout <= 0;
    end
    else begin
        dout <= q1;
    end
end
endmodule
