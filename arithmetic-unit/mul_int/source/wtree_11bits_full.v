module wtree_11bits_full
#(
	parameter DATA_WIDTH = 22
)
(

	input   [7				:0]	cin  ,
    input   [DATA_WIDTH - 1	:0]	src0 ,
    input   [DATA_WIDTH - 1	:0]	src1 ,
	input   [DATA_WIDTH - 1	:0]	src2 ,
	input   [DATA_WIDTH - 1	:0]	src3 ,
	input   [DATA_WIDTH - 1	:0]	src4 ,
    input   [DATA_WIDTH - 1	:0]	src5 ,
    input   [DATA_WIDTH - 1	:0]	src6 ,
	input   [DATA_WIDTH - 1	:0]	src7 ,
	input   [DATA_WIDTH - 1	:0]	src8 ,
	input   [DATA_WIDTH - 1	:0]	src9 ,
	input   [DATA_WIDTH - 1	:0]	src10,

    output  [DATA_WIDTH - 1	:0]	sout ,
	output  [DATA_WIDTH - 1	:0]	cout
);

/////////////switch//////////////
wire [10:0] switch_result [DATA_WIDTH - 1:0];
genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1) begin: switch
		assign switch_result[i] = {src0[i:i], src1[i:i], src2[i:i], src3[i:i], src4[i:i], src5[i:i], 
								   src6[i:i], src7[i:i], src8[i:i], src9[i:i], src10[i:i]};
	end
endgenerate
/////////////////////////////////
wire [2:0] cout1 [DATA_WIDTH - 1:0];
wire [1:0] cout2 [DATA_WIDTH - 1:0];
wire [1:0] cout3 [DATA_WIDTH - 1:0];
wire	   cout4 [DATA_WIDTH - 1:0];

wtree_11bits u0_wtree_11bits(

	.src	(switch_result[0]	), 
	.cin2	(cin[2:0]			),
	.cin3	(cin[4:3]			),
	.cin4	(cin[6:5]			),
	.cin5	(cin[7:7]			),

	.cout1	(cout1[0]			),
	.cout2	(cout2[0]			),
	.cout3	(cout3[0]			),
	.cout4	(cout4[0]			),

	.cout	(cout[0:0]			),
	.sout	(sout[0:0]			)
);

genvar j;
generate
	for(j = 1; j < DATA_WIDTH ; j = j + 1) begin: wtree_11bits
  	wtree_11bits u_wtree_11bits(
	
 		  .src	(switch_result[j]	), 
 		  .cin2	(cout1[j - 1]		),
 		  .cin3	(cout2[j - 1]		),
 		  .cin4	(cout3[j - 1]		),
 		  .cin5	(cout4[j - 1]		),

 		  .cout1(cout1[j]			),
 		  .cout2(cout2[j]			),
 		  .cout3(cout3[j]			),
 		  .cout4(cout4[j]			),

 		  .cout	(cout[j:j]			),
 		  .sout	(sout[j:j]			)
		);
	end
endgenerate


endmodule
