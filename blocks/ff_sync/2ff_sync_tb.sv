`timescale 1ps/1ps
module ff_sync_test();
parameter WIDTH = 4;
logic clk;
logic rst_n;
logic [WIDTH-1:0] din;
logic [WIDTH-1:0] dout;

ff_sync #(.WIDTH(WIDTH)) UUT (
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .dout(dout)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst_n = 0;
    din = 4'b0;
    $dumpfile("sim.vcd");
    $dumpvars(0,ff_sync_test);
    $monitor("Time = %t | clk = %b | rst_n = %b | din = %b | q1 = %b | dout = %b", $time, clk, rst_n, UUT.q1, din, dout);
    #12
    rst_n = 1;
    #3
    din = 4'b0001; #10
    din = 4'b0010; #10
    din = 4'b0011; #10
    din = 4'b0100; #10
    din = 4'b0101; #10
    din = 4'b0110; #10
    din = 4'b0111; #10
    #20 $finish;
end

endmodule