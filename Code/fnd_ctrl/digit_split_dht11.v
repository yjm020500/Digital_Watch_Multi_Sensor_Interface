`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 14:05:15
// Design Name: 
// Module Name: digit_split_dht11
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


module digit_split_dht11 (
    input [15:0] dht11_data,

    output [3:0] t_digit_1,
    output [3:0] t_digit_10,
    output [3:0] rh_digit_1,
    output [3:0] rh_digit_10
);

    assign rh_digit_1 = (dht11_data[15:8] % 10);
    assign rh_digit_10 = (dht11_data[15:8] / 10);
    assign t_digit_1 = (dht11_data[7:0] % 10);
    assign t_digit_10 = (dht11_data[7:0] / 10);
endmodule
