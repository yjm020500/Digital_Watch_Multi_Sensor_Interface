`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 12:35:30
// Design Name: 
// Module Name: stop_watch_lut
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


module stop_watch_lut (
    input clk,
    input rst,
    input sel,
    input [7:0] rx_data,
    input rx_done,
    input [1:0] s_state,

    output reg [3:0] o_uart_btn_signal
);

    parameter STOP = 2'b00, RUN = 2'b01;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_uart_btn_signal <= 0;
        end else if (rx_done && sel) begin
            case (rx_data)
                8'h47:
                if (s_state == STOP) o_uart_btn_signal <= 4'b0001;  // G
                8'h53:
                if (s_state == RUN) o_uart_btn_signal <= 4'b0001;  // S
                8'h43: o_uart_btn_signal <= 4'b0010;  // C
            endcase
        end
        else begin
            o_uart_btn_signal <= 0;
        end
    end


endmodule
