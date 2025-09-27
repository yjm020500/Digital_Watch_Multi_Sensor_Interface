`timescale 1ns / 1ps

module fifo (
    input        clk,
    input        rst,
    input        push,
    input        pop,
    input  [7:0] push_data,
    output       full,
    output       empty,
    output [7:0] pop_data
);

    wire [3:0] w_w_ptr, w_r_ptr;

    register_file U_Reg_File (
        .clk  (clk),
        .wr_en({(~full) & push}),
        .wdata(push_data),
        .w_ptr(w_w_ptr),
        .r_ptr(w_r_ptr),
        .rdata(pop_data)
    );

    fifo_cu U_FIFO_Reg (
        .clk  (clk),
        .rst  (rst),
        .push (push),
        .pop  (pop),
        .w_ptr(w_w_ptr),
        .r_ptr(w_r_ptr),
        .full (full),
        .empty(empty)
    );

endmodule

module register_file #(
    parameter DEPTH = 16,
    WIDTH = 4
) (
    input              clk,
    input              wr_en,
    input  [      7:0] wdata,
    input  [WIDTH-1:0] w_ptr,
    input  [WIDTH-1:0] r_ptr,
    output [      7:0] rdata
);

    reg [7:0] mem[0:DEPTH-1];  //mem[0:2**WIDTH - 1]

    assign rdata = mem[r_ptr];  //lutmem 사용, 속도는 더 빠르다///////////////////

    always @(posedge clk) begin
        if (wr_en) begin
            mem[w_ptr] <= wdata;
        end
        //rdata <= mem[r_ptr]; //assign대신 이렇게 쓰기도 한다, 이건 bram사용
    end

endmodule

module fifo_cu (
    input        clk,
    input        rst,
    input        push,
    input        pop,
    output [3:0] w_ptr,
    output [3:0] r_ptr,
    output       full,
    output       empty
);

    reg [3:0] w_ptr_reg, w_ptr_next, r_ptr_reg, r_ptr_next;
    reg full_reg, full_next, empty_reg, empty_next;

    assign w_ptr = w_ptr_reg;
    assign r_ptr = r_ptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg  <= 1'b0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

    always @(*) begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;
        case ({
            pop, push
        })
            2'b01: begin  //push
                if (full_reg == 1'b0) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;
                    if (w_ptr_next == r_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            2'b10: begin  //pop
                if (empty_reg == 1'b0) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next  = 1'b0;
                    if (w_ptr_reg == r_ptr_next) begin
                        empty_next = 1'b1;
                    end
                end
            end
            2'b11: begin  //push & pop
                if (empty_reg) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;
                end else if (full_reg) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next  = 1'b0;
                end else begin
                    w_ptr_next = w_ptr_reg + 1;
                    r_ptr_next = r_ptr_reg + 1;
                end
            end
        endcase
    end

endmodule
