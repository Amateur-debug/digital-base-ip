module mul_mp_fpany
#(
    parameter E0 = 5,
    parameter M0 = 10,
    parameter E1 = 8,
    parameter M1 = 23
)
(

    input                   clock   ,

    input   [E0 + M0    :0] src0    ,   //input at d0
    input   [E1 + M1    :0] src1    ,   //input at d0
    output  [E1 + M1    :0] result  ,   //output at d1
    output                  overflow
);
////////////////////////////////////////////////
// unpack
wire             src0_sign;
wire [E0 - 1 :0] src0_exp;
wire [M0 - 1 :0] src0_man;
wire             src1_sign;
wire [E1 - 1 :0] src1_exp;
wire [M1 - 1 :0] src1_man;

assign src0_sign = src0[E0 + M0];
assign src0_exp  = src0[E0 + M0 - 1:M0];
assign src0_man  = src0[M0 - 1:0];
assign src1_sign = src1[E1 + M1];
assign src1_exp  = src1[E1 + M1 - 1:M1];
assign src1_man  = src1[M1 - 1:0];
////////////////////////////////////////////////
// whether the number is normal
wire                src0_normal;
wire                src1_normal;
wire [E0 - 1    :0] src0_exp_normal;
wire [E1 - 1    :0] src1_exp_normal;
wire [M0        :0] src0_man_normal;
wire [M1        :0] src1_man_normal;

assign src0_normal = src0_exp != 'b0;
assign src1_normal = src1_exp != 'b0;
assign src0_exp_normal = src0_exp + {{(E0- 1){1'b0}}, ~src0_normal};
assign src1_exp_normal = src1_exp + {{(E0- 1){1'b0}}, ~src1_normal};
assign src0_man_normal = {src0_normal, src0_man};
assign src1_man_normal = {src1_normal, src1_man};
////////////////////////////////////////////////
localparam [E0:0] BIAS0 = (1 << (E0 - 1)) - 1;
localparam [E1:0] BIAS1 = (1 << (E1 - 1)) - 1;
////////////////////////////////////////////////
// multiplication
wire                    mul_sign;
wire [E1            :0] mul_exp;
wire [M0 + M1 + 1   :0] mul_man; // xx.xxxxxx

assign mul_sign = src0_sign ^ src1_sign;
assign mul_exp = {1'b0, src0_exp_normal} + {1'b0, src1_exp_normal} - BIAS0;
assign mul_man = src0_man_normal * src1_man_normal;
////////////////////////////////////////////////
// get pre-normalize shift bits

// right shift bits
wire pre_normal_rshift_valid;
wire pre_normal_rshift_bits;

priority_encoder #(.WIDTH(2), .LSB_PRIORITY("LOW")) pre_normal_r_priority_encoder
(.unencoded(mul_man[M_ADD + 3:M_ADD + 2]), .valid(pre_normal_rshift_valid), .encoded(pre_normal_rshift_bits));

// left shift bits
wire [M_ADD + 2             :0] pre_normal_unencoded_left;
wire                            pre_normal_lshift_valid;
wire [$clog2(M_ADD + 3) - 1 :0] pre_normal_lshift_bits;
wire [$clog2(M_ADD + 3) - 1 :0] pre_normal_lshift_bits_true;

assign pre_normal_lshift_bits_true = exp_temp - 'b1 > pre_normal_lshift_bits ? pre_normal_lshift_bits : exp_temp - 'b1;

generate
    for (i = 0; i < M_ADD + 3; i = i + 1) begin: pre_normal_reserve_left
        assign pre_normal_unencoded_left[i] = man_source[M_ADD + 2 - i];
    end
endgenerate

priority_encoder #(.WIDTH(M_ADD + 3), .LSB_PRIORITY("HIGH")) pre_normal_l_priority_encoder
(.unencoded(pre_normal_unencoded_left), .valid(pre_normal_lshift_valid), .encoded(pre_normal_lshift_bits));

// exp shift bits
wire [E_ADD - 1 :0] pre_normal_bits;

assign pre_normal_bits = pre_normal_rshift_valid ? {{E_ADD{1'b0}}, pre_normal_rshift_bits} : {{(E_ADD - $clog2(M_ADD + 3)){1'b1}}, ~pre_normal_lshift_bits_true} + 'b1;
////////////////////////////////////////////////
// pre_normalize
wire [M_ADD + 2 :0] pre_normal_man_rshifted;    // xx.xxxxxx_g
wire                pre_normal_man_reserve;
wire                sticky;
wire [M_ADD + 2 :0] pre_normal_man_lshifted;    //  x.xxxxxx_gr
wire [M_ADD + 2 :0] pre_normal_man;             // xx.xxxxxx_g
wire [E_ADD - 1 :0] pre_normal_exp;  

assign {pre_normal_man_rshifted, pre_normal_man_reserve} = man_source >> pre_normal_rshift_bits;
assign sticky = pre_normal_man_reserve | trunc_sticky;
assign pre_normal_man_lshifted = man_source[M_ADD + 2:0] << pre_normal_lshift_bits_true;
assign pre_normal_man = pre_normal_rshift_valid ? pre_normal_man_rshifted : {1'b0, pre_normal_man_lshifted[M_ADD + 2 :1]};
assign pre_normal_exp = exp_temp + pre_normal_bits;
////////////////////////////////////////////////
// round
wire [M_ADD + 1 :0] man_round1;
wire [M_ADD + 1 :0] man_round0;
reg  [M_ADD + 1 :0] man_rounded; // xx.xxxxxx

assign man_round1 = pre_normal_man[M_ADD + 2:1] + 'b1;
assign man_round0 = pre_normal_man[M_ADD + 2:1];

always @(*) begin
    case({pre_normal_man[0], sticky})
        2'b00: begin
            man_rounded = man_round0;
        end
        2'b01: begin
            man_rounded = man_round0;
        end
        2'b10: begin
            man_rounded = pre_normal_man[1] ? man_round1 : man_round0;
        end
        2'b11: begin
            man_rounded = man_round1;
        end
    endcase
end
////////////////////////////////////////////////
// normalize
wire [E_ADD         :0] normal_exp;         //  x_xxx
wire [E_ADD         :0] normal_bits;        //  x_xxx
wire [M_ADD + 1     :0] normal_man;         //  x.xxxxxx

wire [E_ADD - 1     :0] exp_d0;
wire [M_ADD - 1     :0] man_d0;

assign normal_exp = pre_normal_exp + man_rounded[M_ADD + 1];
assign normal_man = man_rounded[M_ADD + 1] ? man_rounded[M_ADD + 1:1] : man_rounded[M_ADD:0];
assign exp_d0 = normal_exp[E_ADD] ? {E_ADD{1'b1}} : 
                normal_exp == 'b1 & man_rounded[M_ADD + 1:M_ADD] == 'b0 ? {E_ADD{1'b0}} : normal_exp[E_ADD - 1:0];
assign man_d0 = normal_man[M_ADD - 1:0];
////////////////////////////////////////////////
// output
assign result = {sign_d0, exp_d0, man_d0};
assign overflow = normal_exp[E_ADD];

endmodule
