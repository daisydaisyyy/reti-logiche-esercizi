module QUADRATO_DELLA_SOMMA(x,y,q);
    input [7:0] x,y;
    output [17:0] q;

    // prodotti
    wire [15:0] x2;
    mul_add_nat mul_x_2 (
        .x(x), .y(x), .c(8'b0),
        .m(x2)
    );

    wire [15:0] y2;
    mul_add_nat mul_y_2 (
        .x(y), .y(y), .c(8'b0),
        .m(y2)
    );

    wire [15:0] xy;
    mul_add_nat mul_xy (
        .x(x), .y(y), .c(8'b0),
        .m(xy)
    );

    // somma x^2 + y^2
    wire [16:0] first_sum;
    add #(.N(16)) sum1 ( // somma su 16 bit, il carry va nell'ultimo bit
        .x(x2), .y(y2), .c_in(1'b0),
        .s(first_sum[15:0]), .c_out(first_sum[16])
    );

    // somma precedente + 2xy
    // {xy, 1'b0} = xy * 2 perche' shiftato una volta a sinistra
    add #(.N(17)) tot_sum (
        .x(first_sum), .y({xy, 1'b0}), .c_in(1'b0),
        .s(q[16:0]), .c_out(q[17])
    );
endmodule
