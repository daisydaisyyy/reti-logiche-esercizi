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

    wire b5,b4,b3,b2,b1,b0;
    wire c;

    ABC_PO po (
        clock, reset_,
        x, soc, eoc,
        m, z,
        b5,b4,b3,b2,b1,b0,
        c
    );

    ABC_PC pc (
        clock, reset_,
        b5,b4,b3,b2,b1,b0,
        c
    );


endmodule


module ABC_PO (
    clock, reset_,
    x, soc, eoc,
    m, z,
    b5,b4,b3,b2,b1,b0,
    c
);

    input clock, reset_;
    input [7:0] x;
    input eoc;
    output soc;
    output [7:0] m;
    output z;
    input b5,b4,b3,b2,b1,b0;
    output c;

    reg SOC;
    reg [7:0] M;
    reg Z;
    reg [7:0] PREV_M;

    assign soc = SOC;
    assign m = M;
    assign z = Z;
    assign c = eoc;

    wire [7:0] next_m;

    MEDIA_ESPONENZIALE rc(
        .cur_m(PREV_M), .next_x(x), .next_m(next_m)
    );


    // SOC
    always @(reset_ == 0) begin
        SOC <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex({b1,b0})
            2'b00: begin // S0
                SOC <= 1;
            end
            2'b01: begin // S1
                SOC <= 0;
            end
            2'b1X: begin
                SOC <= SOC;
            end
        endcase
    end

    // M
    always @(reset_ == 0) begin
        M <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(b2)
            1'b1: begin // S2
                M <= next_m;
            end
            1'b0: begin
                M <= M;
            end
        endcase
    end

    // PREV_M
    always @(reset_ == 0) begin
        PREV_M <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(b3)
            1'b1: begin // S2
                PREV_M <= next_m;
            end
            1'b0: begin
                PREV_M <= PREV_M;
            end

        endcase
    end

    // Z
    always @(reset_ == 0) begin
        Z <= 0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex({b5,b4})
            2'b00: begin // S0
                Z <= 0;
            end
            2'b01: begin // S2
                Z <= 1;
            end
            2'b1X: begin
                Z <= Z;
            end
        endcase
    end

endmodule


module ABC_PC (
    clock, reset_,
    b5,b4,b3,b2,b1,b0,
    c
);

    input clock, reset_;
    output b5,b4,b3,b2,b1,b0;
    input c;
    reg [1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;


    assign {b5,b4,b3,b2,b1,b0} = 
    (STAR == S0) ? 6'b000000 :
    (STAR == S1) ? 6'b1X0001 :
    (STAR == S2) ? 6'b01111X :
    6'b1X001X;


    always @(reset_ == 0) begin
        STAR = S0;
    end

    always @(posedge clock) if(reset_ == 1) begin
        casex(STAR)
            S0: begin
                STAR <= c ? S0 : S1;
            end
            S1: begin
                STAR <= c ? S2 : S1;
            end
            S2: begin
                STAR <= S0;
            end

        endcase
    end

endmodule


/*
ROM

m-addr   | b5,b4,b3,b2,b1,b0 |   c_eff   |  m-addr-T  |   m-addr-F
00 (S0)  |      000000       |   1       |     00     |     01
01 (S1)  |      1X0001       |   1       |     10     |     01
10 (S2)  |      01111X       |   X       |     00     |     00

*/