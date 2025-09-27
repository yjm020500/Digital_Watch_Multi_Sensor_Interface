`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 17:23:31
// Design Name: 
// Module Name: top
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


module top (
    input clk,
    input rst,
    input [3:0] i_sw,
    input [3:0] i_btn,
    input echo,
    input rx,

    output       sr04_trig,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [3:0] led,        //보드: led[15] == 코드: led[3]
    output       tx,

    inout dht11_io
);

    wire w_uart_rst;
    wire [3:0] o_debounce_btn;

    //uart signal
    wire w_rx_done;
    wire [7:0] w_rx_data;

    // UART BTN SIGNAL
    wire [3:0] w_uart_btn_watch , w_uart_btn_stopwatch, w_uart_btn_super_sonic, w_uart_btn_dht11;

    //MAIN CTRL SWITCH
    wire [3:0] w_o_sw;

    // DHT11 VALID SIGNAL
    wire w_dht11_valid;

    // SELECTED BTN
    wire [3:0] w_o_btn_watch, w_o_btn_stopwatch, w_o_btn_super_sonic, w_o_btn_dht11;
    wire [1:0] w_s_state;

    // FND로 넘어가는 Data
    wire [23:0] w_o_watch_data, w_o_stopwatch_data;
    wire [9:0] w_dist_data;
    wire [7:0] w_rh_data;
    wire [7:0] w_temperature_data;
    wire [23:0] w_mux_to_fnd_data;

    // System Reset
    wire sys_rst;
    assign sys_rst = (rst | w_uart_rst);

    // Led Indicator
    assign led[1:0] = w_o_sw[1:0];
    assign led[2] = (w_o_sw[1:0] == 2'b11) ? w_dht11_valid :
                    ((w_o_sw[1:0] == 2'b00) || (w_o_sw[1:0] == 2'b01) ) ? w_o_sw[2] : 1'b0;
    assign led[3] = w_o_sw[3];


    btn_debouncing U_BTN_DEBOUNCE (
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn),
        .o_debounced_btn(o_debounce_btn)
    );

    uart U_UART (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .dht11_valid(w_dht11_valid),
        .i_watch_data(w_o_watch_data),
        .i_stopwatch_data(w_o_stopwatch_data),
        .i_super_sonic_data(w_dist_data),
        .i_dht11_data({
            w_temperature_data, w_rh_data
        }),  //t,rh순으로 묶어서 입력
        .tx(tx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    main_controller U_MAIN_CU (
        .clk(clk),
        .rst(rst),
        .i_sw(i_sw),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data),
        .s_state(w_s_state),
        .o_sw(w_o_sw),
        .o_uart_btn_watch(w_uart_btn_watch),
        .o_uart_btn_stopwatch(w_uart_btn_stopwatch),
        .o_uart_btn_super_sonic(w_uart_btn_super_sonic),
        .o_uart_btn_dht11(w_uart_btn_dht11),
        .o_uart_reset(w_uart_rst)
    );

    btn_hw_sel U_BTN_SEL (
        .i_btn(o_debounce_btn),
        .i_btn_uart_watch(w_uart_btn_watch),
        .i_btn_uart_stopwatch(w_uart_btn_stopwatch),
        .i_btn_uart_sr04(w_uart_btn_super_sonic),
        .i_btn_uart_dht11(w_uart_btn_dht11),
        .sw_sel(w_o_sw[1:0]),

        .o_btn_watch(w_o_btn_watch),
        .o_btn_stopwatch(w_o_btn_stopwatch),
        .o_btn_sr04(w_o_btn_super_sonic),
        .o_btn_dht11(w_o_btn_dht11)
    );

    Top_watch U_WATCH (
        .clk(clk),
        .rst(sys_rst),
        .i_watch_btn(w_o_btn_watch),
        .i_stopwatch_btn(w_o_btn_stopwatch),
        .i_sw(w_o_sw[3]),

        .o_watch_data(w_o_watch_data),
        .o_stopwatch_data(w_o_stopwatch_data),
        .s_state(w_s_state)
    );

    // top_sr04 U_SR04_TOP (
    //     .clk(clk),
    //     .rst(sys_rst),
    //     .Btn_start(w_o_btn_super_sonic[3]),
    //     .echo(echo),
    //     .trig(sr04_trig),
    //     .led(),
    //     .distance(w_dist_data)  // ⭕ 거리 데이터 출력
    // );

    sr04_ctrl U_SR04_TOP (
        .clk  (clk),
        .rst  (sys_rst),
        .start(w_o_btn_super_sonic[3]),
        .echo (echo),

        .trig(sr04_trig),
        .distance(w_dist_data),
        .dist_done()
    );

    dht11_controller U_DHT11_TOP (
        .clk(clk),
        .rst(sys_rst),
        .start(w_o_btn_dht11[3]),
        .en(w_o_sw[3]),
        .rh_data(w_rh_data),
        .t_data(w_temperature_data),
        .dht11_done(),
        .dht11_valid(w_dht11_valid),  //checksum
        .dht11_io(dht11_io)
    );

    mux_4X1_tof U_MUX_4X1 (
        .sel(w_o_sw[1:0]),  // 모드 선택: 00, 01, 10, 11

        .watch_bcd    (w_o_watch_data),     // 00
        .stopwatch_bcd(w_o_stopwatch_data), // 01

        .dist   (w_dist_data),  // 10: 거리 (sr04)
        .rh_data(w_rh_data),  // 11: 습도 (dht11)
        .t_data (w_temperature_data),  // 11: 온도 (dht11)

        .m_to_fnd_bcd(w_mux_to_fnd_data)
    );

    fnd_controller U_FND_CU (
        .clk(clk),
        .reset(sys_rst),
        .disp_data(w_mux_to_fnd_data),
        .hw_sel(w_o_sw[1:0]),
        .disp_sel(w_o_sw[2]),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
