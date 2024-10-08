module lzd_2bits(

    input	[1	:0]	src,
	output			p  ,
	output			v
);

assign	p = ~src[1:1];
assign	v = src[0:0] | src[1:1];

endmodule
