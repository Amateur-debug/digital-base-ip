module clu_3bits(

    input   [2	:0]	p   ,
    input   [2	:0]	g   ,
    input			cin ,
    output  [2	:0]	cout,
	output			pm  ,
	output			gm  
);

assign	pm = p[2:2] & p[1:1] & p[0:0];
assign	gm = g[2:2] | (p[2:2] & g[1:1]) | (p[2:2] & p[1:1] & g[0:0]);
assign  cout[0:0] = cin;
assign  cout[1:1] = g[0:0] | (p[0:0] & cout[0:0]);
assign  cout[2:2] = g[1:1] | (p[1:1] & g[0:0]) | (p[1:1] & p[0:0] & cout[0:0]);
  
endmodule
