`timescale 1ns / 1ps

module watch_cu (
    input        clk,
    input        rst,
    input        i_select,
    input  [1:0] i_btn,
    output       o_sec,
    output       o_min,
    output       o_hour
);

    parameter RUN = 2'b00, SELECT_SEC = 2'b01, SELECT_MIN = 2'b10, SELECT_HOUR = 2'b11;

    reg [1:0] c_state, n_state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= RUN;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            RUN: begin
                if (i_select) begin
                    n_state = SELECT_SEC;
                end else begin
                    n_state = c_state;
                end
            end
            SELECT_SEC: begin
                if (!i_select) begin
                    n_state = RUN;
                end else if (i_btn == 2'b10) begin  //left
                    n_state = SELECT_MIN;
                end else if (i_btn == 2'b01) begin  //right
                    n_state = SELECT_HOUR;
                end else begin
                    n_state = c_state;
                end
            end
            SELECT_MIN: begin
                if (!i_select) begin
                    n_state = RUN;
                end else if (i_btn == 2'b10) begin  //left
                    n_state = SELECT_HOUR;
                end else if (i_btn == 2'b01) begin  //right
                    n_state = SELECT_SEC;
                end else begin
                    n_state = c_state;
                end
            end
            SELECT_HOUR: begin
                if (!i_select) begin
                    n_state = RUN;
                end else if (i_btn == 2'b10) begin  //left
                    n_state = SELECT_SEC;
                end else if (i_btn == 2'b01) begin  //right
                    n_state = SELECT_MIN;
                end else begin
                    n_state = c_state;
                end
            end
        endcase
    end

    assign o_sec  = (c_state == SELECT_SEC) ? 1 : 0;
    assign o_min  = (c_state == SELECT_MIN) ? 1 : 0;
    assign o_hour = (c_state == SELECT_HOUR) ? 1 : 0;

endmodule
