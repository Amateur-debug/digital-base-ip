module cla_64bits(

    input	[63	:0]	a   ,
    input	[63	:0]	b   ,
    input  		    cin ,
    output	[63	:0]	s   ,
	output    	    pm  ,
	output    	    gm  
);

wire	[3	:0]	px;
wire	[3	:0]	gx;
wire	[3	:0]	clu_cout;

cla_16bits u0_cla_16bits(

    .a   (a[15:0]  	   	),
    .b   (b[15:0]  	   	),
    .cin (clu_cout[0:0]	),
    .s   (s[15:0] 	   	),
	.pm  (px[0:0]	   	),
	.gm  (gx[0:0]	   	)
);

cla_16bits u1_cla_16bits(

    .a   (a[31:16] 	   	),
    .b   (b[31:16] 	   	),
    .cin (clu_cout[1:1]	),
    .s   (s[31:16] 	   	),
	.pm  (px[1:1]	   	),
	.gm  (gx[1:1]	   	)
);

cla_16bits u2_cla_16bits(

    .a   (a[47:32]     	),
    .b   (b[47:32]     	),
    .cin (clu_cout[2:2]	),
    .s   (s[47:32] 	   	),
	.pm  (px[2:2]	   	),
	.gm  (gx[2:2]	   	)
);

cla_16bits u3_cla_16bits(

    .a   (a[63:48] 	   	),
    .b   (b[63:48] 	   	),
    .cin (clu_cout[3:3]	),
    .s   (s[63:48] 	   	),
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
