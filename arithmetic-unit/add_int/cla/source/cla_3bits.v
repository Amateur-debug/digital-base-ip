module cla_3bits(

    input	[2	:0]	a   ,
    input   [2	:0]	b   ,
    input			cin ,
    output	[2	:0]	s   ,
	output			pm  ,
	output			gm  
);

wire	[2	:0]	p;
wire	[2	:0]	g;
pg #(3) u_pg(

    .a(a),
    .b(b),
    .p(p),
    .g(g)
);

wire [2:0] clu_cout;
clu_3bits u_clu_3bits(

    .p   (p),
    .g   (g),
    .cin (cin),
    .cout(clu_cout),
	.pm  (pm),
	.gm  (gm)
);

assign s = a ^ b ^ clu_cout;

endmodule
