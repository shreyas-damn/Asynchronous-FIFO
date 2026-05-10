`timescale 1ns/1ps
module async_fifo_tb();
parameter ADDR_WIDTH = 4;
parameter DATA_WIDTH = 9;
parameter DEPTH = (1 << ADDR_WIDTH);

//port declaration
logic wr_clk, rd_clk;
logic wr_rst_n, rd_rst_n;
logic wr_en, rd_en;
logic [DATA_WIDTH-1:0] din;
logic [DATA_WIDTH-1:0] dout;
logic full, empty;
logic [DATA_WIDTH-1:0] data;

//Device Instantiation
async_fifo #(ADDR_WIDTH, DATA_WIDTH) dut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_rst(wr_rst_n),
    .rd_rst_n(rd_rst_n),
    .d_in(din),
    .d_out(dout),
    .full(full),
    .empty(empty)
);

initial wr_clk = 0;
always #10 wr_clk = ~wr_clk;

initial rd_clk = 0;
always #15 rd_clk = ~rd_clk;

//Creating a task to reset the fifo
task reset_fifo();
begin
    wr_rst_n = 0;
    rd_rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    repeat (3) @(posedge wr_clk);
    wr_rst_n = 1;
    repeat(3) @(posedge rd_clk);
    rd_rst_n = 1;
end
endtask

//Creating a task to write into the fifo
task write_fifo(input [DATA_WIDTH-1:0] data);
begin
    @(posedge wr_clk);
        if(!full) begin
            wr_en = 1;
            din = data;
        end
        else begin
            wr_en = 0;
        end
    @(posedge wr_clk);
        wr_en = 0;
end
endtask

//Creating a task to read from the fifo
task read_fifo(output logic [DATA_WIDTH-1:0] data);
begin
    @(posedge rd_clk);
        if (!empty) begin
            rd_en = 1;
        end
        else begin
            rd_en = 0;
        end
    @(posedge rd_clk);
        data = dout;
        rd_en = 0;  
end
endtask

//Creating a task to test the full conditions
task test_full();
begin
    int i;
    //Fills the fifo exactly till full
    for (i = 0; i < DEPTH; i = i+1) begin
        write_fifo(i);
    end
    //checking full flag working
    if (!full) begin
        $display("Full flag not working as expected");
    end
    else begin
        $display("Full flag working as expected");
    end
    //Overflow state
    //2^ADDR_WIDTH  = 16, and DATA_WIDTH = 9 bits
    write_fifo(999);
end
endtask

//Creating a task to read_all
task readall();
    logic [DATA_WIDTH-1:0] data;
    begin
        while (!empty) begin
            read_fifo(data);
        end
    end
endtask

initial begin
    $dumpfile("sim/async_fifo/async_fifo.vcd");
    $dumpvars(0,async_fifo_tb);
    //intializing signals
    wr_en = 0;
    rd_en = 0;
    din = 0;
    //reset
    reset_fifo();
    //writing
    write_fifo(9'd1);
    write_fifo(9'd2);
    write_fifo(9'd3);
    write_fifo(9'd4);
    write_fifo(9'd5);
    write_fifo(9'd6);
    //reading
    read_fifo(data);
    read_fifo(data);
    read_fifo(data);
    read_fifo(data);
    read_fifo(data);
    read_fifo(data);
    //
    reset_fifo();
    //Testin full logic
    test_full();
    //Read all
    readall();
    $finish;
end
endmodule
