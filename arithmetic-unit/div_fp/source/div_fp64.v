`include "mul_fp.vh"
module div_fp64(

	input  		    clock    ,
	input  		    reset    ,
	input   	    valid_in ,
	input	[2 	:0]	rm       ,
	input   [63	:0]	dividend ,
	input   [63	:0]	divisor  ,
	output  		valid_out,
	output  [63	:0]	quotient ,
	output			nv	     ,
	output			dz	     ,
	output			of		 ,
	output			uf	     ,
	output			nx		 
);
////////////////////////////////////////////////
wire			dividend_sign;
wire			divisor_sign;
wire	[10	:0]	dividend_exp;
wire	[10	:0] divisor_exp;
wire	[51	:0] dividend_man;
wire	[51	:0] divisor_man;

assign dividend_sign = dividend[63:63];
assign divisor_sign = divisor[63:63];
assign dividend_exp = dividend[62:52];
assign divisor_exp = divisor[62:52];
assign dividend_man = dividend[51:0];
assign divisor_man = divisor[51:0];
////////////////////////////////////////////////
wire dividend_normal;
wire divisor_normal;
wire dividend_subnormal;
wire divisor_subnormal;
wire dividend_zero;	
wire divisor_zero;	
wire dividend_infinity;
wire divisor_infinity;
wire dividend_snan;
wire divisor_snan;
wire dividend_qnan;
wire divisor_qnan;	

assign dividend_normal = dividend_exp != 11'b0 && dividend_exp != 11'b111_1111_1111;
assign divisor_normal = divisor_exp != 11'b0 && divisor_exp != 11'b111_1111_1111;

assign dividend_subnormal = dividend_exp == 11'b0 && dividend_man != 52'b0;
assign divisor_subnormal = divisor_exp == 11'b0 && divisor_man != 52'b0;

assign dividend_zero = dividend_exp == 11'b0 && dividend_man == 52'b0;
assign divisor_zero = divisor_exp == 11'b0 && divisor_man == 52'b0;

assign dividend_infinity = dividend_exp == 11'b111_1111_1111 && dividend_man == 52'b0;
assign divisor_infinity = divisor_exp == 11'b111_1111_1111 && divisor_man == 52'b0;

assign dividend_snan = dividend_exp == 11'b111_1111_1111 && !dividend_man[51:51] && dividend_man[50:0] != 51'b0;
assign divisor_snan = divisor_exp == 11'b111_1111_1111 && !divisor_man[51:51] && divisor_man[50:0] != 51'b0;

assign dividend_qnan = dividend_exp == 11'b111_1111_1111 && dividend_man[51:51];
assign divisor_qnan = divisor_exp == 11'b111_1111_1111 && divisor_man[51:51];
////////////////////////////////////////////////
wire 			zero;	
wire 			infinity;
wire 			snan;
wire 			qnan;
wire	[50	:0]	nan_load;
wire 			nv_d0;
wire 			dz_d0;

assign zero = dividend_zero && (divisor_normal || divisor_subnormal || divisor_infinity);
assign infinity = dividend_infinity && (divisor_normal || divisor_subnormal);
assign snan = dividend_snan || divisor_snan;
assign qnan = dividend_qnan || divisor_qnan || dividend_zero && divisor_zero || dividend_infinity && divisor_infinity;
assign nan_load = dividend_snan || dividend_qnan ? dividend_man[50:0] : 
				  divisor_snan || divisor_qnan ? divisor_man[50:0] : 51'b1;
assign nv_d0 = dividend_zero && divisor_zero || dividend_infinity && divisor_infinity || 
			   dividend_snan || divisor_snan || dividend_qnan || divisor_qnan;
assign dz_d0 = (dividend_normal || dividend_subnormal) && divisor_zero;
////////////////////////////////////////////////
wire sign;
assign sign = dividend_sign ^ divisor_sign;
////////////////////////////////////////////////
//多一位编码承载溢出
wire	[11	:0]	dividend_exp_true;
wire	[11	:0]	divisor_exp_true;
wire	[11	:0]	divisor_exp_negative;
wire	[11	:0]	exp_temp;

assign dividend_exp_true = dividend_normal ? {1'b0, dividend_exp} + 12'b1100_0000_0001 : 12'b1100_0000_0010;
assign divisor_exp_true = divisor_normal ? {1'b0, divisor_exp} + 12'b1100_0000_0001 : 12'b1100_0000_0010;
assign divisor_exp_negative = ~divisor_exp_true + 'b1;
assign exp_temp = dividend_exp_true + divisor_exp_negative;
////////////////////////////////////////////////
//恢复隐藏的1
wire	[52	:0]	dividend_man_true;
wire	[52	:0]	divisor_man_true;

assign dividend_man_true = {dividend_normal, dividend_man};
assign divisor_man_true = {divisor_normal, divisor_man};

////////////////////////////////////////////////
wire 			man_div_finish;
wire 			almost_valid;
wire	[107:0]	man_temp_d1;
div_int #(108) u_div_int(

    .clock    	 (clock								),
	.reset    	 (reset								),					 
    .valid_in 	 (valid_in							),
    .opcode   	 (1'b0								),
    .dividend 	 ({1'b0, dividend_man_true, 54'b0}	),
    .divisor  	 ({55'b0, divisor_man_true}			),		    
    .valid_out	 (man_div_finish					),
	.almost_valid(almost_valid						),
    .quotient 	 (man_temp_d1						),
    .remainder	 (									)
);
////////////////////////////////////////////////
wire			zero_d1;
wire			infinity_d1;
wire			snan_d1;
wire			qnan_d1;
wire	[50	:0] nan_load_d1;
wire			nv_d1;
wire			dz_d1;
wire			sign_d1;
wire	[11	:0] exp_temp_d1;
wire	[2	:0] rm_d1;

dff_en #(1	) zero_dff_en_d1	(.clock(clock), .en(almost_valid), .d(zero		), .q(zero_d1		));
dff_en #(1	) infinity_dff_en_d1(.clock(clock), .en(almost_valid), .d(infinity	), .q(infinity_d1	));
dff_en #(1	) snan_dff_en_d1	(.clock(clock), .en(almost_valid), .d(snan		), .q(snan_d1		));
dff_en #(1	) qnan_dff_en_d1	(.clock(clock), .en(almost_valid), .d(qnan		), .q(qnan_d1		));
dff_en #(1	) nv_dff_en_d1		(.clock(clock), .en(almost_valid), .d(nv_d0		), .q(nv_d1			));
dff_en #(1	) dz_dff_en_d1		(.clock(clock), .en(almost_valid), .d(dz_d0		), .q(dz_d1			));
dff_en #(1	) sign_dff_en_d1	(.clock(clock), .en(almost_valid), .d(sign		), .q(sign_d1		));
dff_en #(12	) exp_temp_dff_en_d1(.clock(clock), .en(almost_valid), .d(exp_temp	), .q(exp_temp_d1	));
dff_en #(3	) rm_dff_en_d1		(.clock(clock), .en(almost_valid), .d(rm		), .q(rm_d1			));
dff_en #(51	) nan_load_dff_en_d1(.clock(clock), .en(almost_valid), .d(nan_load	), .q(nan_load_d1	));
////////////////////////////////////////////////
//Leading 0 detection
wire	[5	:0]	p1_d1;
wire			v1_d1;
lzd_64bits u1_lzd_64bits(

    .src({man_temp_d1[107:55], 11'b0}	),
	.p  (p1_d1							),
	.v  (v1_d1							)
);

wire	[5	:0]	p2_d1;
wire			v2_d1;
lzd_64bits u2_lzd_64bits(

    .src({man_temp_d1[54:0], 9'b0}	),
	.p  (p2_d1						),
	.v  (v2_d1						)
);
////////////////////////////////////////////////
//Calculate the shift number
wire	[12	:0] lshift_max_d1;
wire	[12	:0] rshift_min_d1;
wire			shift_direction_d1; //0-left, 1-right
wire	[6	:0] lshift_bits_d1;
wire	[6	:0] lshift_true_d1;
wire	[9	:0] rshift_bits_d1;
wire	[9	:0] rshift_true_d1;

assign lshift_max_d1 = {exp_temp_d1[11:11], exp_temp_d1} + 'd1022;
assign rshift_min_d1 = $signed(-'d1021) + ~{exp_temp_d1[11:11], exp_temp_d1};	//assign rshift_max_d1 = $signed(-'d1022) + ~{exp_temp_d1[11:11], exp_temp_d1} + 'b1;

assign shift_direction_d1 = $signed(rshift_min_d1) > $signed('b0) || v1_d1;

assign lshift_bits_d1 = p2_d1;
assign rshift_bits_d1 = v1_d1 ? 'd53 - p1_d1 : 'b0;

assign lshift_true_d1 = $signed(lshift_bits_d1) < $signed(lshift_max_d1) ? lshift_bits_d1 : 
						lshift_max_d1[12:12] ? 'b0 : lshift_max_d1[6:0];
assign rshift_true_d1 = $signed(rshift_bits_d1) > $signed(rshift_min_d1) ? rshift_bits_d1 : 
						rshift_min_d1[12:12] ? 'b0 : rshift_min_d1[9:0];
////////////////////////////////////////////////
//normalize
wire	[107:0]	man_lshifted_d1;
wire	[107:0]	man_rshifted_d1;
wire	[54	:0]	man_normalized_d1;
wire	[107:0]	dis_bits_d1;
wire	[11	:0]	exp_lshifted_d1;
wire	[11	:0]	exp_rshifted_d1;
wire	[11	:0]	exp_normalized_d1;

assign man_lshifted_d1 = man_temp_d1 << lshift_true_d1;
assign {man_rshifted_d1, dis_bits_d1} = rshift_true_d1 < 'd108 ? {man_temp_d1, 108'b0} >> rshift_true_d1 : {108'b0, man_temp_d1};
assign man_normalized_d1[54:1] = shift_direction_d1 ? man_rshifted_d1[54:1] : man_lshifted_d1[54:1];
assign man_normalized_d1[0:0] = shift_direction_d1 ? |{man_rshifted_d1[0:0], dis_bits_d1} : |man_lshifted_d1[0:0];

assign exp_lshifted_d1 = exp_temp_d1 + ~{5'b0, lshift_true_d1} + 'b1;
assign exp_rshifted_d1 = exp_temp_d1 + {2'b0, rshift_true_d1};
assign exp_normalized_d1 = shift_direction_d1 ? exp_rshifted_d1 : exp_lshifted_d1;
////////////////////////////////////////////////
wire			zero_d2;
wire			infinity_d2;
wire			snan_d2;
wire			qnan_d2;
wire			nv_d2;
wire			dz_d2;
wire			sign_d2;
wire	[11	:0] exp_temp_d2;
wire	[54	:0] man_temp_d2;
wire	[2	:0] rm_d2;
wire	[50	:0] nan_load_d2;
wire			valid_out_d2;

dff #(1	) zero_dff_d2		(.clock(clock), .d(zero_d1			), .q(zero_d2		));
dff #(1	) infinity_dff_d2	(.clock(clock), .d(infinity_d1		), .q(infinity_d2	));
dff #(1	) snan_dff_d2		(.clock(clock), .d(snan_d1			), .q(snan_d2		));
dff #(1	) qnan_dff_d2		(.clock(clock), .d(qnan_d1			), .q(qnan_d2		));
dff #(1	) nv_dff_d2			(.clock(clock), .d(nv_d1			), .q(nv_d2			));
dff #(1	) dz_dff_d2			(.clock(clock), .d(dz_d1			), .q(dz_d2			));
dff #(1	) sign_dff_d2		(.clock(clock), .d(sign_d1			), .q(sign_d2		));
dff #(12) exp_temp_dff_d2	(.clock(clock), .d(exp_normalized_d1), .q(exp_temp_d2	));
dff #(55) man_temp_dff_d2	(.clock(clock), .d(man_normalized_d1), .q(man_temp_d2	));
dff #(3	) rm_dff_d2			(.clock(clock), .d(rm_d1			), .q(rm_d2			));
dff #(51) nan_load_dff_d2	(.clock(clock), .d(nan_load_d1		), .q(nan_load_d2	));
dff_ar #(1) valid_out_dff_ar_d2(.clock(clock), .reset(reset), .d(man_div_finish), .q(valid_out_d2));
////////////////////////////////////////////////
//round
wire	[52	:0] man_round1_d2;
wire	[52	:0]	man_round0_d2;
reg		[52	:0]	man_rounded_d2;

assign man_round1_d2 = man_temp_d2[54:2] + 'b1;
assign man_round0_d2 = man_temp_d2[54:2];
always@(*) begin
	case(rm_d2)
		`RTE: begin
			case(man_temp_d2[1:0])
				2'b00: begin
					man_rounded_d2 = man_round0_d2;
				end
				2'b01: begin
					man_rounded_d2 = man_round0_d2;
				end
				2'b10: begin
					man_rounded_d2 = man_temp_d2[2:2] ? man_round1_d2 : man_round0_d2;
				end
				2'b11: begin
					man_rounded_d2 = man_round1_d2;
				end
			endcase
		end
		`RTZ: begin
			man_rounded_d2 = man_round0_d2;
		end
		`RDN: begin
			man_rounded_d2 = sign_d2 ? (|man_temp_d2[1:0] ? man_round1_d2 : man_round0_d2) : man_round0_d2;
		end
		`RUP: begin
			man_rounded_d2 = sign_d2 ? man_round0_d2 : (|man_temp_d2[1:0] ? man_round1_d2 : man_round0_d2);
		end
		`RMM: begin
			man_rounded_d2 = man_temp_d2[1:1] ? man_round1_d2 : man_round0_d2;
		end
		default: begin
			man_rounded_d2 = 'b0;
		end
	endcase
end
////////////////////////////////////////////////
wire	[11	:0]	exp_bias_d2;

assign exp_bias_d2 = man_rounded_d2[52:52] ? exp_temp_d2 + 'd1023 : 'b0;
////////////////////////////////////////////////
//select the final result
wire			special;
wire			of_d2;
wire			uf_d2;
wire			nx_d2;
wire	[10	:0]	exp_d2;
wire	[51	:0]	man_d2;
assign special = zero_d2 || infinity_d2 || snan_d2 || qnan_d2;
assign of_d2 = ~special && $signed(exp_temp_d2) > $signed('d1023);
assign uf_d2 = ~special && exp_bias_d2 == 'b0;
assign nx_d2 = of_d2 || uf_d2;
assign exp_d2 = zero_d2 ? 'b0 : 
				infinity_d2 || snan_d2 || qnan_d2 || of_d2 || dz_d2 ? 'b111_1111_1111 : exp_bias_d2[10:0];
assign man_d2 = zero_d2 ? 'b0 :  
				infinity_d2 ? 'b0 :
				snan_d2 ? {1'b0, nan_load_d2} :
				qnan_d2 ? {1'b1, nan_load_d2} :
				of_d2 || dz_d2 ? 'b0 : man_rounded_d2[51:0];
////////////////////////////////////////////////
////////////////////////////////////////////////
dff_ar #(1) valid_out_dff_ar_d3(.clock(clock), .reset(reset), .d(valid_out_d2), .q(valid_out));
dff #(64) result_dff_d3	(.clock(clock), .d({sign_d2, exp_d2, man_d2}), .q(quotient	));
dff #(1	) nv_dff_d3		(.clock(clock), .d(nv_d2					), .q(nv		));
dff #(1	) dz_dff_d3		(.clock(clock), .d(dz_d2					), .q(dz		));
dff #(1	) of_dff_d3		(.clock(clock), .d(of_d2					), .q(of		));
dff #(1	) uf_dff_d3		(.clock(clock), .d(uf_d2					), .q(uf		));
dff #(1	) nx_dff_d3		(.clock(clock), .d(nx_d2					), .q(nx		));

endmodule
