module cla_128bits(

    input   [127:0]	a   ,
    input   [127:0]	b   ,
    input			cin ,
    output	[127:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[1	:0]	px;
wire	[1	:0]	gx;
wire	[1	:0]	clu_cout;

cla_64bits u0_cla_64bits(

    .a   (a[63:0]  	   	),
    .b   (b[63:0]  	   	),
    .cin (clu_cout[0:0]	),
    .s   (s[63:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_64bits u1_cla_64bits(

    .a   (a[127:64] 	),
    .b   (b[127:64] 	),
    .cin (clu_cout[1:1]	),
    .s   (s[127:64] 	),
	.pm  (px[1:1]	   	),
	.gm  (gx[1:1]	   	)
);

clu_2bits u_clu_2bits(

    .p   (px		),
    .g   (gx		),
    .cin (cin		),
    .cout(clu_cout	),
	.pm  (pm		),
	.gm  (gm		)
);



endmodule
