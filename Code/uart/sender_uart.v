`timescale 1ns / 1ps

module uart (
    input clk,
    input rst,
    input rx,
    input dht11_valid,
    input  [23:0] i_watch_data,///////////////////////////////////////////////////////////////////////////
    input [23:0] i_stopwatch_data,
    input [9:0] i_super_sonic_data,
    input [15:0] i_dht11_data,  //t,rh순으로 묶어서 들어온다고 가정
    output tx,
    output [7:0] rx_data,
    output rx_done
);

    parameter IDLE = 0, SEND_WATCH = 1, SEND_STOPWATCH = 2, SEND_SUPER_SONIC = 3, SEND_DHT11 = 4;

    reg [2:0] c_state, n_state;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [4:0] send_cnt_reg, send_cnt_next;

    wire [63:0] w_watch_data, w_stopwatch_data;
    wire [31:0] w_dht11_data;
    wire [23:0] w_super_sonic_data;

    wire [ 7:0] w_rx_data;
    wire [ 2:0] w_send_select;
    wire w_tx_full, w_rx_done;
    ////////////////////////////////////////////////////////////////////////////////////////////////
    assign rx_data = w_rx_data;
    assign rx_done = w_rx_done;
    ////////////////////////////////////////////////////////////////////////////////////////////////
    uart_fifo U_UART_CON (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx_push(send_reg),
        .tx_push_data(send_data_reg),
        .rx_pop_data(w_rx_data),
        .rx_done(w_rx_done),
        .tx_full(w_tx_full),
        .tx_done(),
        .tx(tx)
    );

    uart_send_data_lut U_SEND_DATA_LUT (
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .send_select(w_send_select)
    );
    /////////////////////////////////////////////////////////////////////////////////////////

    data_to_ascii_watch U_DtoA_WATCH (
        .i_data(i_watch_data),
        .o_data(w_watch_data)
    );

    data_to_ascii_watch U_DtoA_STOPWATCH (
        .i_data(i_stopwatch_data),
        .o_data(w_stopwatch_data)
    );

    data_to_ascii_super_sonic U_DtoA_SUPER_SONIC (
        .i_data(i_super_sonic_data),
        .o_data(w_super_sonic_data)
    );

    data_to_ascii_dht11 U_DtoA_DHT11 (
        .i_data(i_dht11_data),
        .o_data(w_dht11_data)
    );

    //////////////////////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state       <= 0;
            send_data_reg <= 0;
            send_reg      <= 0;
            send_cnt_reg  <= 0;
        end else begin
            c_state       <= n_state;
            send_data_reg <= send_data_next;
            send_reg      <= send_next;
            send_cnt_reg  <= send_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        send_data_next = send_data_reg;
        send_next = send_reg;
        send_cnt_next = send_cnt_reg;
        case (c_state)
            IDLE: begin
                send_cnt_next = 0;
                send_next = 0;
                send_data_next = 0;
                case (w_send_select)
                    SEND_WATCH: begin
                        n_state = SEND_WATCH;
                    end
                    SEND_STOPWATCH: begin
                        n_state = SEND_STOPWATCH;
                    end
                    SEND_SUPER_SONIC: begin
                        n_state = SEND_SUPER_SONIC;
                    end
                    SEND_DHT11: begin
                        n_state = SEND_DHT11;
                    end
                endcase
            end
            SEND_WATCH: begin
                if (~w_tx_full) begin
                    if (send_cnt_reg < 22) begin
                        send_next = 1'b1;  //send tick 생성
                        //상위부터 보내기
                        case (send_cnt_reg)///////////////////////////////////////////////////////////////////
                            5'h0: send_data_next = 8'h57;  //W
                            5'h1: send_data_next = 8'h41;  //A
                            5'h2: send_data_next = 8'h54;  //T
                            5'h3: send_data_next = 8'h43;  //C
                            5'h4: send_data_next = 8'h48;  //H
                            5'h5: send_data_next = 8'h20;  //SPACE
                            5'h6: send_data_next = 8'h3D;  //=
                            5'h7: send_data_next = 8'h3E;  //>
                            5'h8: send_data_next = 8'h20;  //SPACE
                            5'h9:
                            send_data_next = w_watch_data[63:56];  //HOUR, 10
                            5'hA:
                            send_data_next = w_watch_data[55:48];  //HOUR, 1
                            5'hB: send_data_next = 8'h3A;  //:
                            5'hC:
                            send_data_next = w_watch_data[47:40];  //MIN, 10
                            5'hD:
                            send_data_next = w_watch_data[39:32];  //MIN, 1
                            5'hE: send_data_next = 8'h3A;  //:
                            5'hF:
                            send_data_next = w_watch_data[31:24];  //SEC, 10
                            5'h10:
                            send_data_next = w_watch_data[23:16];  //SEC, 1
                            5'h11: send_data_next = 8'h3A;  //:
                            5'h12:
                            send_data_next = w_watch_data[15:8];  //MSEC, 10
                            5'h13:
                            send_data_next = w_watch_data[7:0];  //MSEC, 1
                            5'h14: send_data_next = 8'h0D;  // \r
                            5'h15: send_data_next = 8'h0A;  // \n
                            /////////////////////////////////////////////////////////////////////////////////////
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = IDLE;
                        send_next = 1'b0;
                    end
                end else begin
                    n_state = c_state;
                end
            end
            SEND_STOPWATCH: begin
                if (~w_tx_full) begin
                    if (send_cnt_reg < 26) begin
                        send_next = 1'b1;  //send tick 생성
                        //상위부터 보내기
                        case (send_cnt_reg)/////////////////////////////////////////////////////////////////
                            5'h0: send_data_next = 8'h53;  //S
                            5'h1: send_data_next = 8'h54;  //T
                            5'h2: send_data_next = 8'h4F;  //O
                            5'h3: send_data_next = 8'h50;  //P 
                            5'h4: send_data_next = 8'h57;  //W
                            5'h5: send_data_next = 8'h41;  //A
                            5'h6: send_data_next = 8'h54;  //T
                            5'h7: send_data_next = 8'h43;  //C
                            5'h8: send_data_next = 8'h48;  //H
                            5'h9: send_data_next = 8'h20;  //SPACE
                            5'hA: send_data_next = 8'h3D;  //=
                            5'hB: send_data_next = 8'h3E;  //>
                            5'hC: send_data_next = 8'h20;  //SPACE
                            5'hD:
                            send_data_next = w_stopwatch_data[63:56]; //HOUR, 10
                            5'hE:
                            send_data_next = w_stopwatch_data[55:48];  //HOUR, 1
                            5'hF: send_data_next = 8'h3A;  //:
                            5'h10:
                            send_data_next = w_stopwatch_data[47:40];  //MIN, 10
                            5'h11:
                            send_data_next = w_stopwatch_data[39:32];  //MIN, 1
                            5'h12: send_data_next = 8'h3A;  //:
                            5'h13:
                            send_data_next = w_stopwatch_data[31:24];  //SEC, 10
                            5'h14:
                            send_data_next = w_stopwatch_data[23:16];  //SEC, 1
                            5'h15: send_data_next = 8'h3A;  //:
                            5'h16:
                            send_data_next = w_stopwatch_data[15:8];  //MSEC, 10
                            5'h17:
                            send_data_next = w_stopwatch_data[7:0];  //MSEC, 1
                            5'h18: send_data_next = 8'h0D;  // \r
                            5'h19: send_data_next = 8'h0A;  // \n
                            ///////////////////////////////////////////////////////////////////////////////
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = IDLE;
                        send_next = 1'b0;
                    end
                end else begin
                    n_state = c_state;
                end
            end
            SEND_SUPER_SONIC: begin
                //n_state = 0;
                if (~w_tx_full) begin
                    if (send_cnt_reg < 20) begin////////////////////////////////
                        send_next = 1'b1;  //send tick 생성
                        //상위부터 보내기
                        case (send_cnt_reg)//////////////////////////////////////////////////////////////
                            5'h0: send_data_next = 8'h55;  //U
                            5'h1: send_data_next = 8'h4C;  //L
                            5'h2: send_data_next = 8'h54;  //T
                            5'h3: send_data_next = 8'h52;  //R
                            5'h4: send_data_next = 8'h41;  //A
                            5'h5: send_data_next = 8'h53;  //S
                            5'h6: send_data_next = 8'h4F;  //O
                            5'h7: send_data_next = 8'h4E;  //N
                            5'h8: send_data_next = 8'h49;  //I
                            5'h9: send_data_next = 8'h43;  //C
                            5'hA: send_data_next = 8'h20;  //SPACE
                            5'hB: send_data_next = 8'h3D;  //=
                            5'hC: send_data_next = 8'h3E;  //>
                            5'hD: send_data_next = 8'h20;  //SPACE
                            5'hE:
                            if (w_super_sonic_data[23:16] != 8'h30)
                                send_data_next = w_super_sonic_data[23:16];//100
                            5'hF:
                            if (w_super_sonic_data[15:8] != 8'h30)
                                send_data_next = w_super_sonic_data[15:8];  //10
                            5'h10:
                            send_data_next = w_super_sonic_data[7:0];  //1
                            5'h11: send_data_next = 8'h63;  //c
                            5'h12: send_data_next = 8'h6D;  //m
                            5'h13: send_data_next = 8'h0D;  // \r
                            5'h14: send_data_next = 8'h0A;  // \n 
                            //////////////////////////////////////////////////////////////////////////
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = IDLE;
                        send_next = 1'b0;
                    end
                end else begin
                    n_state = c_state;
                end
            end
            SEND_DHT11: begin
                if (~w_tx_full && dht11_valid) begin
                    if (send_cnt_reg < 17) begin
                        send_next = 1'b1;  //send tick 생성
                        //상위부터 보내기
                        case (send_cnt_reg)///////////////////////////////////////////////////////////////
                            5'h0: send_data_next = 8'h54;  //T
                            5'h1: send_data_next = 8'h2C;  //,
                            5'h2: send_data_next = 8'h20;  //SPACE
                            5'h3: send_data_next = 8'h52;  //R
                            5'h4: send_data_next = 8'h48;  //H
                            5'h5: send_data_next = 8'h20;  //SPACE
                            5'h6: send_data_next = 8'h3D;  //=
                            5'h7: send_data_next = 8'h3E;  //>
                            5'h8: send_data_next = 8'h20;  //SPACE
                            5'h9: send_data_next = w_dht11_data[31:24];  //T, 10
                            5'hA: send_data_next = w_dht11_data[23:16];  //T, 1
                            5'hB: send_data_next = 8'h43;  //C
                            5'hC: send_data_next = 8'h20;  //SPACE
                            5'hD: send_data_next = w_dht11_data[15:8];  //RH, 10
                            5'hE: send_data_next = w_dht11_data[7:0];  //RH, 1
                            5'hF: send_data_next = 8'h25;  //%
                            5'h10: send_data_next = 8'h0D;  // \r
                            5'h11: send_data_next = 8'h0A;  // \n 
                            ///////////////////////////////////////////////////////////////////////////////
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state   = IDLE;
                        send_next = 1'b0;
                    end
                end else if (~dht11_valid) begin
                    n_state = IDLE;
                end else begin
                    n_state = c_state;
                end
            end
        endcase
    end


endmodule

// decoder, LUT, super sonic
module data_to_ascii_super_sonic (
    input  [ 9:0] i_data,
    output [23:0] o_data
);

    assign o_data[7:0]   = (i_data % 10) + 8'h30;
    assign o_data[15:8]  = ((i_data / 10) % 10) + 8'h30;
    assign o_data[23:16] = ((i_data / 100) % 10) + 8'h30;

endmodule

// decoder, LUT, watch, stopwatch
module data_to_ascii_watch (
    input  [23:0] i_data,
    output [63:0] o_data
);
    //msec
    assign o_data[7:0]   = (i_data[6:0] % 10) + 8'h30;
    assign o_data[15:8]  = (i_data[6:0] / 10) + 8'h30;
    //sec
    assign o_data[23:16] = (i_data[12:7] % 10) + 8'h30;
    assign o_data[31:24] = (i_data[12:7] / 10) + 8'h30;
    //min
    assign o_data[39:32] = (i_data[18:13] % 10) + 8'h30;
    assign o_data[47:40] = (i_data[18:13] / 10) + 8'h30;
    //hour
    assign o_data[55:48] = (i_data[23:19] % 10) + 8'h30;
    assign o_data[63:56] = (i_data[23:19] / 10) + 8'h30;

endmodule

module data_to_ascii_dht11 (
    input  [15:0] i_data,
    output [31:0] o_data
);
    //rh data
    assign o_data[7:0]   = (i_data[7:0] % 10) + 8'h30;
    assign o_data[15:8]  = ((i_data[7:0] / 10) % 10) + 8'h30;
    //t data
    assign o_data[23:16] = (i_data[15:8] % 10) + 8'h30;
    assign o_data[31:24] = ((i_data[15:8] / 10) % 10) + 8'h30;

endmodule

module uart_send_data_lut (
    input      [7:0] rx_data,
    input            rx_done,
    output reg [2:0] send_select
);

    always @(*) begin
        send_select = 3'b000;
        if (rx_done) begin
            case (rx_data)
                8'h31: begin  //watch, "1"
                    send_select = 3'b001;
                end
                8'h32: begin  //stopwatch, "2"
                    send_select = 3'b010;
                end
                8'h33: begin  //super_sonic, "3"
                    send_select = 3'b011;
                end
                8'h34: begin  //dht11, "4"
                    send_select = 3'b100;
                end
            endcase
        end
    end

endmodule
