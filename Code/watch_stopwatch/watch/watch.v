`timescale 1ns / 1ps

module watch (
    input        clk,
    input        rst,
    input  [3:0] btn,     //Up, Down, Left, Right
    input        select,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_sec, w_min, w_hour;

    watch_cu U_Watch_CU (
        .clk(clk),
        .rst(rst),
        .i_select(select),
        .i_btn(btn[1:0]),
        .o_sec(w_sec),
        .o_min(w_min),
        .o_hour(w_hour)
    );

    watch_dp U_Watch_DP (
        .clk(clk),
        .rst(rst),
        .i_sec(w_sec),
        .i_min(w_min),
        .i_hour(w_hour),
        .btn_updown(btn[3:2]),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

endmodule
