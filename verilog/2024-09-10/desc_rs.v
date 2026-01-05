module ABC (
    clock, reset_,
    rxd,
    ow, signal, out
);

    input clock, reset_;
    input rxd;
    output ow, signal;
    output [7:0] out;


    parameter mark = 1;
    parameter space = 0;


    reg [7:0] CUR_BYTE, PREV_BYTE;
    reg [3:0] COUNT_BIT;
    reg [2:0] COUNT_BYTE;
    reg [7:0] OUT;
    reg SIGNAL, OW;
    assign signal = SIGNAL, ow = OW, signal = SIGNAL;
    reg  [1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    wire [7:0] sum;
    wire sum_ow;
    PROSSIMO_S rc(
        .x(CUR_BYTE), .xprev(PREV_BYTE), .s(sum), .ow(sum_ow)
    );




    always @(reset_ == 0) begin
        COUNT_BIT <= 0;
        COUNT_BYTE <= 0;
        PREV_BYTE <= 0;
        CUR_BYTE <= 0;
        STAR <= S0;
    end



    always @(posedge clock) if (reset_ == 1) begin
        casex(STAR) 
            S0: begin
                SIGNAL <= 0;
                OW <= 0;
                STAR <= (rxd == space) ? S1 : S0;
            end
            S1: begin
                COUNT_BIT <= COUNT_BIT + 1;
                STAR <= (rxd == space) ? S1 : S2;
            end
            S2: begin
                COUNT_BIT <= 0;
                COUNT_BYTE <= COUNT_BYTE + 1;
                CUR_BYTE <= {~COUNT_BIT[3], CUR_BYTE[7:1]}; // aggiungo ultimo bit ricevuto, = 0 se ho aspettato > 7 cicli, = 1 altrimenti
                STAR <= (COUNT_BYTE == 7) ? S3 : S0;
            end
            S3: begin
                OUT <= sum;
                STAR <= S4;
            end
            S4: begin
                SIGNAL <= ~sum_ow;
                OW <= sum_ow;
                COUNT_BIT <= 0;
                COUNT_BYTE <= 0;
                CUR_BYTE <= 0;
                PREV_BYTE <= sum_ow ? 0 : CUR_BYTE;
                STAR <= S0;
            end
        endcase
    end
endmodule