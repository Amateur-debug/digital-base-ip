module cla_16bits(

    input   [15	:0]	a   ,
    input   [15	:0]	b   ,
    input			cin ,
    output	[15	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[3	:0]	px;
wire	[3	:0]	gx;
wire	[3	:0]	clu_cout;

cla_4bits u0_cla_4bits(

    .a   (a[3:0]  	   	),
    .b   (b[3:0]  	   	),
    .cin (clu_cout[0:0]	),
    .s   (s[3:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_4bits u1_cla_4bits(

    .a   (a[7:4] 	   	),
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

cla_4bits u3_cla_4bits(

    .a   (a[15:12] 	   	),
    .b   (b[15:12] 	   	),
    .cin (clu_cout[3:3]	),
    .s   (s[15:12] 	   	),
	.pm  (px[3:3]	   	),
	.gm  (gx[3:3]	   	)
);

clu_4bits u_clu_4bits(

    .p   (px		),
    .g   (gx		),
    .cin (cin		),
    .cout(clu_cout	),
	.pm  (pm		),
	.gm  (gm		)
);



endmodule
