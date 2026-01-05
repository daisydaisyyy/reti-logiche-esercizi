module PROSSIMA_POSIZIONE (
    cur_x, cur_y,
    vx,vy,
    next_x,next_y
);

    input [7:0] cur_x, cur_y;
    input [3:0] vx, vy;
    output [7:0] next_x,next_y;

    wire [7:0] vx_ext = {vx[3],vx[3],vx[3],vx[3],vx};
    wire [7:0] vy_ext = {vy[3],vy[3],vy[3],vy[3],vy};

    wire ow_x;
    wire ow_y;
    wire [7:0] sx, sy;

    add #(.N(8)) add_x(
        .x(cur_x),.y(vx_ext), .c_in(1'b0),
        .s(sx), .ow(ow_x)
    );

    assign next_x = ow_x ? cur_x : sx;

    add #(.N(8)) add_y(
        .x(cur_y),.y(vy_ext), .c_in(1'b0),
        .s(sy), .ow(ow_y)
    );

    assign next_y = ow_y ? cur_y : sy;

endmodule