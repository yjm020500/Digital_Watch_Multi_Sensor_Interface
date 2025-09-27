`timescale 1ns / 1ps

module sw_select_controller (
    input        clk,
    input        rst,
    input  [3:0] i_sw,
    input        rx_done,
    input  [7:0] rx_data,
    output [3:0] o_sw,
    output       o_reset
);

    reg [3:0] r_sw, r_sw_next;
    reg [3:0] prev_sw;
    reg r_reset_reg, r_reset_next;

    assign o_sw = r_sw;
    assign o_reset = r_reset_reg;

    always @(posedge clk, posedge rst) begin
        if (rst || r_reset_reg) begin
            r_sw        <= 4'b0;
            prev_sw     <= 4'b0;
            r_reset_reg <= 1'b0;
        end else begin
            r_sw        <= r_sw_next;
            prev_sw     <= i_sw;
            r_reset_reg <= r_reset_next;
        end
    end

    always @(*) begin
        r_reset_next = 1'b0;
        r_sw_next    = r_sw;

        if (rx_done) begin
            case (rx_data)
                // toggle switches
                8'h4D: begin  // M: mode toggle sw0, 
                    r_sw_next = {r_sw[3:1], ~r_sw[0]};
                end
                8'h4E: begin  // N: mode toggle sw1
                    r_sw_next = {r_sw[3:2], ~r_sw[1], r_sw[0]};
                end
                8'h57: begin  // W : watch,stopwatch 일때 초/분 switching
                    r_sw_next = {r_sw[3], ~r_sw[2], r_sw[1:0]};
                end
                8'h45: begin  // E: toggle sw2
                    r_sw_next = {~r_sw[3], r_sw[2:0]};
                end

                // reset
                8'h1B: r_reset_next = 1'b1;  // ESC
            endcase
        end else begin
            // i_sw 변화 감지
            r_sw_next[0] = (i_sw[0] != prev_sw[0]) ? i_sw[0] : r_sw[0];
            r_sw_next[1] = (i_sw[1] != prev_sw[1]) ? i_sw[1] : r_sw[1];
            r_sw_next[2] = (i_sw[2] != prev_sw[2]) ? i_sw[2] : r_sw[2];
            r_sw_next[3] = (i_sw[3] != prev_sw[3]) ? i_sw[3] : r_sw[3];
        end
    end

endmodule
