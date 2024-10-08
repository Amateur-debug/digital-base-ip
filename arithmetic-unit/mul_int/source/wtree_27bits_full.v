module wtree_27bits_full
#(
	parameter DATA_WIDTH = 106
)
(

    input    					clock,
	
	input   [24				:0]	cin  ,	//input at d0
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
	input   [DATA_WIDTH - 1	:0]	src13,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src14,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src15,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src16,	//input at d0
    input   [DATA_WIDTH - 1	:0]	src17,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src18,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src19,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src20,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src21,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src22,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src23,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src24,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src25,	//input at d0
	input   [DATA_WIDTH - 1	:0]	src26,	//input at d0
	
	output  [DATA_WIDTH - 1	:0]	cout ,	//output at d1
    output  [DATA_WIDTH - 1	:0]	sout	//output at d1

);

/////////////switch//////////////
wire	[26	:0]	switch_result [DATA_WIDTH - 1:0];
genvar i;
generate
	for(i = 0; i < DATA_WIDTH; i = i + 1) begin: switch
		assign switch_result[i] = {src0[i:i], src1[i:i], src2[i:i], src3[i:i], src4[i:i], src5[i:i], 
								   src6[i:i], src7[i:i], src8[i:i], src9[i:i], src10[i:i], src11[i:i],
								   src12[i:i], src13[i:i], src14[i:i], src15[i:i], src16[i:i], src17[i:i],
								   src18[i:i], src19[i:i], src20[i:i], src21[i:i], src22[i:i], src23[i:i],
								   src24[i:i], src25[i:i], src26[i:i]};
	end
endgenerate
/////////////////////////////////
wire [5:0] cin_d1;
dff #(6) cin_dff_d1(.clock(clock), .d(cin[24:19]), .q(cin_d1));
/////////////////////////////////
wire	[8	:0] cout1 [DATA_WIDTH - 1:0];
wire	[5	:0]	cout2 [DATA_WIDTH - 1:0];
wire	[3	:0]	cout3 [DATA_WIDTH - 1:0];
wire	[2	:0]	cout4_d1 [DATA_WIDTH - 1:0];
wire	[1	:0]	cout5_d1 [DATA_WIDTH - 1:0];
wire			cout6_d1 [DATA_WIDTH - 1:0];


wtree_27bits u0_wtree_27bits(

    .clock	(clock				),
		    
    .src	(switch_result[0]	),
    .cin2	(cin[8:0]			),
    .cin3	(cin[14:9]			),
    .cin4	(cin[18:15]			),
    .cin5	(cin_d1[2:0]		),
    .cin6	(cin_d1[4:3]		),
    .cin7	(cin_d1[5:5]		),
						     
    .cout1	(cout1[0]			),
    .cout2	(cout2[0]			),
    .cout3	(cout3[0]			),
    .cout4	(cout4_d1[0]		),
    .cout5	(cout5_d1[0]		),
    .cout6	(cout6_d1[0]		),
    .cout	(cout[0:0]			),
    .sout	(sout[0:0]			)
);
genvar j;
generate  
    for(j = 1; j < DATA_WIDTH; j = j + 1) begin: wtree_27bits
        wtree_27bits u_wtree_27bits(

			.clock  (clock				),

            .src	(switch_result[j]	),
            .cin2	(cout1[j - 1]		),
            .cin3	(cout2[j - 1]		),
            .cin4	(cout3[j - 1]		),
            .cin5	(cout4_d1[j - 1]	),
            .cin6	(cout5_d1[j - 1]	),
            .cin7	(cout6_d1[j - 1]	),

            .cout1	(cout1[j]			),
            .cout2	(cout2[j]			),
            .cout3	(cout3[j]			),
            .cout4	(cout4_d1[j]		),
            .cout5	(cout5_d1[j]		),
            .cout6	(cout6_d1[j]		),
            .cout	(cout[j:j]			),
            .sout	(sout[j:j]			)
        );
   	end 
endgenerate

endmodule
