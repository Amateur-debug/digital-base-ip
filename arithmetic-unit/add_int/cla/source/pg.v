module pg
#(
	parameter DATA_WIDTH = 4
)
(

    input	[DATA_WIDTH - 1:0]	a,
    input	[DATA_WIDTH - 1:0]	b,
    output	[DATA_WIDTH - 1:0]	p,
    output	[DATA_WIDTH - 1:0]	g
);

assign  p = a | b;
assign  g = a & b;

endmodule
