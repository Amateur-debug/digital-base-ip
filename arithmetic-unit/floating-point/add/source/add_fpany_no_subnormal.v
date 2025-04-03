module add_fpany_no_subnormal
#(
    parameter E = 4,
    parameter M = 3
)
(

    input               clock   ,
    input   [E + M  :0] src1    ,   //input at d0
    input   [E + M  :0] src2    ,   //input at d0
    output  [E + M  :0] result      //output at d1
);
////////////////////////////////////////////////
wire            sign1;
wire            sign2;
wire [E - 1 :0] exp1;
wire [E - 1 :0] exp2;
wire [M - 1 :0] man1;
wire [M - 1 :0] man2;

assign sign1 = src1[E + M];
assign sign2 = src2[E + M];
assign exp1  = src1[E + M - 1:M];
assign exp2  = src2[E + M - 1:M];
assign man1  = src1[M - 1:0];
assign man2  = src2[M - 1:0];
////////////////////////////////////////////////
/*
wire [E  :0] exp_diff;
wire [E - 1 :0] exp_temp;
wire [E - 1 :0] rshift_bits;

assign exp_diff = {exp1[E - 1], exp1} + ~{exp2[E - 1], exp2} + 'b1;
assign exp_temp = exp_diff[E] ? exp2 : exp1;
assign rshift_bits = exp_diff[E] ? ~exp_diff[E - 1:0] + 'b1 : exp_diff[E - 1:0];
*/
////////////////////////////////////////////////
wire            exp_compare;
wire [E - 1 :0] sub1;
wire [E - 1 :0] sub2;
wire [E     :0] exp_diff;
wire [E - 1 :0] exp_temp;
wire [E - 1 :0] rshift_bits;

assign exp_compare = exp1 < exp2;
assign sub1 = exp_compare ? exp2 : exp1;
assign sub2 = exp_compare ? exp1 : exp2;
assign exp_diff = sub1 - sub2;
assign exp_temp = exp_compare ? exp2 : exp1;
assign rshift_bits = exp_diff;
////////////////////////////////////////////////
//transfer source code to complement
wire [1     :0] complement_select;
wire [M - 1 :0] to_be_complement;
wire [M + 1 :0] man_complement;
wire [M + 1 :0] man1_complement;
wire [M + 1 :0] man2_complement;

assign complement_select[0] = sign1 == sign2;
assign complement_select[1] = (sign1 != sign2) & sign1;
assign to_be_complement = sign1 ? man1 : man2;
assign man_complement = {2'b10, ~to_be_complement} + 'b1;
assign man1_complement = complement_select[1] ? man_complement : {2'b01, man1};
assign man2_complement = complement_select[0] | complement_select[1] ? {2'b01, man2} : man_complement;
////////////////////////////////////////////////
// align
wire signed [M + 3 :0] data_shift;
wire        [M + 1 :0] data_shifted;
wire                   guard;
wire                   round;
wire        [M + 1 :0] adder_src1;
wire        [M + 1 :0] adder_src2;

assign data_shift = exp_compare ? {man1_complement, 2'b0} : {man2_complement, 2'b0};
assign {data_shifted, guard, round} = data_shift >>> rshift_bits;
assign adder_src1 = exp_compare ? man2_complement : man1_complement;
assign adder_src2 = data_shifted;
////////////////////////////////////////////////
// add
wire [M + 1 :0] man_sum;

assign man_sum = adder_src1 + adder_src2;
////////////////////////////////////////////////
// transfer complement to source code
wire            sign_d0;
wire [M + 1 :0] man_temp;

assign sign_d0 = sign1 == sign2 ? sign1 : man_sum[M + 1];
assign man_temp = (sign1 != sign2) & man_sum[M + 1] ? ~man_sum + 'b1 : man_sum;
////////////////////////////////////////////////
wire [M                 :0] unencoded;
wire                        lzero_valid;
wire [$clog2(M + 1) - 1 :0] lzero_position;

genvar i;
generate
    for (i = 0; i < M + 1; i = i + 1) begin: reverse
        assign unencoded[i] = man_temp[M-i];
    end
endgenerate

priority_encoder #(.WIDTH(M+1), .LSB_PRIORITY("HIGH")) u_priority_encoder
(.unencoded(unencoded), .valid(lzero_valid), .encoded(lzero_position));
////////////////////////////////////////////////
// get the shift direction
wire shift_direction; //0: left; 1: right

assign shift_direction = man_temp[M + 1];
////////////////////////////////////////////////
// normalize
wire [M + 3:0] man_rshifted;
wire [M + 3:0] man_lshifted;
wire [M + 3:0] man_normalized;
wire [E - 1:0] exp_shift_num;

assign man_rshifted = {man_temp, guard, round} >> shift_direction;
assign man_lshifted = {man_temp, guard, round} << lzero_position;
assign man_normalized = shift_direction ? man_rshifted : man_lshifted;

assign exp_shift_num = shift_direction ? 'b1 : {{(E-$clog2(M + 1)){1'b1}}, ~lzero_position} + 'b1;
////////////////////////////////////////////////
// round
wire [M + 1 :0] man_rounded;

assign man_rounded = man_normalized[M + 3:2] + man_normalized[1];
////////////////////////////////////////////////
// normalize
wire [E - 1:0] exp_d0;
wire [M - 1:0] man_d0;

assign exp_d0 = exp_temp + exp_shift_num + man_rounded[M + 1];
assign man_d0 = man_rounded[M + 1] ? man_rounded[M:1] : man_rounded[M - 1:0];
////////////////////////////////////////////////
dff #(M+E+1) result_dff(.clock(clock), .d({sign_d0, exp_d0, man_d0}), .q(result));

endmodule
