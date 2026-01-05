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


    reg [2:0] STAR;
    reg DAV_, SOC;
    reg [1:0] T;
    
    assign soc_x = SOC;
    assign soc_y = SOC;
    assign dav_ = DAV_;
    assign t = T;

    reg [3:0] BUFFER;

    wire match;
    wire [1:0] match_type;

    localparam
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3,
        S4 = 4,
        S5 = 5;

    MATCH_SEQ rc (
        .buffer(BUFFER), .match(match), .match_type(match_type)
    );


    always @ (reset_ == 0) #1 begin
        BUFFER = 0;
        SOC = 0;
        DAV_ = 1;
        STAR = S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
        casex(STAR)
            S0:
                begin
                    SOC <= 1;
                    STAR <= (eoc_x == 0 & eoc_y == 0) ? S1 : S0;
                end
            S1:
                begin
                    SOC <= 0;
                    STAR <= (eoc_x == 1 & eoc_y == 1) ? S2 : S1;
                end
            S2:
                begin
                    BUFFER <= {BUFFER[3:0], x ^ y};
                    STAR <= S3;
                end
            S3:
                begin
                    T <= match_type;
                    STAR <= (match) ? S4 : S0;
                end
            S4:
                begin
                    DAV_ <= 0;
                    STAR <=  (rfd == 0) ? S5 : S4;
                end

            S5:
                begin
                    DAV_ <= 1;
                    STAR <= (rfd == 1) ? S0 : S5;
                end
        endcase
    endmodule

