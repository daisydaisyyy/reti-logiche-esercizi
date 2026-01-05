module ABC (
    clock, reset_,
    rxd,
    ow, signal, out,
    
);

    input clock, reset_;
    input rxd;
    output ow, signal;
    output [7:0] out;
    wire b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;
    wire c1,c0;

    ABC_PO po(
        clock, reset_, rxd,
        ow, signal, out,
        b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c1,c0
    );

    ABC_PC pc(
        clock, reset_,
        b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c1,c0
    );
endmodule


module ABC_PO (
    clock, reset_, rxd,
    ow, signal, out,
    b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c1,c0
);

    input clock, reset_;
    input rxd;
    output ow, signal;
    output [7:0] out;

    reg [7:0] CUR_BYTE, PREV_BYTE;
    reg [3:0] COUNT_BIT;
    reg [2:0] COUNT_BYTE;
    reg [7:0] OUT;
    reg SIGNAL, OW;
    assign signal = SIGNAL, ow = OW, signal = SIGNAL;
    wire [7:0] sum;
    wire sum_ow;

    input b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;
    output c1,c0;

    assign #1 c0 = ~rxd; // rxd == space
    assign #1 c1 = COUNT_BYTE == 7; // COUNT_BYTE == 7

    PROSSIMO_S rc(
        .x(CUR_BYTE), .xprev(PREV_BYTE), .s(sum), .ow(sum_ow)
    );

    // count bit
    always @(reset_ == 0) begin
        COUNT_BIT <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex({b1,b0})
            2'b0X: begin // S2, S4
                COUNT_BIT <= 0;
            end

            2'b10: begin // S1
                COUNT_BIT <= COUNT_BIT + 1;
            end

            2'b11: begin
                COUNT_BIT <= COUNT_BIT;
            end
        endcase
    end

    // count byte
    always @(reset_ == 0) begin
        COUNT_BYTE <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex({b3,b2})
            2'b00: begin  // S2
                COUNT_BYTE <= COUNT_BYTE + 1;
            end
            2'b01: begin // S4
                COUNT_BYTE <= 0;
            end
            2'b1X: begin
                COUNT_BYTE <= COUNT_BYTE;
            end


        endcase
    end

    // prev  byte
    always @(reset_ == 0) begin
        PREV_BYTE <= 0;
    end


    always @(posedge clock) if (reset_ == 1) begin
        casex(b4)
            1'b0: begin // S4
                PREV_BYTE <= sum_ow ? 0 : CUR_BYTE;
            end
            1'b1: begin
                PREV_BYTE <= PREV_BYTE;
            end
        endcase
    end

    // cur byte
    always @(reset_ == 0) begin
        CUR_BYTE <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex({b6,b5})
            2'b00: begin // s2
                CUR_BYTE <= {~COUNT_BIT[3], CUR_BYTE[7:1]}; // aggiungo ultimo bit ricevuto, = 0 se ho aspettato > 7 cicli, = 1 altrimenti
            end
            2'b01: begin // s4
                CUR_BYTE <= 0;
            end
            2'b1X: begin
                CUR_BYTE <= CUR_BYTE;
            end
        endcase
    end

    // signal
    always @(posedge clock) if (reset_ == 1) begin
        casex({b8,b7})
            2'b00: begin // s0
                SIGNAL <= 0;
            end
            2'b01: begin // s4
                SIGNAL <= ~sum_ow;
            end
            2'b1X: begin
                SIGNAL <= SIGNAL;
            end
        endcase
    end

    // ow
    always @(posedge clock) if (reset_ == 1) begin
        casex({b10,b9})
            2'b00: begin // s0
                OW <= 0;
            end
            2'b01: begin // s4
                OW <= sum_ow;
            end
            2'b1X: begin
                OW <= OW;
            end
        endcase
    end


    // out
    always @(posedge clock) if (reset_ == 1) begin
        casex(b11)
            1'b0: begin // s3
                OUT <= sum;
            end
            1'b1: begin
                OUT <= OUT;
            end
        endcase
    end

endmodule


module ABC_PC (
    clock, reset_,
    b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c1,c0
);
    input clock, reset_;
    input c1,c0;
    output b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0;

    // STAR
    reg  [1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    assign #1 {b11,b10,b9,b8,b7,b6,b5,b4,b3,b2,b1,b0} =
        (STAR == S0) ? 12'b100001X11X11 :
        (STAR == S1) ? 12'b100001X11X10 :
        (STAR == S2) ? 12'b11X1X001000X :
        (STAR == S3) ? 12'b01X1X1X11X11 :
        (STAR == S4) ? 12'b10101010010X :
        12'b11X1X1X11X11;

    always @(reset_ == 0) begin
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex(STAR)
            S0: begin
                STAR <= (c0) ? S1 : S0;
            end
            S1: begin
                STAR <= (c0) ? S1 : S2;
            end
            S2: begin
                STAR <= (c1) ? S3 : S0;
            end
            S3: begin
                STAR <= S4;
            end
            S4: begin
                STAR <= S0;
            end
        endcase
    end
endmodule



