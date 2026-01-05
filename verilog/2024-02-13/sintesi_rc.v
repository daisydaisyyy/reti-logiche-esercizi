module IN_AREA (
    x,y,z
);

    input [7:0] x;
    input [7:0] y;
    output z;
    wire [7:0] abs_x, abs_y;
    
    abs #(.N(8)) rc_abs_x (
        .x(x), .abs_x(abs_x)
    );

    abs #(.N(8)) rc_abs_y (
        .x(y), .abs_x(abs_y)
    );
    wire [8:0] s;
    wire min_k1;
    wire eq_k1;
    wire min_x;
    wire eq_x;
    wire min_y;
    wire eq_y;
    localparam [7:0] k1 = 8'd64;
    localparam [7:0] k2 = 8'd48;

    add #(.N(8)) add_xy (.x(abs_x), .y(abs_y), .c_in(1'b0),
    .s(s[7:0]), .c_out(s[8]) );

    comp_nat #(.N(9)) comp_k1(
        .a(s), .b({1'b0,k1}),
        .min(min_k1), .eq(eq_k1)
    );

    // equivalenza k2
    comp_nat #(.N(8)) comp_x_k2(
        .a(abs_x), .b(k2),
        .min(min_x), .eq(eq_x)
    );

    comp_nat #(.N(8)) comp_y_k2(
        .a(abs_y), .b(k2),
        .min(min_y), .eq(eq_y)
    );

    assign z = (min_k1 | eq_k1) ^ ((min_x | eq_x) & (min_y | eq_y));

endmodule

