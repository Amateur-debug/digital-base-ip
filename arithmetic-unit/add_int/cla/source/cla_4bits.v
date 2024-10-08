module cla_4bits(

    input   [3	:0]	a   ,
    input   [3	:0]	b   ,
    input			cin ,
    output	[3	:0]	s   ,
	output			pm	,
	output			gm  
);

wire	[3	:0]	p;
wire	[3	:0]	g;
pg #(4) u_pg(

    .a(a),
    .b(b),
    .p(p),
    .g(g)
);

wire	[3	:0]	clu_cout;
clu_4bits u_clu_4bits(

    .p   (p),
    .g   (g),
    .cin (cin),
    .cout(clu_cout),
	.pm  (pm),
	.gm  (gm)
);

assign s = a ^ b ^ clu_cout;

endmodule
