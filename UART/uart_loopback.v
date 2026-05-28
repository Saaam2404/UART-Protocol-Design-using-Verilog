module uart_loopback(

    input clk,
    input rst,
    input load,
    input [7:0] tx_data,
    output tx,
    output [7:0] rx_data,
    output busy

);

wire serial_line;

// UART TX
uart_tx transmitter(
    .clk(clk),
    .rst(rst),
    .load(load),
    .data(tx_data),
    .tx(serial_line),
    .busy(busy)
);

// UART RX
uart_rx receiver(
    .clk(clk),
    .rst(rst),
    .rx(serial_line),
    .data(rx_data)
);

// Optional external observation
assign tx = serial_line;

endmodule