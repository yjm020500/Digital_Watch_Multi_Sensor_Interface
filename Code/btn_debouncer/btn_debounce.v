`timescale 1ns / 1ps


module btn_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);
    parameter FCOUNT = 10000;//1000
    //100kHz
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    reg [7:0] q_reg, q_next;
    wire w_debounce;

    //clk div 100kHz
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if (r_counter == (FCOUNT - 1)) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

    //shift debounce
    always @(posedge r_clk, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    always @(i_btn, r_clk, q_reg) begin
        q_next = {i_btn, q_reg[7:1]};
    end

    //8input and gate
    assign w_debounce = &q_reg;


    reg r_edge_q;  //q5

    //edge detector
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_edge_q <= 1'b0;
        end else begin
            r_edge_q <= w_debounce;
        end
    end

    //rising edge
    assign o_btn = (~r_edge_q) & w_debounce;

endmodule
