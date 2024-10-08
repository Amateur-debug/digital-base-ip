module lzd_4bits(

    input	[3	:0]	src,
	output	[1	:0]	p  ,
	output			v
);

wire p0, p1;
wire v0, v1;

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

lzdu_2bits #(2) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);

endmodule