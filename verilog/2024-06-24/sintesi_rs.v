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


    wire b5,b4,b3,b2,b1,b0;
    wire c2,c1,c0;

    ABC_PO po(
        clock, reset_,
        vx,vy,
        eoc_vx, eoc_vy,
        soc_p,
        x, y,
        soc_vx, soc_vy,
        eoc_p,
        b5,b4,b3,b2,b1,b0,
        c2,c1,c0
    );

    ABC_PC pc(
        clock, reset_,
        b5,b4,b3,b2,b1,b0,
        c2,c1,c0
    );


endmodule

module ABC_PO (
    clock, reset_,
    vx,vy,
    eoc_vx, eoc_vy,
    soc_p,
    x, y,
    soc_vx, soc_vy,
    eoc_p,
    b5,b4,b3,b2,b1,b0,
    c2,c1,c0

);
    input clock, reset_;
    input [3:0] vx,vy;
    input eoc_vx, eoc_vy;
    input soc_p;
    output [7:0] x, y;
    output soc_vx, soc_vy;
    output eoc_p;

    input b5,b4,b3,b2,b1,b0;
    output c2,c1,c0;

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

    assign c0 = (soc_p == 1);
    assign c1 = ({eoc_vx, eoc_vy} == 2'b00);
    assign c2 = ({eoc_vx, eoc_vy} == 2'b11);

    PROSSIMA_POSIZIONE rc(
        .cur_x(X), .cur_y(Y), .vx(vx), .vy(vy), .next_x(next_x), .next_y(next_y)
    );


    // X
    always @(reset_ == 0) begin
        X <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex (b0)
            1'b0: begin //  S4
                X <= next_x;
            end
            1'b1: begin
                X <= X;
            end
        endcase
    end


    // Y
    always @(reset_ == 0) begin
        Y <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex (b1)
            1'b0: begin // S4
                Y <= next_y;
            end
            1'b1: begin
                Y <= Y;
            end
        endcase
    end


    // EOC
    always @(reset_ == 0) begin
        EOC <= 1;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex ({b3,b2})
            2'b00: begin // S1
                EOC <= 0;
            end

            2'b01: begin // S5
                EOC <= 1;
            end

            2'b1X: begin
                EOC <= EOC;
            end
        endcase
    end

    // SOC_V
    always @(reset_ == 0) begin
        SOC_V <= 0;
    end

    always @(posedge clock) if (reset_ == 1) begin
        casex ({b5,b4})
            2'b00: begin // S2
                SOC_V <= 1'b1;
            end

            2'b01: begin // S3
                SOC_V <= 1'b0;
            end

            2'b1X: begin
                SOC_V <= SOC_V;
            end
        endcase
    end


endmodule


module ABC_PC (
    clock, reset_,
    b5,b4,b3,b2,b1,b0,
    c2,c1,c0
);

    input clock, reset_;
    input c2,c1,c0;
    output b5,b4,b3,b2,b1,b0;

    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;

    assign {b5,b4,b3,b2,b1,b0} =
        (STAR == S0) ? 6'b1X1X11 :
        (STAR == S1) ? 6'b1X0011 :
        (STAR == S2) ? 6'b001X11 :
        (STAR == S3) ? 6'b011X11 :
        (STAR == S4) ? 6'b1X1X00 :
        (STAR == S5) ? 6'b1X0111 :
        6'b1X1X11;

   always @(reset_ == 0) begin
        STAR <= S0;
    end



    always @(posedge clock) if (reset_ == 1) begin
        casex (STAR)
            S0: begin
                STAR <= (c0) ? S1 : S0;
            end

            S1: begin
                STAR <= (~c0) ? S2 : S1;
            end

            S2: begin
                STAR <= c1 ? S3 : S2;
            end

            S3: begin
                STAR <= c2 ? S4 : S3;
            end

            S4: begin
                STAR <= S5;
            end

            S5: begin
                STAR <= S0;
            end
        endcase
    end

endmodule