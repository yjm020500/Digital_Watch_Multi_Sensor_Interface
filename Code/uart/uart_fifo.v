`timescale 1ns / 1ps

module uart_fifo (
    input        clk,
    input        rst,
    input        rx,
    input        tx_push,
    input  [7:0] tx_push_data,
    output [7:0] rx_pop_data,
    output       rx_done,
    output       tx_full,
    output       tx_done,
    output       tx
);

    wire w_rx_done, w_tx_busy, w_tx_fifo_empty, w_rx_pop;
    wire [7:0] w_rx_data, w_tx_data;

    assign rx_done = ~w_rx_pop;

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .tx_start(~w_tx_fifo_empty),
        .tx_din(w_tx_data),
        .rx(rx),
        .rx_done(w_rx_done),
        .tx_done(tx_done),
        .tx_busy(w_tx_busy),
        .rx_data(w_rx_data),
        .tx(tx)
    );

    fifo U_FIFO_RX (
        .clk(clk),
        .rst(rst),
        .push(w_rx_done),
        .pop(~w_rx_pop),
        .push_data(w_rx_data),
        .full(),  //x
        .empty(w_rx_pop),
        .pop_data(rx_pop_data)
    );

    fifo U_FIFO_TX (
        .clk(clk),
        .rst(rst),
        .push(tx_push),
        .pop(~w_tx_busy),
        .push_data(tx_push_data),
        .full(tx_full),
        .empty(w_tx_fifo_empty),
        .pop_data(w_tx_data)
    );

endmodule
