module dff
#(
	parameter DATA_WIDTH = 32
)
(
    input   						clock,
	input   	[DATA_WIDTH - 1:0] 	d	 ,
	output reg  [DATA_WIDTH - 1:0] 	q
);

always@(posedge clock) begin                      
	q <= d;
end
 
endmodule
