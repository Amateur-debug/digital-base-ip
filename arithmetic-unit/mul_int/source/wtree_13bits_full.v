module wtree_13bits_full
#(
	parameter DATA_WIDTH = 48
)
(
	input  		  				clock,
		
	input   [9				:0]	cin  ,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src0 ,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src1 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src2 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src3 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src4 ,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src5 ,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src6 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src7 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src8 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src9 ,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src10,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src11,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src12,	//input at d0

    output  [DATA_WIDTH - 1	:0]	sout ,	//output at d1
	output  [DATA_WIDTH - 1	:0]	cout    //output at d1
);

/////////////switch//////////////
wire [12:0] switch_result [DATA_WIDTH - 1:0];
genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1) begin: switch
		assign switch_result[i] = {src0[i:i], src1[i:i], src2[i:i], src3[i:i], src4[i:i], src5[i:i], 
								   src6[i:i], src7[i:i], src8[i:i], src9[i:i], src10[i:i], src11[i:i],
								   src12[i:i]};
	end
endgenerate
/////////////////////////////////
wire cin_d1;
dff #(1) cin_dff_d1(.clock(clock), .d(cin[9:9]), .q(cin_d1));
/////////////////////////////////
wire [3:0] cout1	[DATA_WIDTH - 1:0];
wire [2:0] cout2	[DATA_WIDTH - 1:0];
wire [1:0] cout3	[DATA_WIDTH - 1:0];
wire	   cout4_d1	[DATA_WIDTH - 1:0];

wtree_13bits u0_wtree_13bits(

	.clock	(clock				),
	
	.src	(switch_result[0]	), 
	.cin2	(cin[3:0]			),
	.cin3	(cin[6:4]			),
	.cin4	(cin[8:7]			),
	.cin5	(cin_d1				),

	.cout1	(cout1[0]			),
	.cout2	(cout2[0]			),
	.cout3	(cout3[0]			),
	.cout4	(cout4_d1[0]		),

	.cout	(cout[0:0]			),
	.sout	(sout[0:0]			)
);

genvar j;
generate
	for(j = 1; j < DATA_WIDTH ; j = j + 1) begin: wtree_13bits
		wtree_13bits u_wtree_13bits(
			.clock	(clock				),
			
			.src	(switch_result[j]	), 
			.cin2	(cout1[j - 1]		),
			.cin3	(cout2[j - 1]		),
			.cin4	(cout3[j - 1]		),
			.cin5	(cout4_d1[j - 1]	),
	
			.cout1	(cout1[j]			),
			.cout2	(cout2[j]			),
			.cout3	(cout3[j]			),
			.cout4	(cout4_d1[j]		),
	
			.cout	(cout[j:j]			),
			.sout	(sout[j:j]			)
		);
	end
endgenerate


endmodule
