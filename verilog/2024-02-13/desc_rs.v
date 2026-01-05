module ABC (
    soc_x, eoc_x, x, 
    soc_y, eoc_y, y,
    reset_, clock,
    dav_, rfd, result, z
);
    input clock, reset_;
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input [7:0] x;
    input [7:0] y;
    output dav_;
    output result;
    input rfd;

    reg [1:0] STAR;
    reg DAV_;
    assign dav_ = DAV_;
    reg SOC;
    assign soc_x = SOC;
    assign soc_y = SOC;
    output z;

    reg RES;
    assign z = RES;
    wire result;


    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) begin
        SOC <= 0;
        DAV_ <= 1;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex(STAR)
            S0: begin
                SOC <= 1;
                STAR <= ({eoc_x, eoc_y} == 2'b00) ? S1 : S0;
            end

            S1: begin
                RES <= result;
                SOC <= 0;
                STAR <= ({eoc_x, eoc_y} == 2'b11) ? S2 : S1;
            end

            S2: begin
                DAV_ <= 0;
                STAR <= (rfd == 1) ? S3 : S2;
            end

            S3: begin
                DAV_ <= 1;
                STAR <= (rfd == 0) ? S0 : S3;
            end
        endcase
    end

    IN_AREA rc(
        .x(x), .y(y), .z(result)
    );


endmodule