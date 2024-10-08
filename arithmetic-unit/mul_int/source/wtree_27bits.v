module wtree_27bits(

    input    		clock,
		    
    input   [26	:0]	src	 ,	//input at d0
    input   [8	:0]	cin2 ,	//input at d0
    input   [5	:0]	cin3 ,	//input at d0
    input   [3	:0]	cin4 ,	//input at d0
    input   [2	:0]	cin5 ,	//input at d1
    input   [1	:0]	cin6 ,  //input at d1
    input     		cin7 ,  //input at d1
		    
    output  [8	:0]	cout1,	//output at d0
    output  [5	:0]	cout2,	//output at d0
    output  [3	:0]	cout3,	//output at d0
    output  [2	:0]	cout4,	//output at d1
    output  [1	:0]	cout5,	//output at d1
    output    		cout6,	//output at d1
    output			cout ,	//output at d1
    output			sout	//output at d1
);

///////////////first_level////////////////
wire [8:0] sout1;
genvar i;
generate
    for(i = 0; i < 9; i = i + 1) begin: first
        csa u1_csa(
		
            .a    (src[3*i:3*i]			),
            .b    (src[3*i + 1:3*i + 1]	),
            .cin  (src[3*i + 2:3*i + 2]	),
            .cout (cout1[i:i]			),
            .s    (sout1[i:i]			)
        );
    end
endgenerate
///////////////secnod_level///////////////
wire [17:0] src2;
wire [5	:0] sout2;
assign src2 = {cin2, sout1};
genvar j;
generate
    for(j = 0; j < 6; j = j + 1) begin: second
        csa u2_csa(

            .a		(src2[3*j:3*j]			),
            .b		(src2[3*j + 1:3*j + 1]	),
            .cin	(src2[3*j + 2:3*j + 2]	),
            .cout	(cout2[j:j]				),
            .s		(sout2[j:j]				)
        );
    end
endgenerate
///////////////thrid_level///////////////
wire [11:0] src3;
wire [3:0] sout3;
assign src3 = {cin3, sout2};
genvar k;
generate
    for(k = 0; k < 4; k = k + 1) begin: thrid
        csa u3_csa(

            .a		(src3[3*k:3*k]			),
            .b		(src3[3*k + 1:3*k + 1]	),
            .cin	(src3[3*k + 2:3*k + 2]	),
            .cout	(cout3[k:k]				),
            .s		(sout3[k:k]				)
        );
    end
endgenerate
///////////////fourth_level///////////////
wire [8:0] src4;
wire [2:0] sout4;
dff #(9) dff_d1(.clock(clock), .d({cin4, sout3, 1'b0}), .q(src4));
genvar m;
generate
    for(m = 0; m < 3; m = m + 1) begin: fourth
        csa u4_csa(

            .a		(src4[3*m:3*m]			),
            .b		(src4[3*m + 1:3*m + 1]	),
            .cin	(src4[3*m + 2:3*m + 2]	),
            .cout	(cout4[m:m]				),
            .s		(sout4[m:m]				)
        );
    end
endgenerate
///////////////fifth_level///////////////
wire [5:0] src5;
wire [1:0] sout5;
assign src5 = {cin5, sout4};
genvar n;
generate
    for(n = 0; n < 2; n = n + 1) begin: fifth
        csa u5_csa(

            .a		(src5[3*n:3*n]			),
            .b		(src5[3*n + 1:3*n + 1]	),
            .cin	(src5[3*n + 2:3*n + 2]	),
            .cout	(cout5[n:n]				),
            .s		(sout5[n:n]				)
        );
    end
endgenerate
///////////////sixth_level///////////////
wire [3:0] src6;
wire [1:0] sout6;
assign sout6[1:1] = src6[3:3];
assign src6 = {cin6, sout5};
csa u6_csa(

    .a		(src6[0:0]	),
    .b		(src6[1:1]	),
    .cin	(src6[2:2]	),
    .cout	(cout6		),
    .s		(sout6[0:0]	)
);
///////////////seventh_level///////////////
wire  [2:0] src7;
assign src7 = {cin7, sout6};
csa u7_csa(

    .a		(src7[0:0]	),
    .b		(src7[1:1]	),
    .cin	(src7[2:2]	),
    .cout	(cout		),
    .s		(sout		)
);

endmodule
