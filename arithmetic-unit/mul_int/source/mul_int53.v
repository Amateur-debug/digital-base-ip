`include "mul_int.vh"
module mul_int53(

    input  		  	clock       ,

    input   	    en          ,	//input at d0
    input  	[1 	:0]	opcode      ,	//input at d0
    input  	[52	:0]	multiplicand,	//input at d0
    input  	[52	:0]	multiplier  ,	//input at d0

    output  [52	:0]	result_hi   ,	//output at d2
    output  [52	:0]	result_lo		//output at d2
);

reg [105:0] multiplicand_true;
reg [53	:0] multiplier_true;

always@(*) begin
	if(en) begin
		case(opcode)
			`UNSIGNED_X_UNSIGNED: begin
				multiplicand_true = {53'b0, multiplicand};
				multiplier_true = {1'b0, multiplier};
			end
			`SIGNED_X_UNSIGNED: begin
				multiplicand_true = {{53{multiplicand[52:52]}}, multiplicand};
				multiplier_true = {1'b0, multiplier};
			end
			`SIGNED_X_SIGNED: begin
				multiplicand_true = {{53{multiplicand[52:52]}}, multiplicand};
				multiplier_true = {{1{multiplier[52:52]}}, multiplier};
			end
			default: begin
				multiplicand_true = 106'b0;
				multiplier_true = 54'b0;
			end
		endcase
	end
	else begin
		multiplicand_true = multiplicand_true;
		multiplier_true = multiplier_true;
	end
end

///////////////////////partial_product_generator/////////////////////////////
wire	[105:0]	p [26:0];
wire	[26	:0]	c;

booth_radix4 #(106) u0_booth_radix4(

    .y({multiplier_true[1:0], 1'b0}	),
    .x(multiplicand_true			),

    .p(p[0]							),
    .c(c[0:0]						)
);
genvar i;
generate  
    for(i = 2; i < 53; i = i + 2) begin: partial_product_generator
        booth_radix4 #(106) u1_booth_radix4(

            .y(multiplier_true[i + 1:i - 1]	),
            .x(multiplicand_true << i      	),

            .p(p[i / 2]						),
            .c(c[i / 2:i / 2]				)
        );
   	end 
endgenerate
/////////////////////////////////////////////////////////////////////////////
////////////////////////////wallace_tree/////////////////////////////////////
wire [105:0] cout_d1;
wire [105:0] sout_d1;
wtree_27bits_full #(106) u_wtree_27bits_full(

    .clock	(clock	),

	.cin	(c[24:0]	),
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
    .src17	(p[17]		),
	.src18	(p[18]		),
	.src19	(p[19]		),
	.src20	(p[20]		),
	.src21	(p[21]		),
	.src22	(p[22]		),
	.src23	(p[23]		),
	.src24	(p[24]		),
	.src25	(p[25]		),
	.src26	(p[26]		),

	.cout	(cout_d1	),
    .sout	(sout_d1	)

);
/////////////////////////////////////////////////////////////////////////////
wire [1:0] c_d1;
dff #(2) c_dff_d1(.clock(clock), .d(c[26:25]), .q(c_d1));
/////////////////////////////////////////////////////////////////////////////
wire [107:0] adder_src1;
wire [107:0] adder_src2;
wire [107:0] adder_result;

assign adder_src1 = {2'b0, cout_d1[104:0], c_d1[1:1]};
assign adder_src2 = {2'b0, sout_d1};

cla_108bits u_cla_108bits(

    .a   (adder_src1	),
    .b   (adder_src2	),
    .cin (c_d1[0:0]		),
    .s   (adder_result	),
	.pm  (				),
	.gm  (				)
);

dff #(106) result_dff_d2(.clock(clock), .d(adder_result[105:0]), .q({result_hi, result_lo}));

endmodule
