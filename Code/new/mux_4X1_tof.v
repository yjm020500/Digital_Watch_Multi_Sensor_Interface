`timescale 1ns / 1ps

module mux_4X1_tof (
    input  [1:0] sel,                // 모드 선택: 00, 01, 10, 11

    input  [23:0] watch_bcd,         // 00
    input  [23:0] stopwatch_bcd,     // 01

    input  [9:0] dist,               // 10: 거리 (sr04)
    input  [7:0] rh_data,            // 11: 습도 (dht11)
    input  [7:0] t_data,             // 11: 온도 (dht11)

    output reg [23:0] m_to_fnd_bcd
);

    always @(*) begin
        case (sel)
            2'b00: m_to_fnd_bcd = watch_bcd;
            2'b01: m_to_fnd_bcd = stopwatch_bcd;
            2'b10: m_to_fnd_bcd = {14'd0, dist};               // sr04 거리 확장
            2'b11: m_to_fnd_bcd = {8'd0, rh_data, t_data};     // dht11 온습도 결합
            default: m_to_fnd_bcd = 24'h000000;
        endcase
    end

endmodule
