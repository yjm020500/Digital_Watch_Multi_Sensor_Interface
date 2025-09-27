`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 14:25:32
// Design Name: 
// Module Name: sr04_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sr04_ctrl (
    input clk,
    input rst,
    input start,
    input echo,

    output trig,
    output [9:0] distance,
    output dist_done
);

    wire w_o_tick_1mhz;

    tick_gen U_TICK_GEN_1MHZ (
        .clk(clk),
        .rst(rst),

        .o_tick_1mhz(w_o_tick_1mhz)
    );

    start_trigger U_START_TRIG (
        .clk(clk),
        .rst(rst),
        .i_tick(w_o_tick_1mhz),
        .btn_trig(start),

        .o_sr04_trig(trig)
    );

    distance_calculator U_DIST_CAL (
        .clk(clk),
        .rst(rst),
        .i_tick(w_o_tick_1mhz),
        .echo(echo),

        .distance(distance),
        .done(dist_done)
    );

endmodule
