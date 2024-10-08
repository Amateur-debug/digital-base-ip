module lzd_24bits(

    input   [23	:0]	src,
	output  [4	:0]	p  ,
	output  	    v
);

wire	[2:0]	p0, p1, p2;
wire			v0, v1, v2;

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

lzd_8bits u2_lzd_8bits(

    .src(src[23:16]	),
	.p  (p2			),
	.v  (v2			)
);

lzdu_3bits #(5) u_lzdu_3bits(

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