module lzd_64bits(

    input	[63	:0]	src,
	output  [5	:0]	p  ,
	output			v
);

wire	[4	:0] p0, p1;
wire			v0, v1;

lzd_32bits u0_lzd_32bits(

    .src(src[31:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_32bits u1_lzd_32bits(

    .src(src[63:32]	),
	.p  (p1			),
	.v  (v1			)
);

lzdu_2bits #(6) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);

endmodule