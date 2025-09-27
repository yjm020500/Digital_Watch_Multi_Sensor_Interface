module mux_4x1 (
    input [3:0] i_bcd_ms,
    input [3:0] i_bcd_mh,
    input [3:0] i_bcd_sr04,
    input [3:0] i_bcd_dht11,
    input [1:0] hw_sel,
    input disp_sel,

    output reg [3:0] o_bcd
);

    always @(*) begin
        case (hw_sel)
            2'b00: begin
                if (!disp_sel) begin
                    o_bcd = i_bcd_ms;
                end else begin
                    o_bcd = i_bcd_mh;
                end
            end
            2'b01: begin
                if (!disp_sel) begin
                    o_bcd = i_bcd_ms;
                end else begin
                    o_bcd = i_bcd_mh;
                end
            end
            2'b10: o_bcd = i_bcd_sr04;
            2'b11: o_bcd = i_bcd_dht11;
        endcase
    end
endmodule
