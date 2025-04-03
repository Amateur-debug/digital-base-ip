module accumulator_fpany_complement_no_subnormal_no_normalize
#(
    parameter E = 5,
    parameter M = 10,
    parameter INT = 3,
    parameter FRAC = 12,
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
wire    [PWIDTH :0] src_man_complement;
wire    [PWIDTH :0] result_man_complement;

assign src_man_complement = src_sign ? {{INT{1'b1}}, 1'b0, ~src_man, {(FRAC-M){1'b1}}} + 'b1 : {{INT{1'b0}}, 1'b1, src_man, {(FRAC-M){1'b0}}};
assign result_man_complement = {result_sign, result_man};
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
// complement output
wire                sign_d0;
wire [E - 1     :0] exp_d0;
wire [PWIDTH - 1:0] man_d0;

assign sign_d0 = man_sum[PWIDTH];
assign exp_d0 = exp_temp;
assign man_d0 = man_sum[PWIDTH - 1:0];
////////////////////////////////////////////////
dff #(PWIDTH+E+1) result_dff(.clock(clock), .d({sign_d0, exp_d0, man_d0} & {(PWIDTH+E+1){~clear}}), .q(result));
// ////////////////////////////////////////////////
// // delay
// wire    [E - 1  :0] exp_temp_d1; 
// wire    [PWIDTH :0] adder_src1_d1; 
// wire    [PWIDTH :0] adder_src2_d1; 

// dff #(E+2*(PWIDTH+1)) d1_dff(.clock(clock), .d({exp_temp, adder_src1, adder_src2} & {(E+2*(PWIDTH+1)){~clear}}), .q({exp_temp_d1, adder_src1_d1, adder_src2_d1}));
// ////////////////////////////////////////////////
// // add
// wire    [PWIDTH :0] man_sum;

// assign man_sum = adder_src1_d1 + adder_src2_d1;
// ////////////////////////////////////////////////
// // complement output
// wire                sign_d1;
// wire [E - 1     :0] exp_d1;
// wire [PWIDTH - 1:0] man_d1;

// assign sign_d1 = man_sum[PWIDTH];
// assign exp_d1 = exp_temp_d1;
// assign man_d1 = man_sum[PWIDTH - 1:0];
// ////////////////////////////////////////////////
// dff #(PWIDTH+E+1) result_dff(.clock(clock), .d({sign_d1, exp_d1, man_d1} & {(PWIDTH+E+1){~clear}}), .q(result));

endmodule
