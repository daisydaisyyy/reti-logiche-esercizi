module ABC (
    colore, endline, dav_, rfd, txd,
    clock, reset_
);


    input clock, reset_;
    input dav_, colore, endline;
    output txd, rfd;

    reg [7:0] N;
    reg [4:0] COUNT;
    reg [9:0] BUFFER;
    reg       RFD, CUR_COL, TXD;

    reg [2:0] STAR;
    localparam S0=0, S1=1, S2=2, S3=3, S4=4;

    // variabili
    localparam marking = 1'B1, start_b = 1'B0, stop_b = 1'B1;
    localparam bianco = 1'B1, nero = 1'B0;

    assign txd = TXD, rfd = RFD;

    always @(reset_ == 0) begin
        CUR_COL <= nero;
        N <= 0;
        TXD <= marking;
        STAR <= S0;
    end

    always @(posedge clock) if(reset == 1) begin
    casex (STAR)
        S0: begin
            RFD <= 1;
            TXD <= marking
            STAR <= (dav_ == 0) ? S1 : S0;
        end

        S1: begin
            N <= (CUR_COL == colore) ? N+1 : N;
            STAR <= (colore == CUR_COL & endline == 0) ? S4 : S2;
        end
        S2: begin
            BUFFER <= (endline == 1) ? {stop_b, N, CUR_COL, start_b} : {stop_b, 8'h00, start_b};
            COUNT <= 9;
            CUR_COL <= colore;
            N <= (endline == 0) ? 1 : 0;
            STAR <= S3;
        end

        S3: begin
            TXD <= BUFFER[0];
            BUFFER <= {marking, BUFFER[9:1]}; // metto il padding
            COUNT <= COUNT - 1; // dec counter
            STAR <= (COUNT == 0) ? S4 : S3;
        end

        S4: begin
            RFD <= 0 // chiudo l'handshake
            STAR <= (dav_ == 0) ? S4 : S0;
        end

    end