module comp_tree 
#(
    parameter WIDTH = 4,
    parameter NUM = 5
)
(
    input   [WIDTH*NUM - 1  :0] comp_data,
    output  [WIDTH - 1      :0] max_data
);

// power-of-two num
localparam NUM_LOW = 2 ** $clog2(NUM) / 2;
localparam NUM_HIGH = NUM - NUM_LOW;

generate
    if (NUM == 1) begin: comp_1
        assign max_data = comp_data;
    end 
    else if (NUM == 2) begin: comp_2
        wire compare;

        assign compare = comp_data[WIDTH - 1:0] < comp_data[WIDTH*2 - 1:WIDTH];
        assign max_data = compare ? comp_data[WIDTH*2 - 1:WIDTH] : comp_data[WIDTH - 1:0];  
    end 
    else if (NUM == 3) begin: comp_3
        wire                compare[1:0];
        wire [WIDTH - 1 :0] max_data_temp;
        
        assign compare[0] = comp_data[WIDTH - 1:0] < comp_data[WIDTH*2 - 1:WIDTH];
        assign max_data_temp = compare[0] ? comp_data[WIDTH*2 - 1:WIDTH] : comp_data[WIDTH - 1:0];

        assign compare[1] = max_data_temp < comp_data[WIDTH*3 - 1:WIDTH*2];
        assign max_data = compare[1] ? comp_data[WIDTH*3 - 1:WIDTH*2] : max_data_temp;
    end 
    else begin: comp_n

        wire [WIDTH - 1             :0] max_data_low, max_data_high;
        
        comp_tree #(
            .WIDTH(WIDTH),
            .NUM(NUM_LOW)
        )
        comp_tree_low (
            .comp_data(comp_data[WIDTH*NUM_LOW - 1:0]),
            .max_data(max_data_low)
        );

        comp_tree #(
            .WIDTH(WIDTH),
            .NUM(NUM_HIGH)
        )
        comp_tree_high (
            .comp_data(comp_data[WIDTH*NUM - 1:WIDTH*NUM_LOW]),
            .max_data(max_data_high)
        );

        wire compare;

        assign compare = max_data_low < max_data_high;
        assign max_data = compare ? max_data_high : max_data_low;  
    end
endgenerate

endmodule