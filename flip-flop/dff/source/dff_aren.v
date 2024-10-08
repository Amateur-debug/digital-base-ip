module dff_aren
#(
	parameter DATA_WIDTH = 32,
	parameter RESET_VALUE = 'b0
)
(
    input   						clock,
    input   						reset,
    input   						en	 ,	
	input   	[DATA_WIDTH - 1:0]  d	 ,
	output reg	[DATA_WIDTH - 1:0]  q
);

always@(posedge clock or posedge reset) begin
	if(reset) begin
		q <= RESET_VALUE;
	end
	else if(en) begin
		q <= d;
	end
	else begin                                   
		q <= q;
	end
end
 
endmodule
