`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 15:04:23
// Design Name: 
// Module Name: distance_calculator
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


module distance_calculator (
    input clk,
    input rst,
    input i_tick,
    input echo,

    output [9:0] distance,
    output done
);

    reg start_reg, start_next;
    reg done_reg, done_next;
    reg [15:0] cnt_reg, cnt_next;
    reg [9:0] distance_reg, distance_next;

    assign distance = distance_reg;
    assign done = done_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            done_reg <= 0;
            cnt_reg <= 0;
            distance_reg <= 0;
        end else begin
            start_reg <= start_next;
            done_reg <= done_next;
            cnt_reg <= cnt_next;
            distance_reg <= distance_next;
        end
    end

    always @(*) begin
        start_next = start_reg;
        done_next = done_reg;
        cnt_next = cnt_reg;
        distance_next = distance_reg;
        case (start_reg)
            1'b0: begin
                done_next = 0;
                if (echo) begin
                    start_next = 1;
                    cnt_next = 0;
                    distance_next = 0;
                end
            end
            1'b1: begin
                if (i_tick) begin
                    if (!echo) begin
                        done_next  = 1;
                        start_next = 0;
                    end else begin
                        cnt_next = cnt_reg + 1;
                        if (cnt_next == 58) begin
                            distance_next = distance_reg + 1;
                            cnt_next = 0;
                        end
                    end
                end
            end
        endcase
    end
endmodule
