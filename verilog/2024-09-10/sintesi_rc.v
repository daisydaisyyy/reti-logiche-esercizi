module PROSSIMO_S (
    x, xprev, s, ow
);


input [7:0] x, xprev;
output [7:0] s;
output ow;

add #(.N(8)) add_x( 
    .x(x), .y(xprev), .c_in(1'b0),
    .s(s), .ow(ow)
);

endmodule