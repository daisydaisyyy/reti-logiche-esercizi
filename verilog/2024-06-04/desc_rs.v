module ABC (
    clock, reset_,
    x, soc, eoc,
    m, z
);

    input clock, reset_;
    input [7:0] x;
    input eoc;
    output soc;
    output [7:0] m;
    output z;

    reg SOC;
    reg [7:0] M;
    reg Z;
    reg [7:0] PREV_M;

    assign soc = SOC;
    assign m = M;
    assign z = Z;

    reg [1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;

    wire [7:0] next_m;

    MEDIA_ESPONENZIALE rc(
        .cur_m(PREV_M), .next_x(x), .next_m(next_m)
    );


    always @(reset_ == 0) begin
        SOC <= 0;
        M <= 0;
        PREV_M <= 0;
        Z <= 0;
        STAR = S0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin
                Z <= 0;
                SOC <= 1;
                STAR <= (eoc == 0) ? S1 : S0;
            end
            S1: begin
                SOC <= 0;
                STAR <= (eoc == 1) ? S2 : S1;
            end
            S2: begin
                M <= next_m;
                PREV_M <= next_m;
                Z <= 1;
                STAR <= S0;
            end

        endcase
    end

endmodule