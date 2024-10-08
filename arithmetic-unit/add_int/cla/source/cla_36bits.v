module cla_36bits(

    input	[35	:0]	a   ,
    input   [35	:0]	b   ,
    input			cin ,
    output	[35	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[2	:0]	px;
wire	[2	:0]	gx;
wire	[2	:0]	clu_cout;

cla_12bits u0_cla_12bits(

    .a   (a[11:0]  	   	),
    .b   (b[11:0]  	   	),
    .cin (clu_cout[0:0]	),
    .s   (s[11:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_12bits u1_cla_12bits(

    .a   (a[23:12] 	   	),
    .b   (b[23:12] 	   	),
    .cin (clu_cout[1:1]	),
    .s   (s[23:12] 	   	),
	.pm  (px[1:1]	   	),
	.gm  (gx[1:1]	   	)
);

cla_12bits u2_cla_12bits(

    .a   (a[35:24]     	),
    .b   (b[35:24]     	),
    .cin (clu_cout[2:2]	),
    .s   (s[35:24] 	   	),
	.pm  (px[2:2]	   	),
	.gm  (gx[2:2]	   	)
);

clu_3bits u_clu_3bits(

    .p   (px		),
    .g   (gx		),
    .cin (cin		),
    .cout(clu_cout	),
	.pm  (pm		),
	.gm  (gm		)
);



endmodule
