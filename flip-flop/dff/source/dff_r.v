module dff_r
#(
	parameter DATA_WIDTH = 32,
	parameter RESET_VALUE = 'b0
)
(
    input   						clock,
    input   						reset,
	input   	[DATA_WIDTH - 1:0] 	d	 ,
	output reg 	[DATA_WIDTH - 1:0] 	q
);

always@(posedge clock) begin
	if(reset) begin
		q <= RESET_VALUE;
	end
	else begin                                   
		q <= d;
	end
end
 
endmodule
