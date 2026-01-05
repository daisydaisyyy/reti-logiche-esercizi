module ABC (
    clock, reset_,
    soc, eoc, x, ok,
    ior_, iow_,
    data, addr
);


    input clock, reset_;
    input ok, eoc;
    inout [7:0] data;
    output [7:0] x ;
    output soc, ior_, iow_;
    output [15:0] addr;
    reg SOC;
    assign soc = SOC;
    reg DIR;
    reg IOR_;
    assign ior_ = IOR_;
    reg IOW_;
    assign iow_ = IOW_;
    reg [15:0] ADDR;
    assign addr = ADDR;
    reg [7:0] X;
    assign x = X;
    assign data = (DIR == 1) ? X : 'HZZ; // tri-state
    
    reg [2:0] STAR; 
        localparam 
            S0 = 0,
            S1 = 1,
            S2 = 2,
            S3 = 3,
            S4 = 4,
            S5 = 5,
            S6 = 6,
            S7 = 7;

    always @(reset_ == 0) #1 begin
        X <= 0;
        SOC <= 0;
        IOR_ <= 1;
        IOW_ <= 1;
        DIR <= 0;
        ADDR <= 16'h0ABC;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
        // handshake con A
        S0: begin
            SOC <= 1;
            STAR <= (eoc == 0) ? S1 : S0;
        end
        
        S1: begin
            SOC <= 0;
            STAR <= (eoc == 1) ? S2 : S1;
        end

        S2: begin
            X <= (ok == 1) ? X : (X+1);
            STAR <= (ok == 0) ? S0 : S3;
        end

        S3: begin
            IOR_ <= 0;
            STAR <= S4;
        end

        S4: begin
            IOR_ <= 1;
            STAR <= (data[5] == 0) ? S3 : S5;
        end

        S5: begin
            ADDR <= 16'h0ABD;
            DIR <= 1;
            STAR <= S6;
        end

        S6: begin
            IOW_ <= 0;
            STAR <= S7;
        end

        S7: begin
            IOW_ <= 1;
        end


    endcase
endmodule