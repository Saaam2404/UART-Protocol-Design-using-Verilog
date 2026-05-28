`timescale 1ns / 1ps

module uart_tx_tb;

reg clk;
reg rst;
reg load;
reg [7:0] data;

wire tx;

uart_tx uut(
    .clk(clk),
    .rst(rst),
    .load(load),
    .data(data),
    .tx(tx)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// VCD dump
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, uart_tx_tb);
end

initial begin

    // Initial values
    rst = 1;
    load = 0;
    data = 8'b0;

    #20;
    rst = 0;

    // -------------------------
    // Transmit first byte
    // 10110010
    // -------------------------

    #20;

    data = 8'b10110010;
    load = 1;

    #10;
    load = 0;

    // Wait enough time for transmission
    #2000;

    // -------------------------
    // Transmit second byte
    // 11001100
    // -------------------------

    data = 8'b11001100;
    load = 1;

    #10;
    load = 0;

    #2000;

    $finish;
end

// Monitor
always @(posedge clk) begin
    if(uut.tick == 0) begin
        $display(
        "t=%0t tx=%b bit=%d",
        $time,
        tx,
        uut.bit_count
        );
    end
end

endmodule