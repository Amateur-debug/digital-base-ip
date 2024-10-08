module lzd_48bits(

    input   [47	:0]	src,
	output  [5	:0]	p  ,
	output  	    v
);

wire	[3	:0]	p0, p1, p2;
wire			v0, v1, v2;

lzd_16bits u0_lzd_16bits(

    .src(src[15:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_16bits u1_lzd_16bits(

    .src(src[31:16]	),
	.p  (p1			),
	.v  (v1			)
);

lzd_16bits u2_lzd_16bits(

    .src(src[47:32]	),
	.p  (p2			),
	.v  (v2			)
);

lzdu_3bits #(6) u_lzdu_3bits(

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
