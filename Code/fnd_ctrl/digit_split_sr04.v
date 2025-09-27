module digit_split_sr04 (
    input [9:0] sr04_data,

    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1    = sr04_data % 10;
    assign digit_10   = (sr04_data / 10) % 10;
    assign digit_100  = (sr04_data / 100) % 10;
    assign digit_1000 = sr04_data / 1000;
endmodule
