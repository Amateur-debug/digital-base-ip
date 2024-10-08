module lzd_8bits(

    input   [7	:0]	src,
	output  [2	:0]	p  ,
	output			v
);

wire	[1	:0]	p0, p1;
wire			v0, v1;

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

lzdu_2bits #(3) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);

endmodule