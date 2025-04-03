module d_latch
#(
    parameter DATA_WIDTH = 1
)
(
    input       [DATA_WIDTH - 1:0]  d   ,
    input                           en  ,
    output reg  [DATA_WIDTH - 1:0]  q
);

always@(*) begin     
    if(en) begin                 
        q <= d;
    end
end

endmodule
