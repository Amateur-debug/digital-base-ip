`timescale  1ns/1ns
`include "mul_fp.vh"
module  tb_add_fp64();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
localparam RUN_TIME = 10000;
localparam FIX_TIME = 240;

//wire  define
wire [63:0] result;
wire nv;
wire of;

//reg   define
reg clock;
reg 	   en;
reg [2 :0] rm;
reg [63:0] src1;
reg [63:0] src2;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//initialize clock
initial begin
    clock   = 1'b0;
end
always  #10 clock = ~clock;

//initialize motivation
initial begin
    en = 1'b1;
    rm = `RTE;
    src1 = 'b0;
	src2 = 'b0;
	
	#20;
	src1 = {1'b0, 11'b111_1111_1111, 52'b0};
	src2 = {1'b1, 11'b111_1111_1111, 52'b0};
	#20;
	src1 = {1'b1, 11'b111_1111_1111, 52'b0};
	src2 = {1'b0, 11'b111_1111_1111, 52'b0};
	
	#20;
	src1 = {1'b0, 11'b111_1111_1111, 52'b0};
	src2 = {1'b0, 11'b111_1111_1111, 52'b0};
	#20;
	src1 = {1'b1, 11'b111_1111_1111, 52'b0};
	src2 = {1'b1, 11'b111_1111_1111, 52'b0};
	
	#20;
	src1 = {1'b0, 11'b111_1111_1110, 7'b100_0110, 45'b0};
	src2 = {1'b0, 11'b111_1111_1110, 7'b100_1111, 45'b0};
	#20;
	src1 = {1'b1, 11'b111_1111_1110, 7'b100_0110, 45'b0};
	src2 = {1'b1, 11'b111_1111_1110, 7'b100_1111, 45'b0};
	
	#20;
	src1 = {1'b0, 11'b111_1111_1111, 52'b0};
	src2 = {$random, $random};
	#20;
	src1 = {$random, $random};
	src2 = {1'b1, 11'b111_1111_1111, 52'b0};
	
	#20;
	src1 = {1'b0, 11'b111_1111_1111, 1'b1, 51'b0};
	src2 = {$random, $random};
	#20;
	src1 = {1'b1, 11'b111_1111_1111, 1'b1, 51'b0};
	src2 = {$random, $random};
	
	#20;
	src1 = {1'b0, 11'b111_1111_1111, 52'b1};
	src2 = {$random, $random};
	#20;
	src1 = {1'b1, 11'b111_1111_1111, 52'b1};
	src2 = {$random, $random};
end

//generate random motivation
always begin 
	#20;
	if($time > FIX_TIME) begin
		src1 = {$random, $random};
		src2 = {$random, $random};
	end
end

//delay input
localparam LATENCY = 4;
reg  [63:0] src1_d [LATENCY - 1:0];
reg  [63:0] src2_d [LATENCY - 1:0];

always @(posedge clock) begin
	src1_d[0] <= src1;
	src2_d[0]  <= src2;
end

genvar i;
generate 
	for(i = 1; i < LATENCY; i = i + 1) begin: delay
		always @(posedge clock) begin
			src1_d[i] <= src1_d[i - 1];
			src2_d[i]  <= src2_d[i - 1];
		end
	end
endgenerate

/*self-check
wire [63:0] result_hi_ref;
wire [63:0] result_lo_ref;
wire ok;

assign {result_hi_ref,  result_lo_ref} = multiplicand_d[LATENCY - 1] * multiplier_d[LATENCY - 1];
assign ok = {result_hi_ref,  result_lo_ref} == {result_hi,  result_lo};

//simulation finish
always @(posedge clock) begin
	if (!ok && $time >= 20*LATENCY) begin
		$display("Error: multiplicand = %h, multiplier = %h, result_hi = %h, result_lo = %h, result_hi_ref = %h, result_lo_ref = %h", 
				 multiplicand_d[LATENCY - 1], multiplier_d[LATENCY - 1], result_hi, result_lo, result_hi_ref, result_lo_ref);
		$finish;
	end
end
*/

always begin
    #100;
    if ($time >= RUN_TIME) begin
        $finish ;
    end
end
//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
add_fp64 u_add_fp64(

	.clock  (clock  ),
	.en     (en     ),	//input at d0
	.rm     (rm     ),	//input at d0
	.src1   (src1   ),	//input at d0
	.src2   (src2   ),	//input at d0
	.result (result ),	//output at d4
	.nv	    (nv	    ),
	.of	    (of	    )
);

endmodule
