module clu_2bits(

    input   [1	:0]	p   ,
    input   [1	:0]	g   ,
    input			cin ,
    output  [1	:0]	cout,
	output			pm  ,
	output			gm  
);

assign	pm = p[1:1] & p[0:0];
assign	gm = g[1:1] | (p[1:1] & g[0:0]);
assign  cout[0:0] = cin;
assign  cout[1:1] = g[0:0] | (p[0:0] & cout[0:0]);
  
endmodule
