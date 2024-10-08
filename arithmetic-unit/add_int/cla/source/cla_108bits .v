module cla_108bits(

    input	[107:0]	a   ,
    input	[107:0]	b   ,
    input			cin ,
    output	[107:0]	s   ,
	output    	    pm  ,
	output    	    gm  
);

wire	[2	:0]	px;
wire	[2	:0]	gx;
wire	[2	:0]	clu_cout;

cla_36bits u0_cla_36bits(

    .a   (a[35:0]  	   	),
    .b   (b[35:0]  	   	),
    .cin (clu_cout[0:0]	),
    .s   (s[35:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_36bits u1_cla_36bits(

    .a   (a[71:36] 	   	),
    .b   (b[71:36] 	   	),
    .cin (clu_cout[1:1]	),
    .s   (s[71:36] 	   	),
	.pm  (px[1:1]	   	),
	.gm  (gx[1:1]	   	)
);

cla_36bits u2_cla_36bits(

    .a   (a[107:72]    	),
    .b   (b[107:72]    	),
    .cin (clu_cout[2:2]	),
    .s   (s[107:72]    	),
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
