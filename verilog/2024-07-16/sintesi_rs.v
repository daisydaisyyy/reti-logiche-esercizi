module ABC(
    clock, reset_,
    soc, eoc,
    x, out
);


    input clock, reset_;
    input [7:0] x;
    input eoc;
    output soc;
    output out;

    // wire var comando
    wire b8,b7,b6,b5,b4,b3,b2,b1,b0;
    // wire var condizionamento
    wire c0;
    // mjr
    wire [2:0] mjr;


    ABC_PO po(
        clock, reset_,
        soc, eoc,
        x, out,
        mjr,
        b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c0
    );


    ABC_PC pc(
        clock, reset_,
        mjr,
        b8,b7,b6,b5,b4,b3,b2,b1,b0,
        c0
    );

endmodule


module ABC_PO (
    clock, reset_,
    soc, eoc,
    x, out,
    mjr,
    b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c0
);

    input clock, reset_;
    input [7:0] x;
    input eoc;
    output soc;
    output out;
    output [2:0] mjr;

    input b8,b7,b6,b5,b4,b3,b2,b1,b0;
    output c0;

    reg SOC, OUT;
    reg [7:0] X2,X1,X0;
    reg [2:0] MJR;
  
    assign soc = SOC;
    assign out = OUT;
    assign mjr = MJR;

    assign c0 = eoc;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S_in0 = 4, S_in1 = 5, S_in2 = 6;

    // SOC
    always @(reset_ == 0) begin
        SOC = 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex ({b1,b0})
            2'b00: begin // S_in0
                SOC <= 1; // inizio handshake con il produttore
            end

            2'b01: begin // S_in1
                SOC <= 0;
            end

            2'b1X: begin
                SOC <= SOC;
            end
        endcase
    end



    // OUT
      always @(reset_ == 0) begin
        OUT = 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex ({b3,b2})
            2'b00: begin // S0
                OUT <= 0;
            end
            2'b01: begin // S3
                OUT <= ({1'b0, X2} + {1'b0, X1} + {1'b0, X0} >= 9'd164) ? 1 : 0;
            end

            2'b1X: begin
                OUT <= OUT;
            end
        endcase
    end

    // MJR
    always @(posedge clock) if (reset_ == 1) begin
        casex ({b5,b4})
            2'b00: begin // S0
                MJR <= S1;
            end

            2'b01: begin // S1
                MJR <= S2;
            end

            2'b10: begin // S2
                MJR <= S3;
            end

            2'b11: begin
                MJR <= MJR;
            end
        endcase
    end

    // X0
    always @(posedge clock) if (reset_ == 1) begin
        casex (b6)
            1'b1: begin // S_in2
                X0 <= x;
            end

            1'b0: begin
                X0 <= X0;
            end

        endcase
    end


    // X1
    always @(posedge clock) if (reset_ == 1) begin
        casex (b7)
            1'b1: begin // S2
                X1 <= X0;
            end

            1'b0: begin
                X1 <= X1;
            end


        endcase
    end

    // X2
    always @(posedge clock) if (reset_ == 1) begin
        casex (b8)
            1'b1: begin // S1
                X2 <= X0;
            end

            1'b0: begin
                X2 <= X2;
            end


        endcase
    end

endmodule



module ABC_PC (
    clock, reset_,
    mjr,
    b8,b7,b6,b5,b4,b3,b2,b1,b0,
    c0
);
    input clock, reset_;
    input [2:0] mjr;

    input c0;
    output b8,b7,b6,b5,b4,b3,b2,b1,b0;


    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S_in0 = 4, S_in1 = 5, S_in2 = 6;

    assign {b8,b7,b6,b5,b4,b3,b2,b1,b0} =
        (STAR == S0) ? 9'b00000001X :
        (STAR == S1) ? 9'b100011X1X :
        (STAR == S2) ? 9'b010101X1X :
        (STAR == S3) ? 9'b00011011X :
        (STAR == S_in0) ? 9'b000111X00 :
        (STAR == S_in1) ? 9'b000111X01 :
        (STAR == S_in2) ? 9'b001111X1X :
        9'b000111X1X;

    always @(reset_ == 0) begin
        STAR = S0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex (STAR)
            S0: begin
                STAR <= S_in0;
            end

            S1: begin
                STAR <= S_in0;
            end

            S2: begin
                STAR <= S_in0;
            end

            S3: begin
                STAR <= S0;
            end

            S_in0: begin
                STAR <= c0 ? S_in0 : S_in1;
            end

            S_in1: begin
                STAR <= c0 ? S_in2 : S_in1;  // fine handshake con il produttore
            end

            S_in2: begin
                STAR <= mjr; // ritorno
            end

        endcase
    end

endmodule



/*
ROM

M-addr      |   m-code      | M-addr-T  | M-addr-F  | M-type
000 (S0)    |   00000001X   |   100     |   100     |   0
001 (S1)    |   100011X1X   |   100     |   100     |   0
010 (S2)    |   010101X1X   |   100     |   100     |   0
011 (S3)    |   00011011X   |   000     |   000     |   0
100 (S_in0) |   000111X00   |   100     |   101     |   0
101 (S_in1) |   000111X01   |   110     |   101     |   0
110 (S_in2) |   001111X1X   |   XXX     |   XXX     |   1

 */