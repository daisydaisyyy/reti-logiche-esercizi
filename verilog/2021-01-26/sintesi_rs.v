module ABC (
    colore, endline, dav_, rfd, txd,
    clock, reset_,
    
);

    wire b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;
    wire c3,c2,c1,c0;

    input colore, endline, dav_, reset_, clock;
    output txd, rfd;

  
    PO ABC_PO (
        colore, endline, dav_, 
        rfd, txd,
        clock, reset_,
        b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c2,c1,c0
    );

    PC ABC_PC (
        b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c2,c1,c0,
        clock, reset_,
    );
endmodule



module PO (
    colore, endline, dav_, 
    rfd, txd,
    clock, reset_,
    b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c2,c1,c0
);

    input b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;
    output c2,c1,c0;

    input colore, endline, dav_, clock, reset_;
    output txd, rfd;

    reg [6:0] N;
    reg [3:0] COUNT;
    reg [9:0] BUFFER;
    reg       RFD, CUR_COL, TXD;

    localparam marking = 1'B1, start_b = 1'B0, stop_b = 1'B1;
    localparam bianco = 1'B1, nero = 1'B0;


    assign rfd = RFD;
    assign txd = TXD;
    assign c0 = ~dav_;
    assign c1 = (colore == CUR_COL) && (endline == 0);
    assign c2 = (COUNT == 0);


    always @(reset_ == 0) #1 TXD <= marking;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex ({b1,b0})
            2'b00: TXD <= BUFFER[0];
            2'b01: TXD <= marking;
            2'b1X: TXD <= TXD;
        endcase
    end

    always @(posedge clock) if(reset_ == 1) #3 begin
        casex ({b3,b2})
            2'b00: COUNT <= COUNT - 1;
            2'b01: COUNT <= 9;
            2'b1X: COUNT <= COUNT;
        endcase
    end


    always @(reset_ == 0) #1 BUFFER <= marking;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex ({b5,b4})
            2'b00: BUFFER <= (endline == 1) ? {stop_b, N, CUR_COL, start_b} : {stop_b, 8'h00, start_b};
            2'b01: BUFFER <= {marking, BUFFER[9:1]};
            2'b1X: BUFFER <= BUFFER;
        endcase
    end

    always @(reset_ == 0) #1 CUR_COL <= nero;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (b6)
            1'b0: CUR_COL <= colore;
            1'b1: CUR_COL <= CUR_COL;
        endcase
    end


    always @(posedge clock) if(reset_ == 1) #3 begin
        casex ({b8,b7})
            2'b00: RFD <= 1;
            2'b01: RFD <= 0;
            2'b1X: RFD <= RFD;
        endcase
    end

    always @(reset_ == 0) #1 N <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex ({b10, b9})
            2'b00: N <= (CUR_COL == colore) ? N+1 : N;
            2'b01: N <= (endline == 0) ? 1 : 0;
            2'b1X: N <= N;
        endcase
    end
endmodule

module PC (
    b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c2,c1,c0,
    clock, reset_,
);

    input clock, reset_;
    output b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;
    input c2,c1,c0;

    reg [2:0] STAR;
    localparam
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3,
        S4 = 4;

   assign {b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0} =
        (STAR == S0) ? 11'b1X_00_1_1X_1X_01 : // S0 (Idle): Hold N, Set RFD=1, Mark
        (STAR == S1) ? 11'b00_1X_1_1X_1X_1X : // S1 (Count): Inc N, Hold others
        (STAR == S2) ? 11'b01_1X_0_00_01_1X : // S2 (Load): Load N/Col/Buf, Load 9
        (STAR == S3) ? 11'b1X_1X_1_01_00_00 : // S3 (Tx): Hold N/Col, Shift Buf, Dec Cnt (00), Data
        (STAR == S4) ? 11'b1X_01_1_1X_1X_01 : // S4 (Busy): Set RFD=0, Mark
        /*default*/    11'b1X_00_1_1X_1X_01 ;

     always @(reset_ == 0) #1 STAR <= S0;
     always @(posedge clock) if(reset_ == 1) #3 begin
        casex (STAR)
            S0: STAR <= c0 ? S1 : S0;
            S1: STAR <= c1 ? S4 : S2;
            S3: STAR <= S3;
            S3: STAR <= c2 ? S4 : S3;
            S4: STAR <= c0 ? S4 : S0;
        endcase
    end
endmodule

/*
S0 = 000, S1 = 001, S2 = 010, S3 = 011, S4 = 100

M-addr | b10 b9 b8 b7 b6 b5 b4 b3 b2 b1 b0 | c_eff | M-addr-T | M-addr-F
-------|-----------------------------------|-------|----------|----------
000    | 1   0  0  0  1  1  0  1  0  0  1  | c0    | 001 (S1) | 000 (S0)
001    | 0   0  1  0  1  1  0  1  0  1  0  | c1    | 001 (S1) | 010 (S2)
010    | 0   1  1  0  0  0  0  0  1  1  0  | X     | 011 (S3) | 011 (S3)
011    | 1   0  1  0  1  0  1  0  0  0  0  | c2    | 100 (S4) | 011 (S3)
100    | 1   0  0  1  1  1  0  1  0  0  1  | c0    | 100 (S4) | 000 (S0)

*/





