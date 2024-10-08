module lzd_32bits(

    input	[31	:0]	src,
	output  [4	:0]	p  ,
	output  	    v
);

wire	[3	:0]	p0, p1;
wire			v0, v1;

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

lzdu_2bits #(5) u_lzdu_2bits(

    .p0(p0	),
	.p1(p1	),
	.v0(v0	),
	.v1(v1	),
	.p (p	),
	.v (v	)
);

endmodule