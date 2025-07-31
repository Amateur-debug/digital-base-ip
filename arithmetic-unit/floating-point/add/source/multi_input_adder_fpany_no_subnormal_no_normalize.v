module multi_input_adder_fpany_no_subnormal_no_normalize
#(
    parameter E = 5,
    parameter M = 10,
    parameter TOTAL = E + M + 1,
    parameter INT = 4,
    parameter FRAC = 12,
    parameter NUM = 4,
    parameter PWIDTH = INT + FRAC
)
(

    // input                       clock   ,

    input   [E + PWIDTH     :0] psum    ,   //input at d0
    input   [NUM*TOTAL - 1  :0] src     ,   //input at d0
    output  [E + PWIDTH     :0] result      //output at d1
);
////////////////////////////////////////////////
wire                    src_sign[NUM - 1:0];
wire [E - 1         :0] src_exp [NUM - 1:0];
wire [M - 1         :0] src_man [NUM - 1:0];
wire                    psum_sign;
wire [E - 1         :0] psum_exp;
wire [PWIDTH - 1    :0] psum_man;

genvar i;
generate
    for (i = 0; i < NUM; i = i + 1) begin: unpack_src
        assign src_sign[i] = src[(i + 1)*(TOTAL) - 1];
        assign src_exp[i] = src[(i + 1)*(TOTAL) - 2 : i*(TOTAL) + M];
        assign src_man[i] = src[(i + 1)*(TOTAL) - E - 2 : i*(TOTAL)];
    end
endgenerate
assign psum_sign = psum[E + PWIDTH];
assign psum_exp  = psum[E + PWIDTH - 1:PWIDTH];
assign psum_man  = psum[PWIDTH - 1:0];
// ////////////////////////////////////////////////
// // init data_exp
// wire [E - 1 :0] data_exp[NUM:0];

// assign data_exp[0] = psum_exp;

// generate 
//     for(i = 1; i < NUM + 1; i = i + 1) begin: init_exp_compare
//         assign data_exp[i] = src_exp[i - 1];
//     end
// endgenerate
// //////////////////////////////////////////////
// // find max exp
// wire                            exp_compare [NUM:1];
// wire [E - 1                 :0] current_max [NUM:0];
// wire [$clog2(NUM + 1) - 1   :0] current_idx [NUM:0];

// assign current_max[0] = data_exp[0];
// assign current_idx[0] = 'b0;

// generate 
//     for (i = 1; i < NUM + 1; i = i + 1) begin : compare
//         assign exp_compare[i] = data_exp[i] < current_max[i - 1];
//         assign current_max[i] = exp_compare[i] ? current_max[i - 1] : data_exp[i];
//         assign current_idx[i] = exp_compare[i] ? current_idx[i - 1] : i;
//     end
// endgenerate

// wire [E - 1                 :0] exp_temp;
// wire [$clog2(NUM + 1) - 1   :0] exp_idx; 

// assign exp_temp = current_max[NUM];
// assign exp_idx = current_idx[NUM];
// //////////////////////////////////////////////
// // get diff number
// wire [E - 1:0] exp_diff[NUM - 1:0];

// generate 
//     for (i = 0; i < NUM + 1; i = i + 1) begin: diff
//         assign exp_diff[i] = exp_temp - data_exp[i];
//     end
// endgenerate
//////////////////////////////////////////////
// init data_exp
wire [E*(NUM + 1) - 1 :0] data_exp;

assign data_exp[E - 1:0] = psum_exp;

generate 
    for(i = 1; i < NUM + 1; i = i + 1) begin: init_exp_compare
        assign data_exp[E*(i + 1) - 1:E*i] = src_exp[i - 1];
    end
endgenerate
////////////////////////////////////////////////
// find max exp

wire [E - 1                 :0] exp_temp;

comp_tree #(
    .WIDTH(E),
    .NUM(NUM + 1)
)
u_comp_tree(
    .comp_data(data_exp),
    .max_data(exp_temp)
);
////////////////////////////////////////////////
// get diff number
wire [E - 1:0] exp_diff[NUM:0];

generate 
    for (i = 0; i < NUM + 1; i = i + 1) begin: diff
        assign exp_diff[i] = exp_temp - data_exp[E*(i + 1) - 1:E*i];
    end
endgenerate
////////////////////////////////////////////////
// transfer source code to complement
wire [PWIDTH :0] data_man_complement[NUM:0];

assign data_man_complement[0] = {psum_sign, psum_man};
generate 
    for (i = 1; i < NUM + 1; i = i + 1) begin: complement
        assign data_man_complement[i] = src_sign[i - 1] ? {{INT{1'b1}}, 1'b0, ~src_man[i - 1], {(FRAC-M){1'b1}}} + 'b1 : 
                                        {{INT{1'b0}}, 1'b1, src_man[i - 1], {(FRAC-M){1'b0}}};
    end
endgenerate
////////////////////////////////////////////////
// align
wire [PWIDTH :0] data_shifted[NUM:0];

generate
    for (i = 0; i < NUM + 1; i = i + 1) begin: align
        assign data_shifted[i] = $signed(data_man_complement[i]) >>> exp_diff[i];
    end
endgenerate
////////////////////////////////////////////////
// add
reg [PWIDTH :0] man_sum;

integer j;
always @(*) begin
    man_sum = 'b0;
    for (j = 0; j < NUM + 1; j = j + 1) begin: add
        man_sum = man_sum + data_shifted[j];
    end
end
////////////////////////////////////////////////
// complement output
wire                sign_d0;
wire [E - 1     :0] exp_d0;
wire [PWIDTH - 1:0] man_d0;

assign sign_d0 = man_sum[PWIDTH];
assign exp_d0 = exp_temp;
assign man_d0 = man_sum[PWIDTH - 1:0];
assign result = {sign_d0, exp_d0, man_d0};
////////////////////////////////////////////////
//dff #(PWIDTH+E+1) result_dff(.clock(clock), .d({sign_d0, exp_d0, man_d0} & {(PWIDTH+E+1){~clear}}), .q(result));
////////////////////////////////////////////////

endmodule
