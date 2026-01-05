module MUL5(a, m);
    input [7:0] a;
    output [15:0] m;


    wire [9:0] a4_ext;
    wire [9:0] a1_ext;
    assign a1_ext = {2'b00, a};
    assign a4_ext = {a, 2'b00};

    wire [9:0] sum;
    wire c_out;
    add #(.N(10)) s (
        .x(a1_ext), .y(a4_ext), .c_in(1'b0),
        .s(sum), .c_out(c_out)
    );

    assign m = { 5'h00, c_out, sum };
endmodule