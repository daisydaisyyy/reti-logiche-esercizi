module ABC (
    x,y, eoc_x, soc_x, eoc_y , soc_y,
    dav_, rfd, t,
    clock, reset_
);

    input reset_, clock;
    input x,y;
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input rfd;
    output dav_;
    output [1:0] t;

    wire match;
    wire [1:0] match_type;

    wire c2,c1,c0;
    wire b5,b4,b3,b2,b1,b0;


    ABC_PO po (
        x,y,
        clock, reset_,
        b5,b4,b3,b2,b1,b0,
        c2,c1,c0,
        soc_x, soc_y,
        eoc_x, eoc_y,
        dav_, t, rfd
    );

    ABC_PC pc (
        clock, reset_,
        b5,b4,b3,b2,b1,b0,
        c2,c1,c0
    );
endmodule


module ABC_PO (
    x,y,
    clock, reset_,
    b5,b4,b3,b2,b1,b0,
    c2,c1,c0,
    soc_x, soc_y,
    eoc_x, eoc_y,
    dav_, t, rfd
);

    input reset_, clock;
    input eoc_x, eoc_y;
    input rfd;
    input x,y;
    output [1:0] t;
    output dav_;
    output soc_x, soc_y;
    input b5,b4,b3,b2,b1,b0;
    output c2,c1,c0;

    reg DAV_, SOC;
    reg [1:0] T;
    
    assign soc_x = SOC;
    assign soc_y = SOC;
    assign dav_ = DAV_;
    assign t = T;

    assign #1 c0 = eoc_x & eoc_y; // salto in s0,s1
    assign #1 c1 = match; 
    assign #1 c2 = rfd;

    reg [3:0] BUFFER;

    wire match;
    wire [1:0] match_type;


    wire c2,c1,c0;
    wire b5,b4,b3,b2,b1,b0;


  MATCH_SEQ rc (
        .buffer(BUFFER), .match(match), .match_type(match_type)
    );


    // soc
    always @ (reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if (reset_ == 1) #3
        casex({b1,b0})
            2'b00:
                begin
                    SOC <= 1;
                end
            2'b01:
                begin
                    SOC <= 0;
                end

            2'b1X:
                begin
                    SOC <= SOC;
                end
        endcase

    // buffer
    always @(reset_ == 0) #1 BUFFER <= 0;

    always @(posedge clock) if (reset_ == 1) #3
        casex(b2)
            1'b0:
                begin
                    BUFFER <= {BUFFER[3:0], x ^ y};
                end


            1'b1:
                begin
                    BUFFER <= BUFFER;
                end
        endcase

    // dav
    always @ (reset_ == 0) #1 DAV_ <= 1;

    always @(posedge clock) if (reset_ == 1) #3
        casex({b4,b3})
            2'b00:
                begin
                    DAV_ <= 0;
                end

            2'b01:
                begin
                    DAV_ <= 1;
                end

            2'b1X:
                begin
                    DAV_ <= DAV_;
                end
        endcase

    // t
    always @(posedge clock) if (reset_ == 1) #3
        casex(b5)
            1'b0:
                begin
                    T <= match_type;
                end

            1'b1:
                begin
                    T <= T;
                end
        endcase
endmodule



module ABC_PC (
    clock, reset_,
    b5,b4,b3,b2,b1,b0,
    c2,c1,c0
);

    input clock, reset_;
    output b5,b4,b3,b2,b1,b0;
    input c2,c1,c0;

    reg [2:0] STAR;
    localparam
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3,
        S4 = 4,
        S5 = 5;



    assign #1 {b5,b4,b3,b2,b1,b0} =
        (STAR == S0) ? 6'b110100 :
        (STAR == S1) ? 6'b110101 :
        (STAR == S2) ? 6'b110010 :
        (STAR == S3) ? 6'b010110 :
        (STAR == S4) ? 6'b100110 :
        (STAR == S5) ? 6'b101110 :
                       6'b000000;

    always @ (reset_ == 0) #1 begin
        STAR = S0;
    end

    always @(posedge clock) if (reset_ == 1) #3 begin
        casex(STAR)
            S0:
                begin
                    STAR <= c0 ? S0 : S1;
                end
            S1:
                begin
                    STAR <= c0 ? S2 : S1;
                end
            S2:
                begin
                    STAR <= S3;
                end
            S3:
                begin
                    STAR <= c1 ? S4 : S0;
                end
            S4:
                begin
                    STAR <=  c2 ? S4 : S5;
                end

            S5:
                begin
                    STAR <= c2 ? S0 : S5;
                end
        endcase
    end

endmodule


/*
ROM

M-addr  | b5,b4,b3,b2,b1,b0 | c_eff | M-addr T | M-addr F
-------------------------------------------------------
000     |        110100     |  00  |    000   |  001
001     |        110101     |  00  |    010   |  001
010     |        010110     |  x   |    011   |  011
011     |        100110     |  01  |    100   |  000
100     |        101110     |  10  |    100   |  101
101     |        101110     |  10  |    000  |   101
*/