module ABC (
    clock, reset_,
    x, y, soc, eocx, eocy,
    dav_, rfd, q
);

    input clock, reset_;
    input eocx, eocy;
    output soc;
    input [7:0] x,y;
    input rfd;
    output [31:0] q;
    output dav_;


    wire b0,b1,b2,b3,b4;
    wire c0,c1,c2;


    ABC_PO po  (
        clock, reset_,
        b0, b1, b2, b3, b4,
        c0, c1, c2,
        x, y, q,
        soc, eocx, eocy,
        dav_, rfd

    );

    ABC_PC pc (
        clock, reset_,
        b0,b1,b2,b3,b4,
        c0,c1,c2
    );

endmodule


module ABC_PO (
    clock, reset_,
    b0, b1, b2, b3, b4,
    c0, c1, c2,
    x, y, q,
    soc, eocx, eocy,
    dav_, rfd
);

    input reset_, clock;
    input [7:0] x,y;
    input eocx, eocy;
    output soc;
    input rfd;
    output dav_;
    output [31:0] q;
    input b0,b1,b2,b3,b4;
    output c0,c1,c2;
    reg SOC;
    assign soc = SOC;

    reg DAV_;
    assign dav_ = DAV_;

    reg [31:0] Q;
    assign q = Q;
    wire [17:0] rc_result;

    assign #1 c0 = (eocx == 0 & eocy == 0);
    assign #1 c1 = (eocx == 1 & eocy == 1);
    assign #1 c2 = rfd;

    QUADRATO_DELLA_SOMMA rc(
        .x(x), .y(y), .q(rc_result)
    );
    // DAV_
    always @(reset_ == 0) #1
        begin
            DAV_ <= 1;
        end

    always @(posedge clock) if (reset_ == 1) #3
        casex ({b1,b0})
            2'b00:
                begin
                    DAV_ <= 0; // invio al consumatore
                end
            2'b01:
                begin
                    DAV_ <= 1; // ho inviato il dato, non e' piu' available
                end
            2'b10:
                begin
                    DAV_ <= DAV_;
                end
        endcase

    // SOC
    always @(reset_ == 0) #1
        begin
            SOC <= 0;
        end

    always @(posedge clock) if (reset_ == 1) #3
        casex ({b3,b2})
            2'b00:
                begin
                    SOC <= 1;
                end
            2'b01:
                begin
                    SOC <= 0;
                end
            2'b10:
                begin
                    SOC <= SOC;
                end
        endcase


    // Q
    always @(posedge clock) if (reset_ == 1) #3
        casex (b4)
            1'b0:
                begin
                    Q <= {14'b0, rc_result}; // risultato esteso a 32 bit
                end
            1'b1:
                begin
                    Q <= Q;
                end
        endcase
endmodule



module ABC_PC (
    clock, reset_,
    b0,b1,b2,b3,b4,
    c0,c1,c2
);


    output b0,b1,b2,b3,b4;
    input c0,c1,c2;
    input clock, reset_;


    reg [1:0] STAR;
    localparam
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3;


    assign #1 {b4,b3,b2,b1,b0} =
            (STAR == S0) ? 5'b10010 :
            (STAR == S1) ? 5'b00110 :
            (STAR == S2) ? 5'b11000 :
            (STAR == S3) ? 5'b11001 :
                        5'b11010;


    // STAR
    always @(reset_ == 0) #1
        begin
            STAR <= S0;
        end

    always @(posedge clock) if (reset_ == 1) #3
        casex (STAR)
            S0:
                begin
                    STAR <= c0 ? S1 : S0;
                end
            S1:
                begin
                    STAR <= c1 ? S2 : S1;
                end
            S2:
                begin
                    STAR <= c2 ? S2 : S3;
                end
            S3:
                begin
                    STAR <= c2 ? S0 : S3; // pronto per ricevere nuovi dati?
                end
            endcase

endmodule





