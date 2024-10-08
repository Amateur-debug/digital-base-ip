module lzd_16bits(

    input   [15	:0]	src,
	output  [3 	:0]	p  ,
	output			v
);

wire	[2	:0]	p0, p1;
wire			v0, v1;

lzd_8bits u0_lzd_8bits(

    .src(src[7:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_8bits u1_lzd_8bits(

    .src(src[15:8]	),
	.p  (p1			),
	.v  (v1			)
);

lzdu_2bits #(4) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);

endmodule