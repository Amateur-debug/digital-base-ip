module lzd_128bits(

    input   [127:0]	src,
	output  [6  :0]	p  ,
	output			v
);

wire	[5	:0]	p0, p1;
wire			v0, v1;

lzd_64bits u0_lzd_64bits(

    .src(src[63:0]	),
	.p  (p0			),
	.v  (v0			)
);

lzd_64bits u1_lzd_64bits(

    .src(src[127:64]),
	.p  (p1			),
	.v  (v1			)
);

lzdu_2bits #(7) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);


endmodule
