`timescale 1ns / 1ps

module Top_watch (
    input         clk,
    input         rst,
    input  [ 3:0] i_watch_btn,
    input  [ 3:0] i_stopwatch_btn,
    input         i_sw,
    output [23:0] o_watch_data,
    output [23:0] o_stopwatch_data,
    output [ 1:0] s_state
);

    wire [6:0] w_stopwatch_msec, w_watch_msec;
    wire [5:0] w_stopwatch_sec, w_stopwatch_min, w_watch_sec, w_watch_min;
    wire [4:0] w_stopwatch_hour, w_watch_hour;
    wire [3:0] w_btn_watch, w_btn_stopwatch;

    assign w_btn_watch = i_watch_btn;
    assign w_btn_stopwatch = i_stopwatch_btn;
    assign o_watch_data = {
        (w_watch_hour), (w_watch_min), (w_watch_sec), (w_watch_msec)
    };
    assign o_stopwatch_data = {
        (w_stopwatch_hour),
        (w_stopwatch_min),
        (w_stopwatch_sec),
        (w_stopwatch_msec)
    };

    watch U_WATCH (
        .clk   (clk),
        .rst   (rst),
        .btn   (w_btn_watch),   //Up, Down, Left, Right
        .select(i_sw),
        .msec  (w_watch_msec),
        .sec   (w_watch_sec),
        .min   (w_watch_min),
        .hour  (w_watch_hour)
    );

    stopwatch U_STOPWATCH (
        .clk         (clk),
        .rst         (rst),
        .btnL_Clear  (w_btn_stopwatch[1]),
        .btnR_RunStop(w_btn_stopwatch[0]),
        .msec        (w_stopwatch_msec),
        .sec         (w_stopwatch_sec),
        .min         (w_stopwatch_min),
        .hour        (w_stopwatch_hour),
        .s_state     (s_state)
    );


endmodule
