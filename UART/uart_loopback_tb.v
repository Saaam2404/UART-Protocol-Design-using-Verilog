`timescale 1ns / 1ps

module uart_loopback_tb;

reg clk;
reg rst;
reg load;
reg [7:0] tx_data;

wire tx;
wire [7:0] rx_data;
wire busy;

// Instantiate loopback module
uart_loopback uut(
    .clk(clk),
    .rst(rst),
    .load(load),
    .tx_data(tx_data),
    .tx(tx),
    .rx_data(rx_data),
    .busy(busy)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Dump waves
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, uart_loopback_tb);
end

initial begin

    // Initial values
    rst = 1;
    load = 0;
    tx_data = 8'b00000000;

    #20;
    rst = 0;

    // =====================================
    // FIRST TRANSMISSION
    // =====================================

    #20;

    tx_data = 8'b10110010;
    load = 1;

    #10;
    load = 0;

    // Wait until TX actually starts
    wait(busy == 1);

    // Wait until TX completes
    wait(busy == 0);

    // Give RX some extra cycles
    #300;

    $display("Received Data 1 = %b", rx_data);

    // =====================================
    // SECOND TRANSMISSION
    // =====================================

    #100;

    tx_data = 8'b11001100;
    load = 1;

    #10;
    load = 0;

    wait(busy == 1);
    wait(busy == 0);

    #300;

    $display("Received Data 2 = %b", rx_data);

    #200;

    $finish;

end

// Monitor signals
initial begin
    $monitor(
    "t=%0t tx=%b busy=%b rx_data=%b tx_state=%b rx_state=%b",
    $time,
    tx,
    busy,
    rx_data,
    uut.transmitter.states,
    uut.receiver.states
    );
end

endmodule