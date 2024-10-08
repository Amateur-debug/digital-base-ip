module wtree_11bits(

    input   [10	:0]	src  ,
    input   [2	:0]	cin2 ,
    input   [1	:0]	cin3 ,
    input   [1	:0]	cin4 ,
    input    	 	cin5 ,

    output  [2	:0]	cout1,
    output  [1	:0]	cout2,
    output  [1	:0]	cout3,
    output  		cout4,
    output  		cout ,
    output  		sout
);

///////////////first////////////////
wire [4:0] sout1;
assign sout1[4:3] = src[10:9];
genvar i;
generate
    for(i = 0; i < 3; i = i + 1) begin: first
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
wire [7:0] src2;
wire [3:0] sout2;
assign src2 = {cin2, sout1};
assign sout2[3:2] = src2[7:6];
genvar j;
generate
    for(j = 0; j < 2; j = j + 1) begin: second
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
wire  [5:0] src3;
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
assign src4 = {cin4, sout3};
assign sout4[1:1] = src4[3:3];
csa u4_csa(

    .a		(src4[0:0]	),
    .b		(src4[1:1]	),
    .cin	(src4[2:2]	),
    .cout	(cout4		),
    .s		(sout4		)
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
