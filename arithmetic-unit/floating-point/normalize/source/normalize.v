module normalize
#(
    parameter E = 5,
    parameter M = 10,
    parameter INT = 3,
    parameter FRAC = 12,
    parameter PWIDTH = INT + FRAC
)
(

    input                   clock   ,

    input   [E + PWIDTH :0] src     ,   //input at d0
    output  [E + M      :0] result      //output at d1
);
////////////////////////////////////////////////
wire                src_sign;
wire [E - 1     :0] src_exp;
wire [PWIDTH - 1:0] src_man;
wire                src_subnormal;

assign src_sign = src[E + PWIDTH];
assign src_exp  = src[E + PWIDTH - 1:PWIDTH];
assign src_man  = src[PWIDTH - 1:0];
assign src_subnormal = src_exp == 'b0;
////////////////////////////////////////////////
// transfer complement to source code
wire                    sign_d0;
wire    [PWIDTH - 1:0]  man_temp;

assign sign_d0 = src_sign;
assign man_temp = src_sign ? ~src_man + 'b1 : src_man;
////////////////////////////////////////////////
// get the shift bits

// right shift bits
wire                            rshift_valid;
wire    [$clog2(INT) - 1   :0]  rshift_bits;
wire    [E - 1             :0]  rshift_max;
wire    [$clog2(INT) - 1   :0]  rshift_num;

assign rshift_max = src_subnormal ?  : {E{1'b1}} - src_exp;
assign rshift_num = rshift_bits < rshift_max ? rshift_bits : rshift_max;

priority_encoder #(.WIDTH(INT), .LSB_PRIORITY("LOW")) r_priority_encoder
(.unencoded(man_temp[PWIDTH - 1:FRAC]), .valid(rshift_valid), .encoded(rshift_bits));

// left shift bits
wire    [FRAC                   :0] unencoded_left;
wire                                    lshift_valid;
wire    [$clog2(FRAC + 1) - 1   :0] lshift_bits;
wire    [E - 1                      :0] lshift_max;
wire    [$clog2(INT) - 1            :0] lshift_num;

assign lshift_max = src_subnormal ? 'b0 : src_exp - 'b1;
assign lshift_num = lshift_bits < lshift_max ? lshift_bits : lshift_max;

genvar i;
generate
    for (i = 0; i < FRAC + 1; i = i + 1) begin: reserve_left
        assign unencoded_left[i] = man_temp[FRAC-i];
    end
endgenerate

priority_encoder #(.WIDTH(FRAC + 1), .LSB_PRIORITY("HIGH")) l_priority_encoder
(.unencoded(unencoded_left), .valid(lshift_valid), .encoded(lshift_bits));

// exp shift bits
wire [E - 1 :0] exp_shift_num;

assign exp_shift_num = rshift_valid ? {{(E-$clog2(INT)){1'b0}}, rshift_bits} : {{(E-$clog2(FRAC + 1)){1'b1}}, ~lshift_bits} + 'b1;
////////////////////////////////////////////////
// normalize
wire [PWIDTH - 1:0] man_rshifted;
wire [PWIDTH - 1:0] man_lshifted;
wire [M + 3     :0] man_normalized;

assign man_rshifted = man_temp >> rshift_bits;
assign man_lshifted = man_temp << lshift_bits;
assign man_normalized = rshift_valid ? man_rshifted[FRAC + 1:FRAC - M - 2] : man_lshifted[FRAC + 1:FRAC - M - 2];
////////////////////////////////////////////////
// round
wire    [M + 1  :0] man_round1;
wire    [M + 1  :0] man_round0;
reg     [M + 1  :0] man_rounded;

assign man_round1 = man_normalized[M + 3:2] + 'b1;
assign man_round0 = man_normalized[M + 3:2];

always @(*) begin
    case(man_normalized[1:0])
        2'b00: begin
            man_rounded = man_round0;
        end
        2'b01: begin
            man_rounded = man_round0;
        end
        2'b10: begin
            man_rounded = man_normalized[2] ? man_round1 : man_round0;
        end
        2'b11: begin
            man_rounded = man_round1;
        end
    endcase
end
////////////////////////////////////////////////
// normalize
wire [E - 1:0] exp_d0;
wire [M - 1:0] man_d0;

assign exp_d0 = src_exp + exp_shift_num + man_rounded[M + 1];
assign man_d0 = man_rounded[M + 1] ? man_rounded[M:1] : man_rounded[M - 1:0];
////////////////////////////////////////////////
dff #(M+E+1) result_dff(.clock(clock), .d({sign_d0, exp_d0, man_d0}), .q(result));

endmodule
