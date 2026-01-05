module ABC(
    soc_x, eoc_x, x, 
    soc_y, eoc_y, y,
    reset_, clock,
    dav_, rfd, result, z
);

    input clock, reset_;
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input [7:0] x;
    input [7:0] y;
    output dav_;
    output result;
    input rfd;

    reg [1:0] STAR;
    reg DAV_;
    reg SOC;
    output z;

    reg RES;
    wire result;

    wire c2, c1, c0;
    wire b0,b1,b2,b3, b4;


    ABC_PO po (
        x,y, clock, reset_,
        b0,b1,b2,b3,b4,
        c2,c1,c0,
        soc_x, soc_y,
        eoc_x, eoc_y,
        dav_, rfd,
        result, z
    );

    ABC_PC pc (
        clock, reset_,
        b0,b1,b2,b3,b4,
        c2,c1,c0
    );
endmodule


module ABC_PO(
    x,y, clock, reset_,
    b0,b1,b2,b3,b4,
    c2,c1,c0,
    soc_x, soc_y,
    eoc_x, eoc_y,
    dav_, rfd,
    result, z
);

    input clock, reset_;
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input [7:0] x;
    input [7:0] y;
    output dav_;
    output result;
    input rfd;
    input b4, b3, b2, b1, b0;
    output c2, c1, c0;
    reg DAV_;
    assign #1 dav_ = DAV_;
    reg SOC;
    assign #1 soc_x = SOC;
    assign #1 soc_y = SOC;
    output z;

    reg RES;
    assign #1 z = RES;
    wire result;

    assign #1 c0 = {eoc_x, eoc_y} == 2'b00;
    assign #1 c1 = {eoc_x, eoc_y} == 2'b11;
    assign #1 c2 = rfd == 1;

    wire c2,c1,c0;
    wire b5,b4,b3,b2,b1,b0;

    IN_AREA rc(
        .x(x), .y(y), .z(result)
    );
    // soc
    always @(reset_ == 0) begin
        SOC <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex({b1, b0})
            2'b00: begin // S0
                SOC <= 1;
            end

            2'b01: begin // S1
                SOC <= 0;
            end

            2'b10: begin // S1
                SOC <= SOC;
            end
        endcase
    end

    // dav
    always @(reset_ == 0) begin
        DAV_ <= 1;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex({b3,b2})
            2'b00: begin // s2
                DAV_ <= 0;
            end

            2'b01: begin
                DAV_ <= 1; // s3
            end

            2'b10: begin
                DAV_ <= DAV_;
            end

        endcase
    end

    // res
    always @(posedge clock) if (reset_ == 1) begin
        casex(b4)
            1'b0: begin // s1
                RES <= result;
            end

            1'b1: begin
                RES <= RES;
            end
        endcase
    end


endmodule


module ABC_PC (
    clock, reset_,
    b0,b1,b2,b3,b4,
    c2,c1,c0
);
    input clock, reset_;
    input c2,c1,c0;
    output b0,b1,b2,b3,b4;
    reg [1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    
    assign #1 {b4,b3,b2,b1,b0} = 
        (STAR == S0)? 5'b11000 : 
        (STAR == S1)? 5'b01001 : 
        (STAR == S2)? 5'b10010 : 
        (STAR == S3)? 5'b10100 : 
        5'b11010;

    always @(reset_ == 0) begin
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex(STAR)
            S0: begin
                STAR <= (c0) ? S1 : S0;
            end

            S1: begin
                STAR <= (c1) ? S2 : S1;
            end

            S2: begin
                STAR <= (c2) ? S3 : S2;
            end

            S3: begin
                STAR <= (c2) ? S3 : S0;
            end
        endcase
    end




endmodule


/*
ROM

S0 = 00, S1 = 01, S2 = 10, S3 = 11
c0 = 00, c1 = 01, c2 = 1X

M-addr  |  b4, b3, b2, b1, b0   | c_eff | M-addr-T  | M-addr-F
00      |   11000               |   00  |   01      |   00
01      |   01001               |   01  |   10      |   01
10      |   10010               |   1X  |   11      |   10
11      |   10100               |   1X  |   11      |   00

*/
