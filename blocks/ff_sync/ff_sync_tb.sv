`timescale 1ns / 1ps
module ff_sync_tb();
parameter  WIDTH = 4;
logic clk;
logic rst_n;
logic [WIDTH-1:0]din;
logic [WIDTH-1:0]dout;

ff_sync #(.WIDTH(WIDTH))UUT(
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .dout(dout)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;
    din = 0;

    #10 rst_n = 1;

    #10 din = 4'b0001;
    #40 din = 4'b0011;
    #40 din = 4'b1010;
    #40 din = 4'b0101;

    $finish;
end

endmodule
