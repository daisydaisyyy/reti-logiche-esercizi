module ABC (
    output [15:0] addr,
    inout  [7:0] data,
    input  clock, reset_,
    output ior_, iow_
);
    wire [7:0] b;
    wire c0;

    ABC_PO PO (
        .addr(addr), .data(data),
        .ior_(ior_), .iow_(iow_),
        .b(b),
        .c0(c0),
        .clock(clock), .reset_(reset_)
    );

    ABC_PC PC (
        .b(b),
        .c0(c0),
        .clock(clock), .reset_(reset_)
    );

endmodule

// ============================================================================
// PARTE OPERATIVA
// ============================================================================
module ABC_PO (
    output [15:0] addr,
    inout  [7:0] data,
    output ior_, iow_,

    input  [7:0] b,
    output c0,
    input  clock, reset_
);

    wire [1:0] cmd_data = b[7:6];
    wire       cmd_a    = b[5];
    wire       cmd_dir  = b[4];
    wire       cmd_iow  = b[3];
    wire       cmd_ior  = b[2];
    wire [1:0] cmd_addr = b[1:0];

    reg IOW_, IOR_, DIR;
    reg [15:0] ADDR;
    reg [7:0] DATA;
    reg [7:0] A;

    assign addr = ADDR;
    assign ior_ = IOR_;
    assign iow_ = IOW_;
    assign data = (DIR == 1) ? DATA : 8'bZZ; // Tri-state

    assign c0 = data[0];

    // --- ALU ---
    wire [15:0] mul;
    MUL5 m5 (.a(A), .m(mul));

    // ADDR
    always @(reset_ == 0) #1 ADDR <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_addr)
            2'b00: ADDR <= ADDR;
            2'b01: ADDR <= 16'h0100;
            2'b10: ADDR <= 16'h0101;
            2'b11: ADDR <= 16'h0121;
        endcase
    end

    // IOR_
    always @(reset_ == 0) #1 IOR_ <= 1;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_ior)
            1'b0: IOR_ <= 1;
            1'b1: IOR_ <= 0;
        endcase
    end

    // IOW_
    always @(reset_ == 0) #1 IOW_ <= 1;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_iow)
            1'b0: IOW_ <= 1;
            1'b1: IOW_ <= 0;
        endcase
    end

    // DIR
    always @(reset_ == 0) #1 DIR <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_dir)
            1'b0: DIR <= 0;
            1'b1: DIR <= 1;
        endcase
    end

    // A
    always @(reset_ == 0) #1 A <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_a)
            1'b0: A <= A;
            1'b1: A <= data;
        endcase
    end

    // DATA
    always @(reset_ == 0) #1 DATA <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (cmd_data)
            2'b00: DATA <= DATA;
            2'b01: DATA <= mul[15:8];
            2'b10: DATA <= mul[7:0];
            2'b11: DATA <= DATA;
        endcase
    end
endmodule

module ABC_PC (
    output [7:0] b,
    input  c0,
    input  clock, reset_
);

    reg [3:0] STAR;

    // Stati
    localparam SA_0=0, SA_1=1, SA_2=2, SA_3=3, SA_4=4, SA_5=5,
               SB_0=6, SB_1=7, SB_2=8, SB_3=9, SB_4=10, SB_5=11;

    assign #1 b =
        (STAR == SA_0) ? 8'b00____0____0____0____0____01 :
        (STAR == SA_1) ? 8'b00____0____0____0____1____00 :
        (STAR == SA_2) ? 8'b00____0____0____0____0____00 :
        (STAR == SA_3) ? 8'b00____0____0____0____0____10 :
        (STAR == SA_4) ? 8'b00____0____0____0____1____00 :
        (STAR == SA_5) ? 8'b00____1____0____0____0____00 :
        (STAR == SB_0) ? 8'b01____0____1____0____0____11 :
        (STAR == SB_1) ? 8'b00____0____1____1____0____00 :
        (STAR == SB_2) ? 8'b00____0____1____0____0____00 :
        (STAR == SB_3) ? 8'b10____0____1____0____0____00 :
        (STAR == SB_4) ? 8'b00____0____1____1____0____00 :
        (STAR == SB_5) ? 8'b00____0____0____0____0____00 :
        /*default*/      8'b00____0____0____0____0____00 ;

    always @(reset_ == 0) #1 STAR <= SA_0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex (STAR)
            SA_0: STAR <= SA_1;
            SA_1: STAR <= SA_2;

            SA_2: STAR <= (c0) ? SA_3 : SA_0;

            SA_3: STAR <= SA_4;
            SA_4: STAR <= SA_5;
            SA_5: STAR <= SB_0;

            SB_0: STAR <= SB_1;
            SB_1: STAR <= SB_2;
            SB_2: STAR <= SB_3;
            SB_3: STAR <= SB_4;
            SB_4: STAR <= SB_5;
            SB_5: STAR <= SA_0;

            default: STAR <= SA_0;
        endcase
    end

endmodule


/*
M-addr" STAR
CODIFICA STATI:
SA_0=0000, SA_1=0001, SA_2=0010, SA_3=0011, SA_4=0100, SA_5=0101
SB_0=0110, SB_1=0111, SB_2=1000, SB_3=1001, SB_4=1010, SB_5=1011

CODIFICA CONDIZIONI (c_eff):
00 = Incondizionato
01 = Check c0

CODIFICA COMANDI (b7...b0):
b7,b6 : Data Mux (00=Hold, 01=High, 10=Low)
b5    : Load A
b4    : DIR (1=Output)
b3    : IOW (1=Active)
b2    : IOR (1=Active)
b1,b0 : ADDR Mux (01=100h, 10=101h, 11=121h)

M-addr | b7,b6, b5, b4, b3, b2, b1,b0 | c_eff | M-addr-T | M-addr-F
-------------------------------------------------------------------
0000   | 00000001                     | 00    | 0001     | 0001
0001   | 00000100                     | 00    | 0010     | 0010
0010   | 00000000                     | 01    | 0011     | 0000 # condizione SA_2: STAR <= (c0) ? SA_3 : SA_0;
0011   | 00000010                     | 00    | 0100     | 0100
0100   | 00000100                     | 00    | 0101     | 0101
0101   | 00100000                     | 00    | 0110     | 0110
0110   | 01010011                     | 00    | 0111     | 0111
0111   | 00011000                     | 00    | 1000     | 1000
1000   | 00010000                     | 00    | 1001     | 1001
1001   | 10010000                     | 00    | 1010     | 1010
1010   | 00011000                     | 00    | 1011     | 1011
1011   | 00000000                     | 00    | 0000     | 0000


*/