module cla_12bits(

    input	[11	:0]	a   ,
    input   [11	:0]	b   ,
    input			cin ,
    output	[11	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[2	:0]	px;
wire	[2	:0]	gx;
wire	[2	:0]	clu_cout;

cla_4bits u0_cla_4bits(

    .a   (a[3:0]  	   	),
    .b   (b[3:0]		),
    .cin (clu_cout[0:0]	),
    .s   (s[3:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_4bits u1_cla_4bits(

    .a   (a[7:4]		),
    .b   (b[7:4] 	   	),
    .cin (clu_cout[1:1]	),
    .s   (s[7:4] 	   	),
	.pm  (px[1:1]	   	),
	.gm  (gx[1:1]	   	)
);

cla_4bits u2_cla_4bits(

    .a   (a[11:8]  	   	),
    .b   (b[11:8]  	   	),
    .cin (clu_cout[2:2]	),
    .s   (s[11:8] 	   	),
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
