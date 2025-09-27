`timescale 1ns / 1ps

module main_controller (
    input        clk,
    input        rst,
    input  [3:0] i_sw,
    input        rx_done,
    input  [7:0] rx_data,
     input [1:0] s_state,
    output [3:0] o_sw,
    output [3:0] o_uart_btn_watch,
    output [3:0] o_uart_btn_stopwatch,
    output [3:0] o_uart_btn_super_sonic,
    output [3:0] o_uart_btn_dht11,
    output       o_uart_reset
);

    wire [3:0] w_sw;
    wire w_reset;

    assign o_uart_reset = w_reset;
    assign o_sw = w_sw;

    sw_select_controller U_SW_SEL_CNTL (  //sw select
        .clk(clk),
        .rst(rst),
        .i_sw(i_sw),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .o_sw(w_sw),
        .o_reset(w_reset)
    );

    watch_lut U_WATCH_LUT (  //watch btn
        .clk(clk),
        .rst(rst | w_reset),
        .sel(w_sw[1:0] == 2'b00),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .o_uart_btn_signal(o_uart_btn_watch)
    );

    stop_watch_lut U_STOPWATCH_LUT (  //stopwatch btn
        .clk(clk),
        .rst(rst | w_reset),
        .sel(w_sw[1:0] == 2'b01),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .s_state(s_state),
        .o_uart_btn_signal(o_uart_btn_stopwatch)
    );

    super_sonic_lut U_SUPER_SONIC_LUT (  //super sonic btn
        .clk(clk),
        .rst(rst | w_reset),
        .start(w_sw[1:0] == 2'b10),
        .i_btn(),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .o_uart_btn_cntl(o_uart_btn_super_sonic)
    );

    dht11_lut U_DHT11_LUT (  //dht11 btn
        .clk(clk),
        .rst(rst | w_reset),
        .sel(w_sw[1:0] == 2'b11),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .start_pulse(o_uart_btn_dht11)
    );

endmodule