module lzd_6bits(

    input	[5	:0]	src,
	output  [2	:0]	p  ,
	output			v
);

wire	p0, p1, p2;
wire	v0, v1, v2;

lzd_2bits u0_lzd_2bits(

    .src(src[1:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_2bits u1_lzd_2bits(

    .src(src[3:2]	),
	.p  (p1			),
	.v  (v1			)
);

lzd_2bits u2_lzd_2bits(

    .src(src[5:4]	),
	.p  (p2			),
	.v  (v2			)
);

lzdu_3bits #(3) u_lzdu_3bits(

    .p0(p0	),
	.p1(p1	),
	.p2(p2	),
	.v0(v0	),
	.v1(v1	),
	.v2(v2	),
	.p (p	),
	.v (v	)
);

endmodule