// https://rzippo.github.io/reti-logiche-esercitazioni/esercitazioni/Verilog/Esercitazioni/Esercitazione%204#esercizio-41-sintesi-di-rete-sincronizzata


    // 1. per ogni registro scrivo gli stati e gli assegnamenti
    /* 2. variabili di comando (sostituisco le condizioni con STAR (stati) con condizioni basate sulle var di comando)
        star, soc: 1,0 e conservazione
        min: campionamento di rc_out e conservazione
        esempio con soc:
        // soc con aggiunte le variabili di comando, poi rimuovo gli stati
        always @(reset_ == 0) #1 SOC <= 0;
        // al posedge del clock
        always @(posedge clock) if(reset_ == 1) #3 begin
            casex(STAR) // possible states
                2'b00 S0:SOC <= 1;
                2'b01 S1:SOC <= 0;
                2'b1X S2:SOC <= SOC;
                2'b1X S3:SOC <= SOC;
            endcase
        end

        // aggiungo i wire per le variabili di comando
       3. variabili di condizionamento
        modifica la parte del registro star
        // STAR
    always @(reset__ == 0) #1 STAR <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex(STAR)
            S0:STAR <= ({eoc1, eoc2, eoc3} == 3'b000) ? S1 : S0;
            S1:STAR <= ({eoc1, eoc2, eoc3} == 3'b111) ? S2 : S1;
            S2:STAR <= (rfd == 1) ? S2 : S3; // is ready for data
            S3:STAR <= (rfd == 0) ? S0 : S3;
        endcase
    end


        // variabili di condizionamento:
        wire c2,c1,c0; // c1, c0 per le end of computation, c2 per ready for data
            assign #1 c0 = {eoc1, eoc2, eoc3} == 3'b000;
            assign #1 c1 = {eoc1, eoc2, eoc3} == 3'b111;
            assign #2 c2 = rfd == 1;
        poi le sostituisco con le espressioni algebriche
            assign #1 c0 = ~eoc1 & ~eoc2 & ~eoc3;
            assign #1 c1 = eoc1 & eoc2 & eoc3;
            assign #2 c2 = rfd;


        4. separare parte operativa e parte controllo 
            - parte op: reg op, rc che ne pilotano gli ingressi, rc che generano le variabili di condizionamento,
                        collegamenti (wire) input e output della rete complessiva)
            - parte controllo: STAR e ROM a microindirizzi
        5. scrivere la tabella della ROM (parte che genera le variabili di controllo)


    */


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
    input clock, reset_;

    wire b4, b3, b2, b1, b0;
    wire c2,c1,c0; // c1, c0 per le end of computation, c2 per ready for data

    ABC_PO (
        x1,x2,x3,
        eoc1, eoc2, eoc3,
        soc,
        min, dav_, rfd,
        b4,b3,b2,b1,b0,
        c2,c1,c0,
        clock, reset_,
    );


    ABC_PC (
        b4,b3,b2,b1,b0,
        c2,c1,c0,
        clock, reset_,
    )

endmodule

module ABC_PO (
    x1,x2,x3,
    eoc1, eoc2, eoc3,
    soc,
    min, dav_, rfd,
    b4,b3,b2,b1,b0,
    c2,c1,c0,
    clock, reset_,
)

     input[7:0] x1,x2,x3;
    input eoc1, eoc2, eoc3;
    output soc;
    output [7:0] min;
    output _dav;
    input rfd;
    input clock, reset_;

    reg SOC;
    assign soc = SOC;
    reg [7:0] MIN;
    assign min = MIN;
    reg _DAV;
    assign _dav = _DAV;

    wire [7:0] out_rc;
    MIN_3 min_rc (
        .a(x1), .b(x2), .c(x3),
        .min(out_rc)
    );

    input b4,b3,b2,b1,b0;
    output c2,c1,c0;

    assign #1 c0 = ~eoc1 & ~eoc2 & ~eoc3;
    assign #1 c1 = eoc1 & eoc2 & eoc3;
    assign #2 c2 = rfd;
    
    // SOC
    always @(reset_ == 0) #1 SOC <= 0;
        // al posedge del clock
        always @(posedge clock) if(reset_ == 1) #3 begin
            casex({b1, b0}) // possible states
                2'b00: SOC <= 1;
                2'b01: SOC <= 0;
                2'b1X: SOC <= SOC;
            endcase
        end

    // DAV
    always @(reset_ == 0) #1 DAV_ <= 1;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex({b3,b2})
            2'b00: DAV_ <= DAV_;
            2'b01: DAV_ <= 0;
            2'b1X: DAV_ <= 1;
        endcase
    end


    // MIN
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex(STAR)
            1'b0: MIN <= MIN;
            1'b1:MIN <= out_rc;
        endcase
    end

endmodule



module ABC_PC (
 b4,b3,b2,b1,b0,
    c2,c1,c0,
    clock, reset_,
);

    input clock, reset_;

    input c2,c1,c0;
    output b4,b3,b2,b1,b0;

    reg [1:0] STAR;
    localparam
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3;


    assign #1 {b4, b3, b2, b1, b0} =
        (STAR == S0) ? 5'b00000 :
        (STAR == S1) ? 5'b10001 :
        (STAR == S2) ? 5'b0011X :
        (STAR == S3) ? 5'b01X1X :
        /*default*/    5'bXXXXX ;

    always @(reset__ == 0) #1 STAR <= 0;
    always @(posedge clock) if(reset_ == 1) #3 begin
        casex(STAR)
            S0:STAR <= c0 ? S1 : S0;
            S1:STAR <= c1 ? S2 : S1;
            S2:STAR <= c2 ? S2 : S3; // in S2 i wait for rfd = 0 (= I took the data and i need to process it so i'm not ready for data anymore) by remaining in S2, otherwise i proceed to S3
            S3:STAR <= c2 ? S0 : S3;
        endcase
    end


/*
    sintesi ROM
    S0 = 00, S1 = 01, S2 = 10, S3 = 11
    c0 = 00, c1 = 01, c2 = 1X

    M-addr |  b4, b3, b2, b1, b0 | c_eff | M-addr-T | M-addr-F
    ----------------------------------------------------------
    00     | 00000               | 00    | 01       | 00
    01     | 01100               | 01    | 10       | 01
    10     | 1X001               | 1X    | 10       | 11
    11     | 1X01X               | 1X    | 00       | 11
*/





// sintesi rc (rimane uguale)

module MIN_3 {
    a,b,c,
    min
};
    input[7:0] a,b,c;
    output [7:0] min;

    wire [7:0] m_ab_out;
    MIN_2 min_a_b(
        .a(a), .b(b),
        .min(m_ab_out)
    );

    MIN_2 min_abc (
        .a(m_ab_out), .b(c),
        .min(min)
    );
endmodule


