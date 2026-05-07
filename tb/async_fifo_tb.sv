`timescale 1ns / 1ps

module async_fifo_tb;

    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 9;
    parameter DEPTH = (1 << ADDR_WIDTH);

    logic wr_clk, rd_clk;
    logic wr_rst, rd_rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] d_in;
    logic [DATA_WIDTH-1:0] d_out;
    logic full, empty;

    // DUT
    async_fifo #(ADDR_WIDTH, DATA_WIDTH) dut (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .d_in(d_in),

        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .d_out(d_out),

        .full(full),
        .empty(empty)
    );

    // clocks
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;

    initial rd_clk = 0;
    always #8 rd_clk = ~rd_clk;

    // scoreboard
    logic [DATA_WIDTH-1:0] exp_queue[$];

    // reset
    initial begin
        wr_rst = 0;
        rd_rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        d_in = 0;

        #30;
        wr_rst = 1;
        rd_rst_n = 1;
    end

    // ---------------- WRITE TASK ----------------
    task automatic write(input int n);
        int i;
        for (i = 0; i < n; i++) begin
            @(posedge wr_clk);

            wr_en = 1;
            d_in  = $urandom_range(0, 255);

            if (!full)
                exp_queue.push_back(d_in);
        end

        @(posedge wr_clk);
        wr_en = 0;
    endtask

    // ---------------- READ TASK (FIXED) ----------------
    task automatic read_all();
        logic [DATA_WIDTH-1:0] exp;

        while (exp_queue.size() > 0) begin
            @(posedge rd_clk);

            if (!empty) begin
                rd_en = 1;

                @(posedge rd_clk); // allow FIFO output to settle
                rd_en = 0;

                exp = exp_queue.pop_front();

                if (d_out !== exp) begin
                    $display("❌ ERROR: exp=%0d got=%0d time=%0t",
                              exp, d_out, $time);
                    $stop;
                end
            end
            else begin
                rd_en = 0;
            end
        end
    endtask

    // ---------------- DRAIN (CDC SAFE) ----------------
    task automatic drain_fifo();
        repeat (20) @(posedge rd_clk);
    endtask

    // ---------------- MAIN TEST ----------------
    initial begin
        wait(wr_rst && rd_rst_n);

        $display("---- TEST 1: SIMPLE BURST ----");
        write(5);
        read_all();

        $display("---- TEST 2: OVERFLOW STRESS ----");
        write(DEPTH + 5);
        read_all();

        $display("---- TEST 3: RANDOM STRESS ----");
        repeat (50) begin
            fork
                begin
                    @(posedge wr_clk);
                    wr_en = $urandom_range(0,1);
                    d_in  = $urandom;

                    if (wr_en && !full)
                        exp_queue.push_back(d_in);
                end

                begin
                    @(posedge rd_clk);
                    rd_en = $urandom_range(0,1);
                end
            join
        end

        drain_fifo();
        read_all();

        $display("✅ FIFO TEST PASSED");
        $finish;
    end

endmodule