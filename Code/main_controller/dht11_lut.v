`timescale 1ns / 1ps

module dht11_lut (
    input            clk,
    input            rst,
    input            sel,         // SEL[3] == 1
    input      [7:0] rx_data,     // UART 수신 데이터
    input            rx_done,     // UART 수신 완료
    output reg [3:0] start_pulse  // [3]=U, [2]=D, [1]=L, [0]=R (1클럭 pulse)
);

    always @(posedge clk or posedge rst) begin
        if (rst) start_pulse <= 4'b0000;
        else if (rx_done && sel) begin
            case (rx_data)
                8'h55:   start_pulse <= 4'b1000;  // 'U'
            endcase
        end else start_pulse <= 4'b0000;  // 기본: 0 (1클럭 유지)
    end

endmodule
