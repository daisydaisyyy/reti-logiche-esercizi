module MIN_2 {
    a,b,
    min
};
    input [7:0] a,b;
    output [7:0] min;

    wire b_out;
    diff #( .N(8) ) d(
        .x(a), .y(b), .b_in(1'b0),
        .b_out(b_out)
    );

    assign #1 min = b_out ? a : b;
endmodule

module MIN_3 {
    a,b,c,
    min
};
    input[7:0] a,b,c;
    output [7:0] min;

    wire [7:0] m_ab_out;
    MIN_2 min_a_b(
        .a(a), .b(b),
        .min(m_ab_out)
    );

    MIN_2 min_abc (
        .a(m_ab_out), .b(c),
        .min(min)
    );
endmodule

