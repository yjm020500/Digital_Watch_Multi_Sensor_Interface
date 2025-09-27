`timescale 1ns / 1ps


module stopwatch_cu (
    input clk,
    input rst,
    input i_clear,
    input i_runstop,
    output o_clear,
    output o_runstop,
    output [1:0] o_s_state
);

    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] c_state, n_state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= STOP;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP: begin
                if (i_runstop) begin
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end else begin
                    n_state = c_state;
                end
            end
            RUN: begin
                if (i_runstop) begin
                    n_state = STOP;
                end else begin
                    n_state = c_state;
                end
            end
            CLEAR: begin
                if (i_clear) begin
                    n_state = STOP;
                end else begin
                    n_state = c_state;
                end
            end
        endcase
    end

    assign o_clear   = (c_state == CLEAR) ? 1 : 0;
    assign o_runstop = (c_state == RUN) ? 1 : 0;
    assign o_s_state = c_state;

endmodule
