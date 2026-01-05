module MATCH_SEQ (
    buffer,
    match, match_type
);

    input [3:0] buffer;
    output match;
    output [1:0] match_type;

    wire is_type_1;
    assign #1 is_type_1 = ~buffer[0] & buffer[1] & buffer[2] & ~buffer[3];

    wire is_type_2;
    assign #1 is_type_2 = ~buffer[0] & ~buffer[1] & buffer[2] & buffer[3];

    wire is_type_3;
    assign #1 is_type_3 = buffer[0] & ~buffer[1] & buffer[2] & ~buffer[3];

    assign #1 match = is_type_1 | is_type_2 | is_type_3;
    assign #1 match_type =
                        is_type_1? 1 :
                        is_type_2 ? 2 :
                        is_type_3 ? 3 :
                                    0;
endmodule