`timescale 1ns / 1ps

module dht11_controller (
    input        clk,
    input        rst,
    input        start,
    input        en,
    output [7:0] rh_data,
    output [7:0] t_data,
    output       dht11_done,
    output       dht11_valid,  //checksum
    inout        dht11_io
);

    wire w_start;
    wire w_tick;

    tick_gen_10us U_Tick (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3, SYNCH = 4, 
                DATA_SYNC = 5, DATA_DETECT = 6, STOP = 7;

    reg [2 : 0] c_state, n_state;
    reg [$clog2(1900)-1 : 0] t_cnt_reg, t_cnt_next;
    reg dht11_reg, dht11_next;
    reg io_en_reg, io_en_next;
    reg [39:0] data_reg, data_next;
    reg valid_reg, valid_next;
    reg [5:0] data_cnt_reg, data_cnt_next;
    reg dht11_done_reg, dht11_done_next;

    assign w_start = (en && start) ? 1'b1 : 1'b0;

    assign dht11_io = (io_en_reg) ? dht11_reg : 1'bz;
    assign dht11_valid = valid_reg;
    assign dht11_done = dht11_done_reg;
    assign rh_data = data_reg[39:32];
    assign t_data = data_reg[23:16];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            t_cnt_reg <= 0;
            dht11_reg <= 1'b1;  //초기값 항상 high로
            io_en_reg <= 1'b1;  //idle에서 항상 출력 모드
            data_reg <= 0;
            valid_reg <= 1'b0;
            data_cnt_reg <= 0;
            dht11_done_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            t_cnt_reg <= t_cnt_next;
            dht11_reg <= dht11_next;
            io_en_reg <= io_en_next;
            data_reg <= data_next;
            valid_reg <= valid_next;
            data_cnt_reg <= data_cnt_next;
            dht11_done_reg <= dht11_done_next;
        end
    end

    always @(*) begin
        n_state    = c_state;
        t_cnt_next = t_cnt_reg;
        dht11_next = dht11_reg;
        io_en_next = io_en_reg;
        data_next  = data_reg;
        valid_next = valid_reg;
        data_cnt_next = data_cnt_reg;
        dht11_done_next = dht11_done_reg;
        case (c_state)
            IDLE: begin
                dht11_next = 1'b1;
                io_en_next = 1'b1;
                //valid_next = 1'b0; // tick
                dht11_done_next = 1'b0;
                if (w_start) begin
                    n_state = START;  //start로 보내고 tick 검사
                    valid_next = 1'b0;  // led check용
                end
            end
            START: begin
                if (w_tick) begin
                    dht11_next = 1'b0;
                    if (t_cnt_reg == 1900) begin
                        n_state = WAIT;
                        t_cnt_next = 0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                //출력 high
                dht11_next = 1'b1;
                if (w_tick) begin
                    if (t_cnt_reg == 2) begin
                        n_state = SYNCL;
                        t_cnt_next = 0;
                        //출력을을 입력으로 전환
                        io_en_next = 1'b0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
            SYNCL: begin
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = SYNCH;
                    end
                end
            end
            SYNCH: begin
                if (w_tick) begin
                    if (!dht11_io) begin
                        n_state = DATA_SYNC;
                    end
                end
            end
            DATA_SYNC: begin
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = DATA_DETECT;
                    end
                end
            end
            DATA_DETECT: begin  //각자, 1길이 count
                if (w_tick) begin
                    if (!dht11_io) begin
                        if (t_cnt_reg < 5) begin  //data 입력 0
                            data_next = {data_reg[38:0], 1'b0};
                        end else begin  //data 입력 1
                            data_next = {data_reg[38:0], 1'b1};
                        end

                        if (data_cnt_reg == 39) begin  //state 이동
                            data_cnt_next = 0;
                            n_state = STOP;
                            t_cnt_next = 0;
                        end else begin
                            data_cnt_next = data_cnt_reg + 1;
                            n_state = DATA_SYNC;
                            t_cnt_next = 0;
                        end
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
            STOP: begin  //각자
                if (w_tick) begin
                    if (t_cnt_reg == 4) begin
                        n_state = IDLE;
                        dht11_done_next = 1'b1;
                        valid_next = ((data_reg[39:32] + data_reg[31:24] +
                           data_reg[23:16] + data_reg[15:8]) == data_reg[7:0]);
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

module tick_gen_10us (
    input  clk,
    input  rst,
    output o_tick
);

    parameter F_COUNT = 1000;  //100khz

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg    <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                tick_reg    <= 1'b0;
            end
        end
    end

endmodule
