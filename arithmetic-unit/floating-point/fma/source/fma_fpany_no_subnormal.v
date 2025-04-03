module fma_fpany_no_subnormal
#(
    parameter E_MUL = 5,
    parameter M_MUL = 10,
    parameter E_ADD = 8,
    parameter M_ADD = 23
)
(

    input                       clock   ,

    input   [E_MUL + M_MUL  :0] src0    ,   //input at d0
    input   [E_MUL + M_MUL  :0] src1    ,   //input at d0
    input   [E_ADD + M_ADD  :0] src2    ,   //input at d0
    output  [E_ADD + M_ADD  :0] result      //output at d1
);
////////////////////////////////////////////////
// unpack
wire                src0_sign;
wire [E_MUL - 1 :0] src0_exp;
wire [M_MUL - 1 :0] src0_man;
wire                src1_sign;
wire [E_MUL - 1 :0] src1_exp;
wire [M_MUL - 1 :0] src1_man;
wire                src2_sign;
wire [E_ADD - 1 :0] src2_exp;
wire [M_ADD - 1 :0] src2_man;

assign src0_sign = src0[E_MUL + M_MUL];
assign src0_exp  = src0[E_MUL + M_MUL - 1:M_MUL];
assign src0_man  = src0[M_MUL - 1:0];
assign src1_sign = src1[E_MUL + M_MUL];
assign src1_exp  = src1[E_MUL + M_MUL - 1:M_MUL];
assign src1_man  = src1[M_MUL - 1:0];
assign src2_sign = src2[E_ADD + M_ADD];
assign src2_exp  = src2[E_ADD + M_ADD - 1:M_ADD];
assign src2_man  = src2[M_ADD - 1:0];
////////////////////////////////////////////////
localparam [E_ADD - 1:0] BIAS_MUL = (1 << (E_MUL - 1)) - 1;
localparam [E_ADD - 1:0] BIAS_ADD = (1 << (E_ADD - 1)) - 1;
////////////////////////////////////////////////
// multiplication
wire                        mul_sign;
wire [E_ADD - 1         :0] mul_exp;
wire [2*(M_MUL + 1) - 1 :0] mul_man; // xx.xxxxxx

assign mul_sign = src0_sign ^ src1_sign;
assign mul_exp = src0_exp + src1_exp - 2*BIAS_MUL + BIAS_ADD;
assign mul_man = {1'b1, src0_man} * {1'b1, src1_man};
////////////////////////////////////////////////
// compare
wire                exp_compare;
wire [E_ADD - 1 :0] sub1;
wire [E_ADD - 1 :0] sub2;
wire [E_ADD - 1 :0] exp_diff;
wire [E_ADD - 1 :0] exp_temp;
wire [E_ADD - 1 :0] align_bits;

assign exp_compare = mul_exp < src2_exp;
assign sub1 = exp_compare ? src2_exp : mul_exp;
assign sub2 = exp_compare ? mul_exp : src2_exp;
assign exp_diff = sub1 - sub2;
assign exp_temp = exp_compare ? src2_exp : mul_exp;
assign align_bits = exp_diff;
////////////////////////////////////////////////
// truncation                      // xx.xxxxxxxxxxxxxx
wire [M_ADD + 4 :0] mul_man_trunc; // xx.xxxxxx_ggr
wire                mul_man_sticky;

generate
    if(2*M_MUL > M_ADD) begin: long
        assign mul_man_trunc = mul_man[2*(M_MUL + 1) - 1:2*(M_MUL + 1) - M_ADD - 5];
        assign mul_man_sticky = |mul_man[2*(M_MUL + 1) - M_ADD - 6:0];
    end
    else begin: short
        assign mul_man_trunc = {mul_man, {(M_ADD - 2*M_MUL + 3){1'b0}}};
        assign mul_man_sticky = 'b0; 
    end
endgenerate
////////////////////////////////////////////////    
// align                                            // mul_man:             xx.xxxxxx_xxxxxxxxx
wire signed [2*(M_ADD + 5) - 1  :0] data_shift;     // mul_man_trunc:       xx.xxxxxx_ggr
wire        [2*(M_ADD + 5) - 1  :0] data_shifted;   // {2'b01, src2_man}:   xx.xxxxxx
wire                                add_man_sticky; // data_shift:          xx.xxxxxx_xxx_xx_xxxxxx_xxx
wire        [M_ADD + 4          :0] adder_src1;     //                      xx.xxxxxx_ggr
wire        [M_ADD + 4          :0] adder_src2;

assign data_shift = exp_compare ? {mul_man_trunc, {(M_ADD + 5){1'b0}}} : 
                   {2'b01, src2_man, {(M_ADD + 8){1'b0}}};
assign data_shifted = exp_diff < M_ADD + 5 ? data_shift >>> align_bits : 'b0;
assign add_man_sticky = |data_shifted[M_ADD + 4:0];
assign adder_src1 = exp_compare ? {2'b01, src2_man, 3'b000} : mul_man_trunc;
assign adder_src2 = data_shifted;
////////////////////////////////////////////////
// transfer source code to complement
wire [M_ADD + 6 :0] adder_src1_complement;  // xxxx.xxxxxx_ggr
wire [M_ADD + 6 :0] adder_src2_complement;

assign adder_src1_complement = (exp_compare & src2_sign | ~exp_compare & mul_sign) ? 
                               {2'b11, ~adder_src1} + 'b1 : {2'b00, adder_src1};
assign adder_src2_complement = (exp_compare & mul_sign | ~exp_compare & src2_sign) ? 
                               {2'b11, ~adder_src2} + 'b1 : {2'b00, adder_src2};
////////////////////////////////////////////////
// add
wire [M_ADD + 6 :0] man_sum;

assign man_sum = adder_src1 + adder_src2;
////////////////////////////////////////////////
// transfer complement to source code
wire                sign_d0;
wire [M_ADD + 5 :0] man_source; // xxx.xxxxxx_ggr

assign sign_d0 = man_sum[M_ADD + 6];
assign man_source = sign_d0 ? ~man_sum[M_ADD + 5:0] + 'b1 : man_sum[M_ADD + 5:0];
////////////////////////////////////////////////
// get the shift bits

// right shift bits
wire       rshift_valid;
wire [1:0] rshift_bits;

priority_encoder #(.WIDTH(3), .LSB_PRIORITY("LOW")) r_priority_encoder
(.unencoded(man_source[M_ADD + 5:M_ADD + 3]), .valid(rshift_valid), .encoded(rshift_bits));

// left shift bits
wire [M_ADD + 3              :0] unencoded_left;
wire                             lshift_valid;
wire [$clog2(M_ADD + 4) - 1  :0] lshift_bits;

genvar i;
generate
    for (i = 0; i < M_ADD + 4; i = i + 1) begin: reserve_left
        assign unencoded_left[i] = man_source[M_ADD + 3 - i];
    end
endgenerate

priority_encoder #(.WIDTH(M_ADD + 4), .LSB_PRIORITY("HIGH")) l_priority_encoder
(.unencoded(unencoded_left), .valid(lshift_valid), .encoded(lshift_bits));

// exp shift bits
wire [E_ADD - 1 :0] exp_shift_num;

assign exp_shift_num = rshift_valid ? {{(E_ADD - 2){1'b0}}, rshift_bits} : {{(E_ADD - $clog2(M_ADD + 4)){1'b1}}, ~lshift_bits} + 'b1;
////////////////////////////////////////////////
// normalize
wire [M_ADD + 3 :0] man_rshifted;   // xxx.xxxxxx_g
wire [1         :0] normalize_man_reserve;
wire                sticky;
wire [M_ADD + 4 :0] man_lshifted;   // xx.xxxxxx_ggr
wire [M_ADD + 2 :0] man_normalized; // xx.xxxxxx_g

assign {man_rshifted, normalize_man_reserve} = man_source >> rshift_bits;
assign sticky = |normalize_man_reserve | add_man_sticky | mul_man_sticky;
assign man_lshifted = man_source[M_ADD + 4 :0] << lshift_bits;
assign man_normalized = rshift_valid ? man_rshifted[M_ADD + 2:0] : man_lshifted[M_ADD + 4:2];
////////////////////////////////////////////////
// round
wire [M_ADD + 1  :0] man_round1;
wire [M_ADD + 1  :0] man_round0;
reg  [M_ADD + 1  :0] man_rounded; // xx.xxxxxx

assign man_round1 = man_normalized[M_ADD + 2:1] + 'b1;
assign man_round0 = man_normalized[M_ADD + 2:1];

always @(*) begin
    case({man_normalized[0], sticky})
        2'b00: begin
            man_rounded = man_round0;
        end
        2'b01: begin
            man_rounded = man_round0;
        end
        2'b10: begin
            man_rounded = man_normalized[1] ? man_round1 : man_round0;
        end
        2'b11: begin
            man_rounded = man_round1;
        end
    endcase
end
////////////////////////////////////////////////
// normalize again
wire [E_ADD - 1:0] exp_d0;
wire [M_ADD - 1:0] man_d0;

assign exp_d0 = exp_temp + exp_shift_num + man_rounded[M_ADD + 1];
assign man_d0 = man_rounded[M_ADD + 1] ? man_rounded[M_ADD:1] : man_rounded[M_ADD - 1:0];
////////////////////////////////////////////////
// output
assign result = {sign_d0, exp_d0, man_d0};

endmodule
