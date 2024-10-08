`include "mul_fp.vh"
`include "mul_int.vh"
module mul_fp32(

	input			clock  ,
	input			en     ,	//input at d0
	input	[2 	:0]	rm     ,	//input at d0
	input   [31	:0]	src1   ,	//input at d0
	input   [31	:0]	src2   ,	//input at d0
	output  [31	:0]	result ,	//output at d4
	output			nv	   ,
	output			of	   
);
////////////////////////////////////////////////
wire  			sign1;
wire  			sign2;
wire	[7	:0] exp1;
wire	[7	:0] exp2;
wire	[22	:0] man1;
wire	[22	:0] man2;

assign sign1 = src1[31:31];
assign sign2 = src2[31:31];
assign exp1 = src1[30:23];
assign exp2 = src2[30:23];
assign man1 = src1[22:0];
assign man2 = src2[22:0];
////////////////////////////////////////////////
wire	normal1;
wire	normal2;
wire	subnormal1;
wire	subnormal2;
wire	zero1;	
wire	zero2;	
wire	infinity1;
wire	infinity2;
wire	snan1;
wire	snan2;
wire	qnan1;
wire	qnan2;	

assign normal1 = exp1 != 8'b0 && exp1 != 8'b1111_1111;
assign normal2 = exp2 != 8'b0 && exp2 != 8'b1111_1111;

assign subnormal1 = exp1 == 8'b0 && man1 != 23'b0;
assign subnormal2 = exp2 == 8'b0 && man2 != 23'b0;

assign zero1 = exp1 == 8'b0 && man1 == 23'b0;
assign zero2 = exp2 == 8'b0 && man2 == 23'b0;

assign infinity1 = exp1 == 8'b1111_1111 && man1 == 23'b0;
assign infinity2 = exp2 == 8'b1111_1111 && man2 == 23'b0;

assign snan1 = exp1 == 8'b1111_1111 && !man1[22:22] && man1[21:0] != 22'b0;
assign snan2 = exp2 == 8'b1111_1111 && !man2[22:22] && man2[21:0] != 22'b0;

assign qnan1 = exp1 == 8'b1111_1111 && man1[22:22];
assign qnan2 = exp2 == 8'b1111_1111 && man2[22:22];
////////////////////////////////////////////////
wire			zero;	
wire			infinity;
wire			snan;
wire			qnan;
wire	[21	:0] nan_load;
wire			nv_d0;

assign zero = zero1 && (normal2 || subnormal2) || zero2 && (normal1 || subnormal1) || zero1 && zero2;
assign infinity = infinity1 && (normal2 || subnormal2) || infinity2 && (normal1 || subnormal1) || infinity1 && infinity2;
assign snan = snan1 || snan2;
assign qnan = qnan1 || qnan2 || zero1 && infinity2 || zero2 && infinity1;
assign nan_load = snan1 || qnan1 ? man1[21:0] : 
				  snan2 || qnan2 ? man2[21:0] : 22'b00_0000_0000_0000_0000_0001;
assign nv_d0 = zero1 && infinity2 || zero2 && infinity1 || snan1 || snan2 || qnan1 || qnan2;
////////////////////////////////////////////////
wire sign;
assign sign = sign1 ^ sign2;
////////////////////////////////////////////////
//多一位编码承载溢出
wire	[8	:0]	exp1_true;
wire	[8	:0]	exp2_true;
wire	[8	:0]	exp_temp;

assign exp1_true = normal1 ? {1'b0, exp1} + 9'b110000001 : 9'b110000010;
assign exp2_true = normal2 ? {1'b0, exp2} + 9'b110000001 : 9'b110000010;
assign exp_temp = exp1_true + exp2_true;
////////////////////////////////////////////////
//恢复隐藏的1
wire	[23	:0]	man1_true;
wire	[23	:0]	man2_true;

assign man1_true = {normal1, man1};
assign man2_true = {normal2, man2};
////////////////////////////////////////////////
wire	[47	:0]	man_temp_d2;

mul_int24 u_mul_int24(

    .clock       (clock					),
	
    .en          (en					),
    .opcode      (`UNSIGNED_X_UNSIGNED	),
    .multiplicand(man1_true				),
    .multiplier  (man2_true				),

    .result_hi   (man_temp_d2[47:24]	),
    .result_lo	 (man_temp_d2[23:0]		)
);
////////////////////////////////////////////////
wire 			zero_d1;
wire 			zero_d2;	
wire 			infinity_d1;
wire 			infinity_d2;
wire 			snan_d1;
wire 			snan_d2;
wire 			qnan_d1;
wire 			qnan_d2;
wire	[21	:0] nan_load_d1;
wire	[21	:0] nan_load_d2;
wire 			nv_d1;
wire 			nv_d2;
wire 			sign_d1;
wire 			sign_d2;
wire	[8	:0]	exp_temp_d1;
wire	[8	:0]	exp_temp_d2;
wire	[2	:0] rm_d1;
wire	[2	:0] rm_d2;

dff #(1	) zero_dff_d1		(.clock(clock), .d(zero			), .q(zero_d1		));
dff #(1	) zero_dff_d2		(.clock(clock), .d(zero_d1		), .q(zero_d2		));
dff #(1	) infinity_dff_d1	(.clock(clock), .d(infinity		), .q(infinity_d1	));
dff #(1	) infinity_dff_d2	(.clock(clock), .d(infinity_d1	), .q(infinity_d2	));
dff #(1	) snan_dff_d1		(.clock(clock), .d(snan			), .q(snan_d1		));
dff #(1	) snan_dff_d2		(.clock(clock), .d(snan_d1		), .q(snan_d2		));
dff #(1	) qnan_dff_d1		(.clock(clock), .d(qnan			), .q(qnan_d1		));
dff #(1	) qnan_dff_d2		(.clock(clock), .d(qnan_d1		), .q(qnan_d2		));
dff #(1	) nv_dff_d1			(.clock(clock), .d(nv_d0		), .q(nv_d1			));
dff #(1	) nv_dff_d2			(.clock(clock), .d(nv_d1		), .q(nv_d2			));
dff #(1	) sign_dff_d1		(.clock(clock), .d(sign			), .q(sign_d1		));
dff #(1	) sign_dff_d2		(.clock(clock), .d(sign_d1		), .q(sign_d2		));
dff #(9	) exp_temp_dff_d1	(.clock(clock), .d(exp_temp		), .q(exp_temp_d1	));
dff #(9	) exp_temp_dff_d2	(.clock(clock), .d(exp_temp_d1	), .q(exp_temp_d2	));
dff #(3	) rm_dff_d1			(.clock(clock), .d(rm			), .q(rm_d1			));
dff #(3	) rm_dff_d2			(.clock(clock), .d(rm_d1		), .q(rm_d2			));
dff #(22) nan_load_dff_d1	(.clock(clock), .d(nan_load		), .q(nan_load_d1	));
dff #(22) nan_load_dff_d2	(.clock(clock), .d(nan_load_d1	), .q(nan_load_d2	));
////////////////////////////////////////////////
//Leading 0 detection
wire	[5	:0]	p_d2;
wire			v_d2;
lzd_48bits u_lzd_48bits(

    .src(man_temp_d2),
	.p  (p_d2		),
	.v  (v_d2		)
);
////////////////////////////////////////////////
//Calculate the shift number
wire	[9	:0] lshift_max_d2;
wire	[9	:0] rshift_min_d2;
wire			shift_direction_d2; //0-left, 1-right
wire	[5	:0] lshift_bits_d2;
wire	[5	:0] lshift_true_d2;
wire	[6	:0] rshift_bits_d2;
wire	[6	:0] rshift_true_d2;

assign lshift_max_d2 = {exp_temp_d2[8:8], exp_temp_d2} + 'd126;
assign rshift_min_d2 = $signed(-'d125) + ~{exp_temp_d2[8:8], exp_temp_d2};	//assign rshift_max_d2 = $signed(-'d126) + ~{exp_temp_d2[8:8], exp_temp_d2} + 'b1;

assign shift_direction_d2 = $signed(rshift_min_d2) > $signed('b0) || man_temp_d2[47:47];

assign lshift_bits_d2 = p_d2 - 'b1;
assign rshift_bits_d2 = man_temp_d2[47:47] ? 'b1 : 'b0;

assign lshift_true_d2 = $signed(lshift_bits_d2) < $signed(lshift_max_d2) ? lshift_bits_d2 : 
						lshift_max_d2[9:9] ? 'b0 : lshift_max_d2[5:0];
assign rshift_true_d2 = $signed(rshift_bits_d2) > $signed(rshift_min_d2) ? rshift_bits_d2 : 
						rshift_min_d2[9:9] ? 'b0 : rshift_min_d2[6:0];
////////////////////////////////////////////////
//normalize
wire	[47	:0] man_lshifted_d2;
wire	[47	:0] man_rshifted_d2;
wire	[26	:0] man_normalized_d2;
wire	[47	:0] dis_bits_d2;
wire	[8	:0] exp_lshifted_d2;
wire	[8	:0] exp_rshifted_d2;
wire	[8	:0] exp_normalized_d2;

assign man_lshifted_d2 = man_temp_d2 << lshift_true_d2;
assign {man_rshifted_d2, dis_bits_d2} = rshift_true_d2 < 'd48 ? {man_temp_d2, 48'b0} >> rshift_true_d2 : {48'b0, man_temp_d2};
assign man_normalized_d2[26:1] = shift_direction_d2 ? man_rshifted_d2[47:22] : man_lshifted_d2[47:22];
assign man_normalized_d2[0:0] = shift_direction_d2 ? |{man_rshifted_d2[21:0], dis_bits_d2} : |man_lshifted_d2[21:0];

assign exp_lshifted_d2 = exp_temp_d2 + ~{3'b0, lshift_true_d2} + 'b1;
assign exp_rshifted_d2 = exp_temp_d2 + {2'b0, rshift_true_d2};
assign exp_normalized_d2 = shift_direction_d2 ? exp_rshifted_d2 : exp_lshifted_d2;
////////////////////////////////////////////////
wire			zero_d3;
wire			infinity_d3;
wire			snan_d3;
wire			qnan_d3;
wire			nv_d3;
wire			sign_d3;
wire	[8	:0] exp_temp_d3;
wire	[26	:0] man_temp_d3;
wire	[2	:0] rm_d3;
wire	[21	:0] nan_load_d3;

dff #(1	) zero_dff_d3		(.clock(clock), .d(zero_d2			), .q(zero_d3		));
dff #(1	) infinity_dff_d3	(.clock(clock), .d(infinity_d2		), .q(infinity_d3	));
dff #(1	) snan_dff_d3		(.clock(clock), .d(snan_d2			), .q(snan_d3		));
dff #(1	) qnan_dff_d3		(.clock(clock), .d(qnan_d2			), .q(qnan_d3		));
dff #(1	) nv_dff_d3			(.clock(clock), .d(nv_d2			), .q(nv_d3			));
dff #(1	) sign_dff_d3		(.clock(clock), .d(sign_d2			), .q(sign_d3		));
dff #(9	) exp_temp_dff_d3	(.clock(clock), .d(exp_normalized_d2), .q(exp_temp_d3	));
dff #(27) man_temp_dff_d3	(.clock(clock), .d(man_normalized_d2), .q(man_temp_d3	));
dff #(3	) rm_dff_d3			(.clock(clock), .d(rm_d2			), .q(rm_d3			));
dff #(22) nan_load_dff_d3	(.clock(clock), .d(nan_load_d2		), .q(nan_load_d3	));
////////////////////////////////////////////////
//round
wire	[24	:0]	man_round1_d3;
wire	[24	:0]	man_round0_d3;
reg		[24	:0]	man_rounded_d3;

assign man_round1_d3 = man_temp_d3[26:2] + 'b1;
assign man_round0_d3 = man_temp_d3[26:2];
always@(*) begin
	case(rm_d3)
		`RTE: begin
			case(man_temp_d3[1:0])
				2'b00: begin
					man_rounded_d3 = man_round0_d3;
				end
				2'b01: begin
					man_rounded_d3 = man_round0_d3;
				end
				2'b10: begin
					man_rounded_d3 = man_temp_d3[2:2] ? man_round1_d3 : man_round0_d3;
				end
				2'b11: begin
					man_rounded_d3 = man_round1_d3;
				end
			endcase
		end
		`RTZ: begin
			man_rounded_d3 = man_round0_d3;
		end
		`RDN: begin
			man_rounded_d3 = sign_d3 ? (|man_temp_d3[1:0] ? man_round1_d3 : man_round0_d3) : man_round0_d3;
		end
		`RUP: begin
			man_rounded_d3 = sign_d3 ? man_round0_d3 : (|man_temp_d3[1:0] ? man_round1_d3 : man_round0_d3);
		end
		`RMM: begin
			man_rounded_d3 = man_temp_d3[1:1] ? man_round1_d3 : man_round0_d3;
		end
		default: begin
			man_rounded_d3 = 'b0;
		end
	endcase
end
////////////////////////////////////////////////
//normalize
wire	[24	:0]	man_normalized_d3;
wire	[8	:0]	exp_normalized_d3;
wire	[8	:0]	exp_bias_d3;

assign man_normalized_d3 = man_rounded_d3[24:24] ? man_rounded_d3 >> 'b1 : man_rounded_d3;
assign exp_normalized_d3 = man_rounded_d3[24:24] ? exp_temp_d3 + 'b1 : exp_temp_d3;
assign exp_bias_d3 = man_normalized_d3[23:23] ? exp_normalized_d3 + 'd127 : 'b0;
////////////////////////////////////////////////
//select the final result
wire			special;
wire			of_d3;
wire	[7	:0]	exp_d3;
wire	[22	:0]	man_d3;
assign special = zero_d3 || infinity_d3 || snan_d3 || qnan_d3;
assign of_d3 = ~special && $signed(exp_normalized_d3) > $signed('d127);
assign exp_d3 = zero_d3 ? 'b0 : 
				infinity_d3 || snan_d3 || qnan_d3 || of_d3 ? 'b1111_1111 : exp_bias_d3[7:0];
assign man_d3 = zero_d3 ? 'b0 : 
				infinity_d3 ? 'b0 :
				snan_d3 ? {1'b0, nan_load_d3} :
				qnan_d3 ? {1'b1, nan_load_d3} :
				of_d3 ? 'b0 : man_normalized_d3[22:0];
////////////////////////////////////////////////
////////////////////////////////////////////////
dff #(32) result_dff_d4	(.clock(clock), .d({sign_d3, exp_d3, man_d3}), .q(result));
dff #(1	) nv_dff_d4		(.clock(clock), .d(nv_d3					), .q(nv	));
dff #(1	) of_dff_d4		(.clock(clock), .d(of_d3					), .q(of	));

endmodule
