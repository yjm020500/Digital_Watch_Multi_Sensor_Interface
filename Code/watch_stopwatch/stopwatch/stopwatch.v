`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        btnL_Clear,
    input        btnR_RunStop,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output [1:0] s_state
);

    wire w_clear, w_runstop;

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(btnL_Clear),
        .i_runstop(btnR_RunStop),
        .o_clear(w_clear),
        .o_runstop(w_runstop),
        .o_s_state(s_state)
    );

    stopwatch_dp U_StopWatch_DP (
        .clk(clk),
        .rst(rst),
        .clear(w_clear),
        .runstop(w_runstop),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

endmodule
