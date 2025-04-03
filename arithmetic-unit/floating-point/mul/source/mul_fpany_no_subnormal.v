module mul_fpany_no_subnormal
#(
    parameter E = 3,
    parameter M = 4
)
(

    input               clock   ,
    input   [E + M  :0] src1    ,   //input at d0
    input   [E + M  :0] src2    ,   //input at d0
    output  [E + M  :0] result      //output at d1
);
////////////////////////////////////////////////
wire                sign1;
wire                sign2;
wire    [E - 1  :0] exp1;
wire    [E - 1  :0] exp2;
wire    [M - 1  :0] man1;
wire    [M - 1  :0] man2;
    
assign sign1 = src1[E + M];
assign sign2 = src2[E + M];
assign exp1  = src1[E + M - 1:M];
assign exp2  = src2[E + M - 1:M];
assign man1  = src1[M - 1:0];
assign man2  = src2[M - 1:0];
////////////////////////////////////////////////
wire sign_d0;
assign sign_d0 = sign1 ^ sign2;
////////////////////////////////////////////////
wire    [E - 1  :0] exp_temp;

assign exp_temp = exp1 + exp2;
////////////////////////////////////////////////
//恢复隐藏的1
wire    [M  :0] man1_true;
wire    [M  :0] man2_true;

assign man1_true = {1'b1, man1};
assign man2_true = {1'b1, man2};
////////////////////////////////////////////////
//mul
wire    [2 * M + 1  :0]    man_temp; 

assign man_temp = man1_true * man2_true;
////////////////////////////////////////////////
//normalize
wire    [M - 1  :0] man_normalized;
wire    [E - 1  :0] exp_shift_num;
wire    [E - 1  :0] exp_d0;

assign man_normalized = man_temp[2 * M + 1] ? man_temp[2 * M:M + 1] : man_temp[2 * M - 1:M];
assign exp_shift_num = man_temp[2 * M + 1] ? 'b1 : 'b0;
assign exp_d0 = exp_temp + exp_shift_num;
////////////////////////////////////////////////
//round
wire    [M - 1  :0]   man_d0;

assign man_d0 = man_normalized;
////////////////////////////////////////////////
dff #(M+E+1) result_dff (.clock(clock), .d({sign_d0, exp_d0, man_d0}), .q(result));

endmodule
