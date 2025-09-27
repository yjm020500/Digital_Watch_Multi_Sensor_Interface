`timescale 1ns / 1ps
/*
//assign 사용
module baudrate (
    input  clk,
    input  rst,
    output baud_tick
);

    //clk = 100Mhz
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000 / BAUD;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg;
    wire [$clog2(BAUD_COUNT)-1:0] count_next;

    assign count_next = (count_reg == BAUD_COUNT - 1) ? 0 : count_reg + 1;
    assign baud_tick = (count_reg == BAUD_COUNT - 1) ? 1'b1: 1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= 0;
        end else begin
            count_reg <= count_next;
        end
    end

endmodule
*/

//always 사용
module baudrate (
    input  clk,
    input  rst,
    output baud_tick
);

    //clk = 100Mhz
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000 / (BAUD * 8); //100_000_000
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg baud_tick_reg, baud_tick_next;

    assign baud_tick = baud_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= 0;
            baud_tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            baud_tick_reg <= baud_tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        baud_tick_next = 0; //baud_tick_reg도 상관 없다
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            baud_tick_next = 1'b1;
        end
        else begin
            count_next = count_reg + 1;
            baud_tick_next = 1'b0;
        end
    end

endmodule
