// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Priority encoder module
 */
module priority_encoder 
#(
    parameter WIDTH = 4,
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "LOW"
)
(
    input   [WIDTH - 1      :0] unencoded,
    output                      valid,
    output  [$clog2(WIDTH)-1:0] encoded
);

// power-of-two width
localparam HALF_WIDTH = 2 ** $clog2(WIDTH) / 2;

generate
    if (WIDTH == 1) begin: priority_encoder_1
        assign valid = unencoded;
        assign encoded = 'b0;
    end 
    else if (WIDTH == 2) begin: priority_encoder_2
        assign valid = |unencoded;
        if (LSB_PRIORITY == "LOW") begin: priority_encoder_2_low
            assign encoded = unencoded[1];
        end 
        else begin: priority_encoder_2_high
            assign encoded = ~unencoded[0];
        end
    end 
    else begin: priority_encoder_n

        wire [$clog2(HALF_WIDTH) - 1 :0] encoded_low, encoded_high;
        wire valid_low, valid_high;

        priority_encoder #(
            .WIDTH(HALF_WIDTH),
            .LSB_PRIORITY(LSB_PRIORITY)
        )
        priority_encoder_low (
            .unencoded(unencoded[HALF_WIDTH-1:0]),
            .valid(valid_low),
            .encoded(encoded_low)
        );

        priority_encoder #(
            .WIDTH(HALF_WIDTH),
            .LSB_PRIORITY(LSB_PRIORITY)
        )
        priority_encoder_high (
            .unencoded({{(2 * HALF_WIDTH - WIDTH){1'b0}}, unencoded[WIDTH-1:HALF_WIDTH]}),
            .valid(valid_high),
            .encoded(encoded_high)
        );

        assign valid = valid_low | valid_high;

        if (LSB_PRIORITY == "LOW") begin: priority_encoder_n_low
            assign encoded = valid_high ? {1'b1, encoded_high} : {1'b0, encoded_low};
        end 
        else begin: priority_encoder_n_high
            assign encoded = valid_low ? {1'b0, encoded_low} : {1'b1, encoded_high};
        end
    end
endgenerate

endmodule
