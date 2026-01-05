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

reg SOC;
assign soc = SOC;

reg DAV_;
assign dav_ = DAV_;

reg [31:0] Q;
assign q = Q;

wire [17:0] rc_result;
QUADRATO_DELLA_SOMMA rc(
    .x(x), .y(y), .q(rc_result)
);

reg [1:0] STAR;
localparam
    S0 = 0,
    S1 = 1,
    S2 = 2,
    S3 = 3;

always @(reset_ == 0) #1
    begin
        DAV_ <= 1;
        SOC <= 0;
        STAR <= S0;
    end

always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0:
            begin
                SOC <= 1;
                STAR <= (eocx == 0 & eocy == 0) ? S1 : S0;
            end
        S1:
            begin
                SOC <= 0;
                Q <= {14'b0, rc_result}; // risultato esteso a 32 bit
                STAR <= (eocx == 1 & eocy == 1) ? S2 : S1;
            end
        S2:
            begin
                DAV_ <= 0; // invio al consumatore
                STAR <= (rfd == 0) ? S3 : S2;
            end
        S3:
            begin
                DAV_ <= 1; // ho inviato il dato, non e' piu' available
                STAR <= (rfd == 1) ? S0 : S3; // pronto per ricevere nuovi dati?
            end
        endcase
endmodule


