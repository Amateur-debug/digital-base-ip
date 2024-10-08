module div_int
#(
	parameter DATA_WIDTH = 32,
	localparam DATA_WIDTH_SUB = DATA_WIDTH - 1,
	localparam DATA_WIDTH_ADD = DATA_WIDTH + 1
)
(

    input						clock       ,
	input		    			reset       ,					 
    input		    			en    		,
    input    					opcode      ,
    input   [DATA_WIDTH_SUB:0]	dividend    ,
    input   [DATA_WIDTH_SUB:0]	divisor     ,		    
    output  					valid_out   ,
	output  					almost_valid,
    output  [DATA_WIDTH_SUB:0]  quotient	,
    output  [DATA_WIDTH_SUB:0]  remainder
);
////////////////////////////////////////////////
localparam CYCLE_WIDTH = $clog2(DATA_WIDTH) + 1;
localparam CYCLE_WIDTH_SUB = CYCLE_WIDTH - 1;
localparam FINISH_CYCLE = DATA_WIDTH_ADD;
localparam IDEL = 1'b0;
localparam RUN = 1'b1;
////////////////////////////////////////////////
wire						state;
reg							state_next;
wire	[CYCLE_WIDTH_SUB:0] cycle;
reg		[CYCLE_WIDTH_SUB:0] cycle_next;

always@(*) begin
	case(state)
		IDEL: begin
			state_next = en ? RUN : IDEL;
			cycle_next = en ? cycle + 'b1 : 'b0;
		end
		RUN: begin
			state_next = cycle == FINISH_CYCLE ? IDEL : RUN;
			cycle_next = cycle == FINISH_CYCLE ? 'b0 : cycle + 'b1;
		end
	endcase
end

dff_ar #(1			) state_dff(.clock(clock), .reset(reset), .d(state_next), .q(state));
dff_ar #(CYCLE_WIDTH) cycle_dff(.clock(clock), .reset(reset), .d(cycle_next), .q(cycle));
////////////////////////////////////////////////
localparam REG_WIDTH = DATA_WIDTH * 2 + 1;
localparam REG_WIDTH_SUB = REG_WIDTH - 1;
////////////////////////////////////////////////
wire	[REG_WIDTH_SUB	:0]	dividend_true;
wire	[DATA_WIDTH		:0]	divisor_true;
wire	[DATA_WIDTH		:0]	divisor_negative;

assign dividend_true = opcode ? {{DATA_WIDTH_ADD{dividend[31:31]}}, dividend} : {{DATA_WIDTH_ADD{1'b0}}, dividend};
assign divisor_true = opcode ? {divisor[DATA_WIDTH_SUB:DATA_WIDTH_SUB], divisor} : {1'b0, divisor};
assign divisor_negative = ~divisor_true + 'b1;
////////////////////////////////////////////////
wire	[REG_WIDTH_SUB	:0]	result;
wire	[REG_WIDTH_SUB	:0]	result_shifted;
wire	[REG_WIDTH_SUB	:0]	result_next;
wire	[DATA_WIDTH		:0]	r_adder_src0;
wire	[DATA_WIDTH		:0]	r_adder_src1;
wire	[DATA_WIDTH		:0]	r_adder_result;
wire						q;

assign result_shifted = {result[REG_WIDTH_SUB - 1:0], 1'b0};
assign r_adder_src0 = result_shifted[REG_WIDTH_SUB:DATA_WIDTH];
assign r_adder_src1 = result[REG_WIDTH_SUB:REG_WIDTH_SUB] == divisor_true[DATA_WIDTH:DATA_WIDTH] ? divisor_negative : divisor_true;
assign r_adder_result = r_adder_src0 + r_adder_src1;
assign q = result[REG_WIDTH_SUB:REG_WIDTH_SUB] == divisor_true[DATA_WIDTH:DATA_WIDTH] ? 'b1 : 'b0;
assign result_next = state == IDEL ? dividend_true : {r_adder_result, result_shifted[DATA_WIDTH_SUB:1], q};

dff #(REG_WIDTH) result_dff(.clock(clock), .d(result_next), .q(result));
////////////////////////////////////////////////
wire	almost_valid_next;
assign almost_valid_next = cycle == DATA_WIDTH;
dff_ar #(1) almost_valid_dff(.clock(clock), .reset(reset), .d(almost_valid_next), .q(almost_valid));
////////////////////////////////////////////////
wire						correction_en;
wire	[DATA_WIDTH_SUB	:0]	quotient_correction;
wire	[DATA_WIDTH		:0]	remainder_correction;

assign correction_en = cycle == DATA_WIDTH;

dff_en #(DATA_WIDTH		) quotient_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[DATA_WIDTH_SUB:0]		), .q(quotient_correction	));
dff_en #(DATA_WIDTH_ADD) remainder_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[REG_WIDTH_SUB:DATA_WIDTH]), .q(remainder_correction	));
////////////////////////////////////////////////
wire						valid_out_next;
wire						need_correct;
wire						add_correct;
wire	[DATA_WIDTH_SUB:0]	quotient_complement;
wire	[DATA_WIDTH_SUB:0]	quotient_addend;
wire	[DATA_WIDTH_SUB:0]	quotient_corrected;
wire	[DATA_WIDTH_SUB:0]	remainder_addend;
wire	[DATA_WIDTH_SUB:0]	remainder_corrected;

assign valid_out_next = cycle == FINISH_CYCLE;
assign need_correct = remainder_correction[DATA_WIDTH:DATA_WIDTH] != dividend_true[REG_WIDTH - 1:REG_WIDTH - 1];
assign add_correct = remainder_correction[DATA_WIDTH:DATA_WIDTH] != divisor_true[DATA_WIDTH:DATA_WIDTH];

assign quotient_addend = add_correct ? -'b1 : 'b1;
assign quotient_complement = {quotient_correction[DATA_WIDTH_SUB - 1:0], 1'b1};
assign quotient_corrected = need_correct ? quotient_complement + quotient_addend : quotient_complement;

assign remainder_addend = add_correct ? divisor_true[DATA_WIDTH_SUB:0] : divisor_negative[DATA_WIDTH_SUB:0];
assign remainder_corrected = need_correct ? remainder_correction[DATA_WIDTH_SUB:0] + remainder_addend : remainder_correction[DATA_WIDTH_SUB:0];

dff_ar #(1) valid_out_dff_ar(.clock(clock), .reset(reset), .d(valid_out_next), .q(valid_out));
dff #(DATA_WIDTH) quotient_dff	(.clock(clock), .d(quotient_corrected	), .q(quotient	));
dff #(DATA_WIDTH) remainder_dff	(.clock(clock), .d(remainder_corrected	), .q(remainder	));

endmodule
