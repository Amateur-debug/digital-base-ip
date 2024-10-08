module dff_en
#(
	parameter DATA_WIDTH = 32
)
(
    input   						clock,
    input   						en	 ,	
	input   	[DATA_WIDTH - 1:0] 	d	 ,
	output reg 	[DATA_WIDTH - 1:0] 	q
);

always@(posedge clock) begin
	if(en) begin
		q <= d;
	end
	else begin                                   
		q <= q;
	end
end
 
endmodule
