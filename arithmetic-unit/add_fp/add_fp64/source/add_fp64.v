`include "mul_fp.vh"
module add_fp64(

	input  		   	clock  ,
	input   	   	en     ,	//input at d0
	input	[2 	:0]	rm     ,	//input at d0
	input	[63	:0]	src1   ,	//input at d0
	input	[63	:0]	src2   ,	//input at d0
	output	[63	:0]	result ,	//output at d4
	output			nv	   ,
	output			of	   
);
////////////////////////////////////////////////
wire			sign1;
wire			sign2;
wire	[10	:0]	exp1;
wire	[10	:0]	exp2;
wire	[51	:0]	man1;
wire	[51	:0]	man2;

assign sign1 = src1[63:63];
assign sign2 = src2[63:63];
assign exp1 = src1[62:52];
assign exp2 = src2[62:52];
assign man1 = src1[51:0];
assign man2 = src2[51:0];
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

assign normal1 = exp1 != 11'b0 && exp1 != 11'b111_1111_1111;
assign normal2 = exp2 != 11'b0 && exp2 != 11'b111_1111_1111;

assign subnormal1 = exp1 == 11'b0 && man1 != 52'b0;
assign subnormal2 = exp2 == 11'b0 && man2 != 52'b0;

assign zero1 = exp1 == 11'b0 && man1 == 52'b0;
assign zero2 = exp2 == 11'b0 && man2 == 52'b0;

assign infinity1 = exp1 == 11'b111_1111_1111 && man1 == 52'b0;
assign infinity2 = exp2 == 11'b111_1111_1111 && man2 == 52'b0;

assign snan1 = exp1 == 11'b111_1111_1111 && !man1[51:51] && man1[50:0] != 51'b0;
assign snan2 = exp2 == 11'b111_1111_1111 && !man2[51:51] && man2[50:0] != 51'b0;

assign qnan1 = exp1 == 11'b111_1111_1111 && man1[51:51];
assign qnan2 = exp2 == 11'b111_1111_1111 && man2[51:51];
////////////////////////////////////////////////
wire			infinity;
wire			infinity_sign;
wire			snan;
wire			qnan;
wire	[50	:0] nan_load;
wire			nv_d0;

assign infinity = infinity1 && (normal2 || subnormal2) || infinity2 && (normal1 || subnormal1) || infinity1 && infinity2 && (sign1 ^~ sign2);
assign infinity_sign = sign1 && sign2;
assign snan = snan1 || snan2;
assign qnan = qnan1 || qnan2 || infinity1 && infinity2 && (sign1 ^ sign2);
assign nan_load = snan1 || qnan1 ? man1[50:0] : 
				  snan2 || qnan2 ? man2[50:0] : 51'b1;
assign nv_d0 = infinity1 && infinity2 && (sign1 ^ sign2) || snan1 || snan2 || qnan1 || qnan2;
////////////////////////////////////////////////
//多一位编码承载溢出
wire	[10	:0]	exp1_true;
wire	[10	:0]	exp2_true;
wire	[11	:0]	exp_diff;
wire	[10	:0]	exp_temp;
wire	[11	:0]	rshift_bits;

assign exp1_true = normal1 ? exp1 + 11'b100_0000_0001 : 11'b100_0000_0010;
assign exp2_true = normal2 ? exp2 + 11'b100_0000_0001 : 11'b100_0000_0010;
assign exp_diff = {exp1_true[10:10], exp1_true} + ~{exp2_true[10:10], exp2_true} + 'b1;
assign exp_temp = exp_diff[11:11] ? exp2_true : exp1_true;
assign rshift_bits = exp_diff[11:11] ? ~exp_diff + 'b1 : exp_diff;
////////////////////////////////////////////////
//恢复隐藏的1  
wire	[52	:0]	man1_true;
wire	[52	:0]	man2_true;

assign man1_true = {normal1, man1};
assign man2_true = {normal2, man2};
////////////////////////////////////////////////
//transfer source code to complement
wire	[53	:0]	man1_complement;
wire	[53	:0]	man2_complement;

assign man1_complement = sign1 ? ~{1'b0, man1_true} + 'b1 : {1'b0, man1_true};
assign man2_complement = sign2 ? ~{1'b0, man2_true} + 'b1 : {1'b0, man2_true};
////////////////////////////////////////////////
//add round bit and sticky bit
wire	signed	[62	:0]	data_shift;
wire			[62	:0]	data_shifted;
wire			[63	:0]	adder_src1; //多一位编码承载溢出
wire			[63	:0]	adder_src2;

assign data_shift = exp_diff[11:11] ? {man1_complement, 9'b0} : {man2_complement, 9'b0};
assign data_shifted = data_shift >>> rshift_bits;
assign adder_src1 = exp_diff[11:11] ? {data_shifted[62:62], data_shifted} : {man1_complement[53:53], man1_complement, 9'b0};
assign adder_src2 = exp_diff[11:11] ? {man2_complement[53:53], man2_complement, 9'b0} : {data_shifted[62:62], data_shifted};
////////////////////////////////////////////////
wire	[63	:0]	adder_src1_d1;
wire	[63	:0]	adder_src2_d1;
wire	[10	:0]	exp_temp_d1;
wire			infinity_d1;
wire			infinity_sign_d1;
wire			snan_d1;
wire			qnan_d1;
wire	[50	:0]	nan_load_d1;
wire			nv_d1;
wire	[2 	:0]	rm_d1;

dff #(64) adder_src1_dff_d1		(.clock(clock), .d(adder_src1	), .q(adder_src1_d1		));
dff #(64) adder_src2_dff_d1		(.clock(clock), .d(adder_src2	), .q(adder_src2_d1		));
dff #(11) exp_temp_dff_d1		(.clock(clock), .d(exp_temp		), .q(exp_temp_d1		));
dff #(1 ) infinity_dff_d1		(.clock(clock), .d(infinity		), .q(infinity_d1		));
dff #(1 ) infinity_sign_dff_d1	(.clock(clock), .d(infinity_sign), .q(infinity_sign_d1	));
dff #(1 ) snan_dff_d1			(.clock(clock), .d(snan			), .q(snan_d1			));
dff #(1 ) qnan_dff_d1			(.clock(clock), .d(qnan			), .q(qnan_d1			));
dff #(51) nan_load_dff_d1		(.clock(clock), .d(nan_load		), .q(nan_load_d1		));
dff #(1 ) nv_dff_d1				(.clock(clock), .d(nv_d0		), .q(nv_d1				));
dff #(3 ) rm_dff_d1				(.clock(clock), .d(rm			), .q(rm_d1				));
////////////////////////////////////////////////
wire	[63	:0]	man_sum_d1;

cla_64bits u_cla_64bits(

    .a   (adder_src1_d1),
    .b   (adder_src2_d1),
    .cin (1'b0),
    .s   (man_sum_d1),
	.pm  (),
	.gm  ()
);
////////////////////////////////////////////////
//transfer complement to source code
wire			sign_d1;
wire	[62	:0]	man_temp_d1;
assign sign_d1 = infinity_d1 ? infinity_sign_d1 : man_sum_d1[63:63];
assign man_temp_d1 = sign_d1 ? ~man_sum_d1[62:0] + 'b1 : man_sum_d1[62:0];

////////////////////////////////////////////////
//Leading 0 detection
wire	[5	:0]	p_d1;
wire			v_d1;
lzd_64bits u_lzd_64bits(

    .src({man_temp_d1, 1'b0}),
	.p  (p_d1),
	.v  (v_d1)
);
////////////////////////////////////////////////
wire	[5	:0] p_d2;
wire			sign_d2;
wire	[62	:0] man_temp_d2;
wire	[10	:0]	exp_temp_d2;
wire			infinity_d2;
wire			snan_d2;
wire			qnan_d2;
wire	[50	:0] nan_load_d2;
wire			nv_d2;
wire	[2	:0]	rm_d2;

dff #(6 ) p_dff_d2			(.clock(clock), .d(p_d1			), .q(p_d2			));
dff #(1 ) sign_dff_d2		(.clock(clock), .d(sign_d1		), .q(sign_d2		));
dff #(63) man_temp_dff_d2	(.clock(clock), .d(man_temp_d1	), .q(man_temp_d2	));
dff #(11) exp_temp_dff_d2	(.clock(clock), .d(exp_temp_d1	), .q(exp_temp_d2	));
dff #(1	) infinity_dff_d2	(.clock(clock), .d(infinity_d1	), .q(infinity_d2	));
dff #(1	) snan_dff_d2		(.clock(clock), .d(snan_d1		), .q(snan_d2		));
dff #(1	) qnan_dff_d2		(.clock(clock), .d(qnan_d1		), .q(qnan_d2		));
dff #(51) nan_load_dff_d2	(.clock(clock), .d(nan_load_d1	), .q(nan_load_d2	));
dff #(1	) nv_dff_d2			(.clock(clock), .d(nv_d1		), .q(nv_d2			));
dff #(3	) rm_dff_d2			(.clock(clock), .d(rm_d1		), .q(rm_d2			));
////////////////////////////////////////////////
//Calculate the shift number
wire	[10	:0] lshift_max_d2;
wire			shift_direction_d2; //0-left, 1-right
wire	[5	:0]	lshift_bits_d2;
wire	[5	:0] lshift_true_d2;
wire			rshift_true_d2;

assign lshift_max_d2 = exp_temp_d2 + 'd1022;
assign shift_direction_d2 = man_temp_d2[62:62];
assign lshift_bits_d2 = p_d2 - 'b1;
assign lshift_true_d2 = lshift_bits_d2 < lshift_max_d2 ? lshift_bits_d2 : lshift_max_d2[5:0];
assign rshift_true_d2 = man_temp_d2[62:62] ? 'b1 : 'b0;
////////////////////////////////////////////////
//normalize
wire	[62	:0]	man_lshifted_d2;
wire	[63	:0]	man_rshifted_d2;
wire	[55	:0]	man_normalized_d2;
wire	[10	:0]	exp_lshifted_d2;
wire	[11	:0]	exp_rshifted_d2;
wire	[11	:0]	exp_normalized_d2;

assign man_lshifted_d2 = man_temp_d2 << lshift_true_d2;
assign man_rshifted_d2 = {man_temp_d2, 1'b0} >> rshift_true_d2;
assign man_normalized_d2[55:1] = shift_direction_d2 ? man_rshifted_d2[63:9] : man_lshifted_d2[62:8];
assign man_normalized_d2[0:0] = shift_direction_d2 ? |man_rshifted_d2[8:0] : |man_lshifted_d2[7:0];

assign exp_lshifted_d2 = exp_temp_d2 + ~{5'b0, lshift_true_d2} + 'b1;
assign exp_rshifted_d2 = {exp_temp_d2[10:10], exp_temp_d2} + {11'b0, rshift_true_d2};
assign exp_normalized_d2 = shift_direction_d2 ? exp_rshifted_d2 : {exp_lshifted_d2[10:10], exp_lshifted_d2};
////////////////////////////////////////////////
wire			infinity_d3;
wire			snan_d3;
wire			qnan_d3;
wire			nv_d3;
wire			sign_d3;
wire	[11	:0] exp_temp_d3;
wire	[55	:0] man_temp_d3;
wire	[2	:0] rm_d3;
wire	[50	:0] nan_load_d3;

dff #(12) exp_temp_dff_d3	(.clock(clock), .d(exp_normalized_d2), .q(exp_temp_d3	));
dff #(56) man_temp_dff_d3	(.clock(clock), .d(man_normalized_d2), .q(man_temp_d3	));
dff #(1	) infinity_dff_d3	(.clock(clock), .d(infinity_d2		), .q(infinity_d3	));
dff #(1	) snan_dff_d3		(.clock(clock), .d(snan_d2			), .q(snan_d3		));
dff #(1	) qnan_dff_d3		(.clock(clock), .d(qnan_d2			), .q(qnan_d3		));
dff #(1	) nv_dff_d3			(.clock(clock), .d(nv_d2			), .q(nv_d3			));
dff #(1	) sign_dff_d3		(.clock(clock), .d(sign_d2			), .q(sign_d3		));
dff #(3	) rm_dff_d3			(.clock(clock), .d(rm_d2			), .q(rm_d3			));
dff #(51) nan_load_dff_d3	(.clock(clock), .d(nan_load_d2		), .q(nan_load_d3	));
////////////////////////////////////////////////
//round
wire	[53	:0] man_round1_d3;
wire	[53	:0] man_round0_d3;
reg		[53	:0] man_rounded_d3;
assign man_round1_d3 = man_temp_d3[55:2] + 'b1;
assign man_round0_d3 = man_temp_d3[55:2];
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
wire	[53	:0]	man_normalized_d3;
wire	[11	:0]	exp_normalized_d3;
wire	[11	:0]	exp_bias_d3;

assign man_normalized_d3 = man_rounded_d3[53:53] ? man_rounded_d3 >> 'b1 : man_rounded_d3;
assign exp_normalized_d3 = man_rounded_d3[53:53] ? exp_temp_d3 + 'b1 : exp_temp_d3;
assign exp_bias_d3 = man_normalized_d3[52:52] ? exp_normalized_d3 + 'd1023 : 'b0;
////////////////////////////////////////////////
//select the final result
wire			special;
wire			of_d3;
wire	[10	:0] exp_d3;
wire	[51	:0] man_d3;
assign special = infinity_d3 || snan_d3 || qnan_d3;
assign of_d3 = ~special && $signed(exp_normalized_d3) > $signed('d1023);
assign exp_d3 = infinity_d3 || snan_d3 || qnan_d3 || of_d3 ? 'b111_1111_1111 : exp_bias_d3[10:0];
assign man_d3 = infinity_d3 ? 'b0 :
				snan_d3 ? {1'b0, nan_load_d3} :
				qnan_d3 ? {1'b1, nan_load_d3} :
				of_d3 ? 'b0 : man_normalized_d3[51:0];
////////////////////////////////////////////////
////////////////////////////////////////////////
dff #(64) result_dff_d4	(.clock(clock), .d({sign_d3, exp_d3, man_d3}), .q(result));
dff #(1	) nv_dff_d4		(.clock(clock), .d(nv_d3					), .q(nv	));
dff #(1	) of_dff_d4		(.clock(clock), .d(of_d3					), .q(of	));

endmodule
