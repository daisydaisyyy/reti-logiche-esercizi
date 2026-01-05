module testbench();

    wire clock;

    clock_generator clk(
        .clock(clock)
    );

    reg reset_;

    wire soc_x, soc_y;
    reg eoc_x, eoc_y;
    reg x, y;

    wire dav_;
    reg rfd;
    wire [1:0] t;
    
    ABC dut (
        .soc_x(soc_x), .soc_y(soc_y), .eoc_x(eoc_x), .x(x), .eoc_y(eoc_y), .y(y),
        .dav_(dav_), .rfd(rfd), .t(t), 
        .clock(clock), .reset_(reset_)
    );

    // linea di errore, utile per il debug
    reg error;
    initial error = 0;
    always @(posedge error) #1
        error = 0;

    initial
        begin
            $dumpfile("waveform.vcd");
            $dumpvars;

            //the following structure is used to wait for expected signals, and fail if too much time passes
            fork : f
                begin
                    #100000;
                    $display("Timeout - waiting for signal failed");
                    disable f;
                end
            //actual tests start here
                begin
                    eoc_x = 1; eoc_y = 1;
                    rfd = 1;

                    //reset phase
                    reset_ = 0; #(clk.HALF_PERIOD);
                    
                    //first posedge
                    reset_ = 1;

                    if(soc_x !== 0)
                        $display("soc_x is not 0 after reset");

                    if(soc_y !== 0)
                        $display("soc_y is not 0 after reset");

                    if(dav_ !== 1)
                        $display("dav_ is not 1 after reset");

                    fork
                        //Produttore X
                        begin : producer_x
                            reg [4:0] i;
                            reg t_x, t_y;

                            for (i = 0; i < 16; i++) begin
                                {t_x, t_y} = get_input_sequence(i[4:0]);
                                
                                @(posedge soc_x);
                                #(1*2*clk.HALF_PERIOD); 
                                eoc_x <= 0;
                                @(negedge soc_x);
                                #(1*2*clk.HALF_PERIOD); 
                                x <= t_x;
                                #(1*2*clk.HALF_PERIOD); 
                                eoc_x <= 1;    
                            end
                        end

                        //Produttore Y
                        begin : producer_y
                            reg [4:0] i;
                            reg t_x, t_y;

                            for (i = 0; i < 16; i++) begin
                                {t_x, t_y} = get_input_sequence(i[4:0]);
                                
                                @(posedge soc_y);
                                #(2*2*clk.HALF_PERIOD); 
                                eoc_y <= 0;
                                @(negedge soc_y);
                                #(2*2*clk.HALF_PERIOD); 
                                y <= t_y;
                                #(2*2*clk.HALF_PERIOD); 
                                eoc_y <= 1;      
                            end
                        end

                        //Consumer
                        begin : consumer
                            reg [2:0] i;
                            reg [1:0] t_T;

                            for (i = 0; i < 6; i++) begin
                                t_T = get_types_sequence(i[2:0]);

                                @(negedge dav_);
                                if(t !== t_T) begin
                                    $display("Test #%g failed, expected %g, got %g", i, t_T, t);
                                    error = 1;
                                end
                                #(2*clk.HALF_PERIOD); rfd <= 0;
                                @(posedge dav_);
                                #(2*clk.HALF_PERIOD); rfd <= 1;
                            end
                        end
                    join

                    disable f;
                end
            join

            $finish;
        end

    function automatic [6:0] get_input_sequence;
        input [4:0] i;
        reg x, y;
        
        begin
            case(i[3:0])
                0: begin
                    x = 0; y = 0; // 0
                end
                1: begin
                    x = 1; y = 0; // 1
                end
                2: begin
                    x = 0; y = 1; // 1
                end
                3: begin
                    x = 1; y = 1; // 0 -> T_1
                end
                4: begin
                    x = 1; y = 0; // 1
                end
                5: begin
                    x = 0; y = 0; // 0  
                end
                6: begin
                    x = 0; y = 1; // 1 -> T_3
                end
                7: begin
                    x = 1; y = 0; // 1
                end
                8: begin
                    x = 1; y = 1; // 0 -> T_1
                end
                9: begin
                    x = 0; y = 0; // 0 -> T_2
                end
                10: begin
                    x = 1; y = 0; // 1
                end
                11: begin
                    x = 1; y = 1; // 0
                end
                12: begin
                    x = 0; y = 1; // 1 -> T_3
                end
                13: begin
                    x = 0; y = 1; // 1
                end
                14: begin
                    x = 1; y = 1; // 0 -> T_1
                end
                15: begin
                    x = 1; y = 0; // 1
                end
            endcase

            get_input_sequence = {x, y};
        end
    endfunction

    function automatic [4:0] get_types_sequence;
        input [2:0] i;

        reg [1:0] t;

        begin
            case(i[2:0])
                0: begin
                    t = 1;
                end
                1: begin
                    t = 3;
                end
                2: begin
                    t = 1;
                end
                3: begin
                    t = 2;
                end
                4: begin
                    t = 3;
                end
                5: begin
                    t = 1;
                end
                default: begin
                    t = 0;
                end
            endcase

            get_types_sequence = t;
        end
    endfunction
endmodule

// generatore del segnale di clock
module clock_generator(
    clock
);
    output clock;

    parameter HALF_PERIOD = 5;

    reg CLOCK;
    assign clock = CLOCK;

    initial CLOCK <= 0;
    always #HALF_PERIOD CLOCK <= ~CLOCK;

endmodule