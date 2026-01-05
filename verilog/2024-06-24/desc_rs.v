module ABC (
    clock, reset_,
    vx,vy,
    eoc_vx, eoc_vy,
    soc_p,
    x, y,
    soc_vx, soc_vy,
    eoc_p
);

    input clock, reset_;
    input [3:0] vx,vy;
    input eoc_vx, eoc_vy;
    input soc_p;
    output [7:0] x, y;
    output soc_vx, soc_vy;
    output eoc_p;

    reg [7:0] X,Y;
    reg EOC;
    reg SOC_V;

    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;

    assign soc_vx = SOC_V;
    assign soc_vy = SOC_V;
    assign eoc_p = EOC;
    assign x = X; 
    assign y = Y;
    wire [7:0] next_x;
    wire [7:0] next_y;

    PROSSIMA_POSIZIONE rc(
        .cur_x(X), .cur_y(Y), .vx(vx), .vy(vy), .next_x(next_x), .next_y(next_y)
    );


    always @(reset_ == 0) begin
        X <= 0; Y <= 0;
        EOC <= 1;
        SOC_V <= 0;
        STAR <= S0;
    end


    always @(posedge clock) if (reset_ == 1) begin
        casex (STAR)
            S0: begin
                STAR <= (soc_p == 1) ? S1 : S0;
            end

            S1: begin
                EOC <= 0;
                STAR <= (soc_p == 0) ? S2 : S1;
            end

            S2: begin
                SOC_V <= 1;
                STAR <= ({eoc_vx, eoc_vy} == 2'b00) ? S3 : S2;
            end

            S3: begin
                SOC_V <= 0;
                STAR <= ({eoc_vx, eoc_vy} == 2'b11) ? S4 : S3;
            end

            S4: begin
                X <= next_x;
                Y <= next_y;
                STAR <= S5;
            end

            S5: begin
                EOC <= 1;
                STAR <= S0;
            end
        endcase
    end

endmodule