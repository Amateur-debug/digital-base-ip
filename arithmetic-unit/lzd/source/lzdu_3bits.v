module lzdu_3bits
#(
	parameter DATA_WIDTH = 3
)
(

    input	[DATA_WIDTH - 3:0]	p0,
	input	[DATA_WIDTH - 3:0]	p1,
	input	[DATA_WIDTH - 3:0]  p2,
	input 						v0,
	input 						v1,
	input 						v2,
	output  [DATA_WIDTH - 1:0]  p ,
	output						v
);

assign p[DATA_WIDTH - 1:DATA_WIDTH - 1] = ~v2 & ~v1;
assign p[DATA_WIDTH - 2:DATA_WIDTH - 2] = ~v2;
assign p[DATA_WIDTH - 3:0] = v2 ? p2 : (v1 ? p1 : p0);
assign v = v0 | v1 | v2;

endmodule
