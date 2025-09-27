`timescale 1ns / 1ps
//no carry
/*
module watch_dp (
    input        clk,
    input        rst,
    input        i_sec,
    input        i_min,
    input        i_hour,
    input  [1:0] btn_updown,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    localparam NOSELECT = 0;

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick, w_day_tick;

    tick_gen_watch_100hz U_Watch_Tick_100hz (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    watch_time_counter #(
        .BIT_WIDTH  (7),
        .TICK_COUNT (100),
        .START_COUNT(0)
    ) U_MSEC_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(NOSELECT),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    watch_time_counter #(
        .BIT_WIDTH  (6),
        .TICK_COUNT (60),
        .START_COUNT(0)
    ) U_SEC_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_sec),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    watch_time_counter #(
        .BIT_WIDTH  (6),
        .TICK_COUNT (60),
        .START_COUNT(0)
    ) U_MIN_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_min),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    watch_time_counter #(
        .BIT_WIDTH  (5),
        .TICK_COUNT (24),
        .START_COUNT(12)
    ) U_HOUR_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_hour),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick(w_day_tick)
    );

endmodule


module tick_gen_watch_100hz (
    input clk,
    input rst,
    output reg o_tick_100
);

    parameter FCOUNT = 1_000_000;  //1_000_000

    reg [$clog2(FCOUNT)-1:0] r_counter;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1; //count값이 일치했을때 o_tick_100 상승
                r_counter <= 0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter + 1;
            end
        end
    end

endmodule

module watch_time_counter #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    START_COUNT = 0
) (
    input                  clk,
    input                  rst,
    input  [          1:0] i_up_down,
    input                  i_select,
    input                  i_tick,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg r_tick_reg, r_tick_next;

    assign o_time = count_reg;
    assign o_tick = r_tick_reg;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= START_COUNT;
            r_tick_reg <= 1'b0;
        end else begin
            count_reg  <= count_next;
            r_tick_reg <= r_tick_next;
        end
    end

    //next state
    always @(*) begin
        count_next  = count_reg;
        r_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next  = 0;
                r_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                r_tick_next = 1'b0;
            end
        end

        if (i_select) begin
            case (i_up_down)
                2'b10: begin  //up
                    if (count_reg == TICK_COUNT - 1) begin
                        count_next  = 0;
                        //r_tick_next = 1'b1;
                    end else begin
                        count_next  = count_reg + 1;
                        //r_tick_next = 1'b0;
                    end
                end
                2'b01: begin  //down
                    if (count_reg == 0) begin
                        count_next = TICK_COUNT - 1;
                        //r_tick_next = 1'b1;
                    end else begin
                        count_next = count_reg - 1;
                        //r_tick_next = 1'b0;
                    end
                end
            endcase
        end
    end

endmodule
*/

//carry, borrow
module watch_dp (
    input        clk,
    input        rst,
    input        i_sec,
    input        i_min,
    input        i_hour,
    input  [1:0] btn_updown,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    localparam NOSELECT = 0;

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick, w_day_tick;
    wire w_msec_borrow, w_sec_borrow, w_min_borrow, w_hour_borrow;

    tick_gen_watch_100hz U_Watch_Tick_100hz (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    watch_time_counter #(
        .BIT_WIDTH  (7),
        .TICK_COUNT (100),
        .START_COUNT(0)
    ) U_MSEC_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(NOSELECT),
        .i_tick(w_tick_100hz),
        .i_borrow(NOSELECT),
        .o_time(msec),
        .o_tick(w_sec_tick),
        .o_borrow(w_msec_borrow)
    );

    watch_time_counter #(
        .BIT_WIDTH  (6),
        .TICK_COUNT (60),
        .START_COUNT(0)
    ) U_SEC_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_sec),
        .i_tick(w_sec_tick),
        .i_borrow(w_msec_borrow),
        .o_time(sec),
        .o_tick(w_min_tick),
        .o_borrow(w_sec_borrow)
    );

    watch_time_counter #(
        .BIT_WIDTH  (6),
        .TICK_COUNT (60),
        .START_COUNT(0)
    ) U_MIN_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_min),
        .i_tick(w_min_tick),
        .i_borrow(w_sec_borrow),
        .o_time(min),
        .o_tick(w_hour_tick),
        .o_borrow(w_min_borrow)
    );

    watch_time_counter #(
        .BIT_WIDTH  (5),
        .TICK_COUNT (24),
        .START_COUNT(12)
    ) U_HOUR_Watch (
        .clk(clk),
        .rst(rst),
        .i_up_down(btn_updown),
        .i_select(i_hour),
        .i_tick(w_hour_tick),
        .i_borrow(w_min_borrow),
        .o_time(hour),
        .o_tick(w_day_tick),
        .o_borrow(w_hour_borrow)
    );

endmodule


module tick_gen_watch_100hz (
    input clk,
    input rst,
    output reg o_tick_100
);

    parameter FCOUNT = 1_000_000;  //1_000_000

    reg [$clog2(FCOUNT)-1:0] r_counter;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1; //count값이 일치했을때 o_tick_100 상승
                r_counter <= 0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter + 1;
            end
        end
    end

endmodule

module watch_time_counter #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    START_COUNT = 0
) (
    input                  clk,
    input                  rst,
    input  [          1:0] i_up_down,
    input                  i_select,
    input                  i_tick,
    input                  i_borrow,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick,
    output                 o_borrow
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg r_tick_reg, r_tick_next, r_borrow_reg, r_borrow_next;

    assign o_time   = count_reg;
    assign o_tick   = r_tick_reg;
    assign o_borrow = r_borrow_reg;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= START_COUNT;
            r_tick_reg <= 1'b0;
            r_borrow_reg <= 1'b0;
        end else begin
            count_reg <= count_next;
            r_tick_reg <= r_tick_next;
            r_borrow_reg <= r_borrow_next;
        end
    end

    //next state
    always @(*) begin
        count_next = count_reg;
        r_tick_next = 1'b0;
        r_borrow_next = 1'b0;

        if (i_tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next  = 0;
                r_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                r_tick_next = 1'b0;
            end
        end else if (i_select) begin
            case (i_up_down)
                2'b10: begin  //up
                    if (count_reg == TICK_COUNT - 1) begin
                        count_next  = 0;
                        r_tick_next = 1'b1;
                    end else begin
                        count_next  = count_reg + 1;
                        r_tick_next = 1'b0;
                    end
                end
                2'b01: begin  //down
                    if (count_reg == 0) begin
                        count_next = TICK_COUNT - 1;
                        r_borrow_next = 1'b1;
                    end else begin
                        count_next = count_reg - 1;
                        r_borrow_next = 1'b0;
                    end
                end
            endcase
        end else if (i_borrow) begin
            if (count_reg == 0) begin
                count_next = TICK_COUNT - 1;
                r_borrow_next = 1'b1;
            end else begin
                count_next = count_reg - 1;
                r_borrow_next = 1'b0;
            end
        end
    end

endmodule
