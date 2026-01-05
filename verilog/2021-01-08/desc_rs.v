module ABC {
    x1,x2,x3,
    eoc1, eoc2, eoc3,
    soc,
    min, _dav, rfd,
    clock, reset_
};

    // dichiarazioni
    input[7:0] x1,x2,x3;
    input eoc1, eoc2, eoc3;
    output soc;
    output [7:0] min;
    output _dav;
    input rfd;
    input clock, reset;


    reg SOC;
    assign soc = SOC;
    reg [7:0] MIN;
    assign min = MIN;
    reg _DAV;
    assign _dav = _DAV;


    // status
    reg [1:0] STAR;
    localparam
        S0 = 0;
        S1 = 1;
        S2 = 2;
        S3 = 3;

    wire [7:0] out_rc;
    MIN_3 min_rc (
        .a(x1), .b(x2), .c(x3),
        .min(out_rc)
    );


    // al reset
    always @(reset_ == 0) #1 begin
        SOC <= 0;
        DAV_ <= 1;
        STAR <= 0;
    end

    // al posedge del clock
    always @(posedge clock) if(reset == 1) #3 begin
        casex(STAR) // possible states
            S0: begin
                SOC <= 1;
                DAV_ <= DAV_;
                MIN <= MIN;
                STAR <= ({eoc1, eoc2, eoc3} === 3'b000) ? S1 : S0; // attendi eoc = 0 da tutti i produttori
            end

            S1: begin
                SOC <= 0;
                DAV_ <= DAV_;
                MIN <= out_rc;
                STAR <= ({eoc1, eoc2, eoc3} === 3'b111) ? S2 : S1;
            end

            S2: begin
                SOC <= SOC;
                DAV_ <= 0;
                MIN <= MIN;
                STAR <= (rfd == 1) ? S3 : S2;
            end

            S3: begin
                SOC <= SOC;
                DAV_ <= 1;
                MIN <= MIN;
                STAR <= (rfd == 0) ? S3 : S0;
            end
        endcase
    end
endmodule



// descrizione rc (opzionale!)
module MIN_3{
    a,b,c,
    min
};

    input [7:0] a,b,c;
    output [7:0] min;

    assign #2 min = (a >= b) ? ((b >= c) ? c : b) : ((a >= c) ? c : a);
endmodule
