module wtree_13bits(

    input  		  	clock,
	
    input   [12	:0]	src  ,	//input at d0		
    input   [3	:0]	cin2 ,	//input at d0
    input   [2	:0]	cin3 ,	//input at d0
    input   [1	:0]	cin4 ,	//input at d0	
    input    	 	cin5 ,	//input at d1
		
    output  [3	:0]	cout1,	//output at d0
    output  [2	:0]	cout2,	//output at d0	
    output  [1	:0]	cout3,	//output at d0
    output  		cout4,	//output at d1
    output  		cout ,	//output at d1	
    output  		sout	//output at d1
);

///////////////first////////////////
wire [4:0] sout1;
assign sout1[4:4] = src[12:12];
genvar i;
generate
    for(i = 0; i < 4; i = i + 1) begin: first
        csa u1_csa(

            .a    (src[3*i:3*i]			),
            .b    (src[3*i + 1:3*i + 1]	),
            .cin  (src[3*i + 2:3*i + 2]	),
            .cout (cout1[i:i]			),
            .s    (sout1[i:i]			)
        );
    end
endgenerate
///////////////secnod///////////////
wire [8:0] src2;
wire [2:0] sout2;
assign src2 = {cin2, sout1};
genvar j;
generate
    for(j = 0; j < 3; j = j + 1) begin: second
        csa u2_csa(

            .a    (src2[3*j:3*j]		),
            .b    (src2[3*j + 1:3*j + 1]),
            .cin  (src2[3*j + 2:3*j + 2]),
            .cout (cout2[j:j]			),
            .s    (sout2[j:j]			)
        );
    end
endgenerate
///////////////thrid///////////////
wire [5:0] src3;
wire [1:0] sout3;
assign src3 = {cin3, sout2};
genvar k;
generate
    for(k = 0; k < 2; k = k + 1) begin: thrid
        csa u3_csa(

            .a    (src3[3*k:3*k]		),
            .b    (src3[3*k + 1:3*k + 1]),
            .cin  (src3[3*k + 2:3*k + 2]),
            .cout (cout3[k:k]			),
            .s    (sout3[k:k]			)
        );
    end
endgenerate
///////////////fourth///////////////
wire [3:0] src4;
wire [1:0] sout4;
assign sout4[1:1] = src4[3:3];
dff #(4) dff_d1(.clock(clock), .d({cin4, sout3}), .q(src4));
csa u4_csa(

    .a		(src4[0:0]	),
    .b		(src4[1:1]	),
    .cin	(src4[2:2]	),
    .cout	(cout4		),
    .s		(sout4[0:0]	)
);
///////////////fifth///////////////
wire  [2:0] src5;
assign src5 = {cin5, sout4};
csa u5_csa(

    .a		(src5[0:0]	),
    .b		(src5[1:1]	),
    .cin	(src5[2:2]	),
    .cout	(cout		),
    .s		(sout		)
);

endmodule
