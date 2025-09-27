`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 12:34:04
// Design Name: 
// Module Name: tick_gen
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


module tick_gen(
    input clk,
    input rst,

    output o_tick_1mhz
    );

    parameter SYS_CLK = 100_000_000;
    parameter OBJ_CLK = 1000_000;
    parameter TCNT = SYS_CLK / OBJ_CLK;

    reg [($clog2(TCNT)) - 1 : 0] cnt_reg, cnt_next;
    reg tick_reg, tick_next;

    assign o_tick_1mhz = tick_reg;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_reg <= 0;
            tick_reg <= 0;
        end
        else begin
            cnt_reg <= cnt_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        if(cnt_reg == (TCNT - 1)) begin
            cnt_next = 0;
            tick_next = 1'b1;
        end
        else begin
            cnt_next = cnt_reg + 1'b1;
            tick_next = 0;
        end
    end
    
endmodule