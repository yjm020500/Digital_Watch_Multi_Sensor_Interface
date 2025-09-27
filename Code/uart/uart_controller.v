`timescale 1ns / 1ps

module uart_controller (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_din,
    input        rx,
    output       rx_done,
    output       tx_done,
    output       tx_busy,
    output [7:0] rx_data,
    output       tx
);

    wire w_baud_tick, w_start, w_rx_done;
    wire [7:0] w_dout;

    assign rx_done = w_rx_done;
    assign rx_data = w_dout;

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_baud_tick),
        .rx(rx),
        .o_dout(w_dout),
        .o_rx_done(w_rx_done)
    );

    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_baud_tick)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_baud_tick),
        .start(tx_start),
        .din(tx_din),
        .o_tx_done(tx_done),
        .o_tx_busy(tx_busy),
        .o_tx(tx)
    );

endmodule
