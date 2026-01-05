module ABC (
    addr, data, ior_, iow_,
    clock, reset_
);

    input [7:0] data;
    output [15:0] addr;
    output ior_, iow_;
    input clock, reset_;


    reg IOW_, IOR_;
    assign ior_ = IOR_;
    assign iow_ = IOW_;

    reg [15:0] ADDR;
    assign addr = ADDR;


    reg DIR;
    reg [7:0] DATA;
    assign data = (DIR == 1) ? DATA : 8'bZZ;

    reg [3:0] STAR;


    // states
    localparam
        SA_0 = 0,
        SA_1 = 1,
        SA_2 = 2,
        SA_3 = 3,
        SA_4 = 4,
        SA_5 = 5,
        SB_0 = 6,
        SB_1 = 7,
        SB_2 = 8,
        SB_3 = 9,
        SB_4 = 10,
        SB_5 = 11;

    reg [7:0] A;
    wire [15:0] mul;
    MUL5 m5 (
        .a(A), .m(mul)
    );

    always @(reset == 0) #1 begin
        IOR_ <= 1;
        IOW_ <= 1;
        DIR <= 0;
        STAR <= SA_0;
        A <= 0;
    end

    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (STAR)
            // handshake su A implementato con RBR, RSR (polling di RSR finche' il bit di data non e' 1 (cioe' FI=1), a quel punto prendo il dato da RBR)
            // lettura da RSR ( dice se c'e' un dato)
            SA_0: begin
                ADDR <= 16'h0100; // offset
                DIR <= 0;
                STAR <= SA_1;
            end
            SA_1: begin
                IOR_ <= 0;
                STAR <= SA_2;
            SA_2: begin
                IOR_ <= 1;
                STAR <= (data[0]) ? SA_3 : SA_0; // controllo FI (cioe' se il dato esiste, altrimenti torno in S0)
            end
            // lettura da RBR (RBR contiene il dato effettivo)
            SA_3: begin
                ADDR <= 16'h0101;
                STAR <= SA_4;
            end
            SA_4: begin
                IOR_ <= 0;
                STAR <= SA_5
            end
            SA_5: begin // vado negli stati di B dove scrivo in output usando TBR
                A <= data;
                IOR_ <= 1
                STAR <= SB_0
            end


            SB_0: begin
                DATA <= mul[15:8]
                ADDR <= 16'h00121
                DIR <= 1;
                STAR <= SB_1;
            end
            SB_1: begin
                IOW_ <= 0; // scrivo il primo byte
                STAR <= SB_2;
            end

            SB_2: begin
                IOW_ <= 1;
                STAR <= SB_3;
            end

            SB_3: begin
                DATA <= mul[7:0];
                STAR <= SB_4;
            end

            SB_4: begin
                IOW_ <= 0;
                STAR <= SB_5;
            end

            SB_5: begin
                IOW_ <= 1;
                STAR <= SA_0;
            end
        endcase
    end
endmodule