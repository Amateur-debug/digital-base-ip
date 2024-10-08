`include "mul_int.vh"
module mul_int32(

    input  		  	clock       ,

    input   	    en          ,	//input at d0
    input	[1 	:0]	opcode      ,	//input at d0
    input  	[31	:0]	multiplicand,	//input at d0
    input  	[31	:0]	multiplier  ,	//input at d0

    output	[31	:0]	result_hi   ,	//output at d2
    output	[31	:0]  result_lo	    //output at d2
);

reg	[63	:0]	multiplicand_true;
reg	[33	:0]	multiplier_true;

always@(*) begin
	if(en) begin
		case(opcode)
			`UNSIGNED_X_UNSIGNED: begin
				multiplicand_true = {32'b0, multiplicand};
				multiplier_true = {2'b0, multiplier};
			end
			`SIGNED_X_UNSIGNED: begin
				multiplicand_true = {{32{multiplicand[23:23]}}, multiplicand};
				multiplier_true = {2'b0, multiplier};
			end
			`SIGNED_X_SIGNED: begin
				multiplicand_true = {{32{multiplicand[23:23]}}, multiplicand};
				multiplier_true = {{2{multiplier[23:23]}}, multiplier};
			end
			default: begin
				multiplicand_true = 64'b0;
				multiplier_true = 34'b0;
			end
		endcase
	end
	else begin
		multiplicand_true = multiplicand_true;
		multiplier_true = multiplier_true;
	end
end

/////////////////////////////////////////////////////////////////////
wire	[63	:0]	p [16:0];
wire	[16	:0]	c;

booth_radix4 #(64) u0_booth_radix4(

    .y({multiplier_true[1:0], 1'b0}	),
    .x(multiplicand_true			),

    .p(p[0]							),
    .c(c[0:0]						)
);
genvar i;
generate  
    for(i = 2; i < 33; i = i + 2) begin: partial_product_generator
        booth_radix4 #(64) u1_booth_radix4(

            .y(multiplier_true[i + 1:i - 1]	),
            .x(multiplicand_true << i      	),

            .p(p[i / 2]						),
            .c(c[i / 2:i / 2]				)
        );
   	end 
endgenerate
/////////////////////////////////////////////////////////////////////////////
wire [63:0] cout_d1;
wire [63:0] sout_d1;
wtree_17bits_full #(64) u_wtree_17bits_full(

	.clock	(clock	),
	
	.cin	(c[9:0]		),
    .src0	(p[0]		),
    .src1	(p[1]		),
	.src2	(p[2]		),
	.src3	(p[3]		),
	.src4	(p[4]		),
    .src5	(p[5]		),
    .src6	(p[6]		),
	.src7	(p[7]		),
	.src8	(p[8]		),
	.src9	(p[9]		),
	.src10	(p[10]		),
	.src11	(p[11]		),
    .src12	(p[12]		),
	.src13	(p[13]		),
	.src14	(p[14]		),
	.src15	(p[15]		),
    .src16	(p[16]		),

	.cout	(cout_d1	),
    .sout	(sout_d1	)

);
/////////////////////////////////////////////////////////////////////////////
wire [2:0] c_d1;
dff #(3) c_dff_d1(.clock(clock), .d(c[12:10]), .q(c_d1));
/////////////////////////////////////////////////////////////////////////////
wire [47:0] adder0_src1;
wire [47:0] adder0_src2;
wire [47:0] adder0_result;

assign adder0_src1 = {cout_d1[46:0], c_d1[2:2]};
assign adder0_src2 = sout_d1;

cla_48bits u0_cla_48bits(

    .a   (adder0_src1	),
    .b   (adder0_src2	),
    .cin (c_d1[1:1]		),
    .s   (adder0_result	),
	.pm  (				),
	.gm  (				)
);
/////////////////////////////////////////////////////////////////////////////
wire [47:0] adder1_src1;
wire [47:0] adder1_src2;
wire [47:0] adder1_result;

assign adder1_src1 = adder0_result;
assign adder1_src2 = {47'b0, c_d1[0:0]};

cla_48bits u1_cla_48bits(

    .a   (adder1_src1),
    .b   (adder1_src2),
    .cin (1'b0),
    .s   (adder1_result),
	.pm  (),
	.gm  ()
);

dff #(48) result_dff_d2(.clock(clock), .d(adder1_result), .q({result_hi, result_lo}));

endmodule
