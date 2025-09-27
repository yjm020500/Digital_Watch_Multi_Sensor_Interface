`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 14:34:28
// Design Name: 
// Module Name: start_trigger
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


module start_trigger (
    input clk,
    input rst,
    input i_tick,
    input btn_trig,

    output o_sr04_trig
);

    reg start_reg, start_next;
    reg sr04_trig_reg, sr04_trig_next;
    reg [3:0] cnt_reg, cnt_next;

    assign o_sr04_trig = sr04_trig_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            sr04_trig_reg <= 0;
            cnt_reg <= 0;
        end else begin
            start_reg <= start_next;
            sr04_trig_reg <= sr04_trig_next;
            cnt_reg <= cnt_next;
        end
    end

    always @(*) begin
        start_next = start_reg;
        cnt_next = cnt_reg;
        sr04_trig_next = sr04_trig_reg;
        case (start_reg)
            1'b0: begin
                cnt_next = 0;
                sr04_trig_next = 1'b0;
                if (btn_trig) begin
                    start_next = 1'b1;
                end
            end
            1'b1: begin
                if (i_tick) begin
                    sr04_trig_next = 1'b1;
                    cnt_next = cnt_reg + 1;
                    if (cnt_reg == 10) begin
                        start_next = 0;
                    end
                end
            end
        endcase
    end
endmodule
