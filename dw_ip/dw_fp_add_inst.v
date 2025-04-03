
module dw_fp_add_inst #(
    parameter E = 5,
    parameter M = 10,
    parameter IEEE_COMPLIANCE = 1
)
(
    // input                       clock,
    input   [DATA_WIDTH - 1 :0] a,
    input   [DATA_WIDTH - 1 :0] b,
    input   [2              :0] rnd,
    output  [DATA_WIDTH - 1 :0] z,
    output  [7              :0] status
);

DW_fp_add #(
    .sig_width       (E),
    .exp_width       (M),
    .ieee_compliance (IEEE_COMPLIANCE)
) u_DW_fp_add (
    .a      (a      ), //i
    .b      (b      ), //i
    .rnd    (rnd    ), //i
    .z      (z      ), //o
    .status (status )  //o
);
  

endmodule
