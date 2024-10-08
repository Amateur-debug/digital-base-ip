module lzd_12bits(

    input   [11	:0]	src,
	output  [3	:0]	p  ,
	output			v
);

wire	[1	:0]	p0, p1, p2;
wire			v0, v1, v2;

lzd_4bits u0_lzd_4bits(

    .src(src[3:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_4bits u1_lzd_4bits(

    .src(src[7:4]	),
	.p  (p1			),
	.v  (v1			)
);

lzd_4bits u2_lzd_4bits(

    .src(src[11:8]	),
	.p  (p1			),
	.v  (v1			)
);

lzdu_3bits #(4) u_lzdu_3bits(

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