`timescale 1ns / 1ps

module super_sonic_lut (
    input        clk,
    input        rst,
    input        start,         
    input        i_btn,         
    input  [7:0] rx_data,
    input        rx_done,       

    output reg [3:0] o_uart_btn_cntl  // 4비트로 확장
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_uart_btn_cntl <= 4'b0000;
        end else if (rx_done && start) begin
            case (rx_data)
                8'h55: o_uart_btn_cntl <= 4'b1000; // 'U'
            endcase
        end else begin
            o_uart_btn_cntl <= 4'b0000;
        end
    end

endmodule

