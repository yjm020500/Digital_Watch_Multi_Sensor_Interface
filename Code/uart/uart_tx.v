`timescale 1ns / 1ps

module uart_tx (
    input        clk,
    input        rst,
    input        baud_tick,
    input        start,
    input  [7:0] din,
    output       o_tx_done,
    output       o_tx_busy,
    output       o_tx
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [3:0] c_state, n_state;
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next;
    reg [3:0] b_cnt_reg, b_cnt_next;
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;
    reg [7:0] tx_din_reg, tx_din_next;

    assign o_tx = tx_reg;

    assign o_tx_busy = tx_busy_reg;

    //assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7))? 1'b1 : 1'b0;
    assign o_tx_done = tx_done_reg;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= 0;
            tx_reg       <= 1'b1;
            data_cnt_reg <= 0;  //data bit 전송 반복 구조를 위해서
            b_cnt_reg    <= 0;  //baud tick을 0부터 7까지 count
            tx_done_reg <= 1'b0;
            tx_busy_reg <= 1'b0;
            tx_din_reg <= 0;
        end else begin
            c_state      <= n_state;
            tx_reg       <= tx_next;
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg    <= b_cnt_next;
            tx_done_reg <= tx_done_next;
            tx_busy_reg <= tx_busy_next;
            tx_din_reg <= tx_din_next;
        end
    end

    //next state CL
    //먼저 state가 바뀌고 tick을 기다리는 구조
    //또는 변수 하나 더 둬서(start_flag)와 tcik을 비교
    always @(*) begin
        n_state = c_state;
        tx_next = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next = b_cnt_reg;
        tx_done_next = 1'b0;
        tx_busy_next = tx_busy_reg;
        tx_din_next = tx_din_reg;
        case (c_state)
            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start == 1'b1) begin
                    n_state = START;
                    tx_busy_next = 1'b1;
                    tx_din_next = din;
                end
            end
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    if (b_cnt_reg == 4'h8) begin //tick이 들어가면서 tx_값이 바뀌니까 8까지 세야 간격이 맞음
                        n_state = DATA;
                        data_cnt_next = 0;
                        b_cnt_next = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = tx_din_reg[data_cnt_reg];
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 4'h7) begin
                        if (data_cnt_reg == 3'h7) begin
                            n_state = STOP;
                        end
                        data_cnt_next = data_cnt_reg + 1;
                        b_cnt_next = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 4'h7) begin
                        n_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end
                    else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
