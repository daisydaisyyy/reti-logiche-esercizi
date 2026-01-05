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

    reg SOC, OUT;
    reg [7:0] X2,X1,X0;
    reg [2:0] MJR;
    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S_in0 = 4, S_in1 = 5, S_in2 = 6;

    assign soc = SOC;
    assign out = OUT;


    always @(reset_ == 0) begin
        SOC = 0;
        OUT = 0;
        STAR = S0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex (STAR)
            S0: begin
                OUT <= 0;
                STAR <= S_in0;
                MJR <= S1;
            end

            S1: begin
                X2 <= X0;
                STAR <= S_in0;
                MJR <= S2;
            end

            S2: begin
                X1 <= X0;
                STAR <= S_in0;
                MJR <= S3;
            end

            S3: begin
                OUT <= ({X2+X1+X0} >= 164) ? 1 : 0;
                STAR <= S0;
            end

            S_in0: begin
                SOC <= 1; // inizio handshake con il produttore
                STAR <= (eoc == 0) ? S_in1 : S_in0;
            end

            S_in1: begin
                SOC <= 0;
                STAR <= (eoc == 1) ? S_in2 : S_in1;  // fine handshake con il produttore
            end

            S_in2: begin
                X0 <= x;
                STAR <= MJR; // ritorno
            end

        endcase
    end

endmodule