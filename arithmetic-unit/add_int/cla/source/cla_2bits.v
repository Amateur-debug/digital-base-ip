module cla_2bits(

    input	[1	:0]	a   ,
    input   [1	:0]	b   ,
    input			cin ,
    output	[1	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[1	:0]	p;
wire	[1	:0]	g;
pg #(2) u_pg(

    .a(a),
    .b(b),
    .p(p),
    .g(g)
);

wire	[1	:0]	clu_cout;
clu_2bits u_clu_2bits(

    .p   (p),
    .g   (g),
    .cin (cin),
    .cout(clu_cout),
	.pm  (pm),
	.gm  (gm)
);

assign s = a ^ b ^ clu_cout;

endmodule
