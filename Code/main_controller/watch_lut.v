`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 12:03:35
// Design Name: 
// Module Name: watch_lut
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


module watch_lut (
    input clk,
    input rst,
    input sel,
    input [7:0] rx_data,
    input rx_done,

    output reg [3:0] o_uart_btn_signal
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_uart_btn_signal <= 0;
        end else if(rx_done && sel)begin
            case (rx_data)
            8'h55: o_uart_btn_signal <= 4'b1000;  // U
            8'h44: o_uart_btn_signal <= 4'b0100;  // D
            8'h4C: o_uart_btn_signal <= 4'b0010;  // L
            8'h52: o_uart_btn_signal <= 4'b0001;  // R
        endcase
        end
        else begin
            o_uart_btn_signal <= 0;
        end
    end

endmodule
