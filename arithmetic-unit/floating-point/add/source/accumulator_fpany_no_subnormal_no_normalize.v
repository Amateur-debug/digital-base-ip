module accumulator_fpany_no_subnormal_no_normalize
#(
    parameter E = 5,
    parameter M = 10,
    parameter INT = 4,
    parameter FRAC = 20,
    parameter PWIDTH = INT + FRAC
)
(

    input                   clock   ,

    input                   clear   ,
    input   [E + M     :0]  src     ,   //input at d0
    output  [E + PWIDTH:0]  result      //output at d1
);
////////////////////////////////////////////////
wire                src_sign;
wire [E - 1     :0] src_exp;
wire [M - 1     :0] src_man;
wire                result_sign;
wire [E - 1     :0] result_exp;
wire [PWIDTH - 1:0] result_man;

assign src_sign = src[E + M];
assign src_exp  = src[E + M - 1:M];
assign src_man  = src[M - 1:0];
assign result_sign = result[E + PWIDTH];
assign result_exp  = result[E + PWIDTH - 1:PWIDTH];
assign result_man  = result[PWIDTH - 1:0];
////////////////////////////////////////////////
// wire [E      :0] exp_diff;
// wire             exp_compare;
// wire [E - 1  :0] exp_temp;
// wire [E - 1  :0] rshift_bits;

// assign exp_diff = {src_exp[E - 1], src_exp} + ~{result_exp[E - 1], result_exp} + 'b1;
// assign exp_compare = exp_diff[E];
// assign exp_temp = exp_compare ? result_exp : src_exp;
// assign rshift_bits = exp_compare ? ~exp_diff[E - 1:0] + 'b1 : exp_diff[E - 1:0];
////////////////////////////////////////////////
wire                exp_compare;
wire    [E - 1  :0] sub1;
wire    [E - 1  :0] sub2;
wire    [E      :0] exp_diff;
wire    [E - 1  :0] exp_temp;
wire    [E - 1  :0] rshift_bits;

assign exp_compare = src_exp < result_exp;
assign sub1 = exp_compare ? result_exp : src_exp;
assign sub2 = exp_compare ? src_exp : result_exp;
assign exp_diff = sub1 - sub2;
assign exp_temp = exp_compare ? result_exp : src_exp;
assign rshift_bits = exp_diff;
////////////////////////////////////////////////
// transfer source code to complement
wire    [1      :0] complement_select;
wire    [PWIDTH :0] to_be_complement;
wire    [PWIDTH :0] man_complement;
wire    [PWIDTH :0] src_man_complement;
wire    [PWIDTH :0] result_man_complement;

assign complement_select[0] = src_sign == result_sign;
assign complement_select[1] = (src_sign != result_sign) & src_sign;
assign to_be_complement = src_sign ? {{INT{1'b0}}, 1'b1, src_man, {(FRAC-M){1'b0}}} : {1'b0, result_man};
assign man_complement = ~to_be_complement + 'b1;
assign src_man_complement = complement_select[1] ? man_complement : {{INT{1'b0}}, 1'b1, src_man, {(FRAC-M){1'b0}}};
assign result_man_complement = complement_select[0] | complement_select[1] ? {1'b0, result_man} : man_complement;
////////////////////////////////////////////////
// align
wire signed [PWIDTH :0]    data_shift;
wire        [PWIDTH :0]    data_shifted;
wire        [PWIDTH :0]    adder_src1;
wire        [PWIDTH :0]    adder_src2;

assign data_shift = exp_compare ? src_man_complement : result_man_complement;
assign data_shifted = data_shift >>> rshift_bits;
assign adder_src1 = exp_compare ? result_man_complement : src_man_complement;
assign adder_src2 = data_shifted;
////////////////////////////////////////////////
// add
wire    [PWIDTH :0] man_sum;

assign man_sum = adder_src1 + adder_src2;
////////////////////////////////////////////////
// transfer complement to source code
wire                sign_d0;
wire    [PWIDTH:0]  man_temp;

assign sign_d0 = src_sign == result_sign ? src_sign : man_sum[PWIDTH];
assign man_temp = (src_sign != result_sign) & man_sum[PWIDTH] ? ~man_sum + 'b1 : man_sum;
// assign man_temp = man_sum;
////////////////////////////////////////////////
// normalize
wire [E - 1     :0] exp_d0;
wire [PWIDTH - 1:0] man_d0;

assign exp_d0 = exp_temp;
assign man_d0 = man_temp[PWIDTH - 1:0];
////////////////////////////////////////////////
dff #(PWIDTH+E+1) result_dff(.clock(clock), .d({sign_d0, exp_d0, man_d0} & {(PWIDTH+E+1){~clear}}), .q(result));
// assign result = {sign_d0, exp_d0, man_d0};

endmodule
