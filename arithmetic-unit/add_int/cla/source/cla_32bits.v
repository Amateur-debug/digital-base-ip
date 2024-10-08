module cla_32bits(

    input   [31	:0]	a   ,
    input   [31	:0]	b   ,
    input  		    cin ,
    output	[31	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[1	:0]	px;
wire	[1	:0]	gx;
wire	[1	:0]	clu_cout;

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

clu_2bits u_clu_2bits(

    .p   (px		),
    .g   (gx		),
    .cin (cin		),
    .cout(clu_cout	),
	.pm  (pm		),
	.gm  (gm		)
);



endmodule
