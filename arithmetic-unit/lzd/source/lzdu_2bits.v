module lzdu_2bits
#(
	parameter DATA_WIDTH = 2
)
(

    input	[DATA_WIDTH - 2:0]	p0,
	input   [DATA_WIDTH - 2:0]	p1,
	input 						v0,
	input 						v1,
	output  [DATA_WIDTH - 1:0]  p ,
	output						v
);

assign p[DATA_WIDTH - 1:DATA_WIDTH - 1] = ~v1;
assign p[DATA_WIDTH - 2:0] = v1 ? p1 : p0;
assign v = v0 | v1;

endmodule
