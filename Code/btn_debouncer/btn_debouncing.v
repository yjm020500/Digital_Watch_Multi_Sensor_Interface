`timescale 1ns / 1ps

module btn_debouncing (
    input clk,
    input rst,
    input [3:0] i_btn,
    output [3:0] o_debounced_btn
);

    btn_debounce U_BD_UP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn[3]),
        .o_btn(o_debounced_btn[3])
    );

    btn_debounce U_BD_DOWN (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn[2]),
        .o_btn(o_debounced_btn[2])
    );

    btn_debounce U_BD_LEFT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn[1]),
        .o_btn(o_debounced_btn[1])
    );

    btn_debounce U_BD_RIGHT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn[0]),
        .o_btn(o_debounced_btn[0])
    );

endmodule