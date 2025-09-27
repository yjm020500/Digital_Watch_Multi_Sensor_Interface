`timescale 1ns / 1ps

module btn_hw_sel (
	input [3:0] i_btn,
	input [3:0] i_btn_uart_watch,
	input [3:0] i_btn_uart_stopwatch,
	input [3:0] i_btn_uart_sr04,
	input [3:0] i_btn_uart_dht11,
	input [1:0] sw_sel,

	output [3:0] o_btn_watch,
	output [3:0] o_btn_stopwatch,
	output [3:0] o_btn_sr04,
	output [3:0] o_btn_dht11
);
	
	assign o_btn_watch = (sw_sel == 2'b00) ? (i_btn | i_btn_uart_watch) : 4'bzzzz;
	assign o_btn_stopwatch = (sw_sel == 2'b01) ? (i_btn | i_btn_uart_stopwatch) : 4'bzzzz;
	assign o_btn_sr04 = (sw_sel == 2'b10) ? (i_btn | i_btn_uart_sr04) : 4'bzzzz;
	assign o_btn_dht11 = (sw_sel == 2'b11) ? (i_btn | i_btn_uart_dht11) : 4'bzzzz;
	
endmodule