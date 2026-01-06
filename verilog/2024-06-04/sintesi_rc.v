module MEDIA_ESPONENZIALE (
    cur_m, next_x, next_m
);


    input [7:0] cur_m, next_x;
    output [7:0] next_m;

    wire [9:0] prod_m1;
    wire [7:0] m1;
    wire [7:0] x1;
    wire c_out;

    mul_add_nat #(.N(8)) mul_m1 ( // 3 * cur_m
        .x(cur_m), .y(2'd3), .c(8'd0),
        .m(prod_m1)
    );

    assign m1 = prod_m1[9:2]; // (3 * cur_m) / 4
    assign x1 = {2'b00, next_x[7:2]}; // next_x / 4

    // somma finale m1 + x
    add #(.N(8)) add_m1_x (
        .x(m1), .y(x1), .c_in(1'b0),
        .s(next_m),
        .c_out(c_out)
    );

endmodule
