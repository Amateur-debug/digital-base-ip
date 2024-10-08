module div_int64(

    input		    clock    	,
	input		    reset    	,					 
    input		    en 			,
	input		    flush 		,
    input    		opcode   	,
    input   [63:0]  dividend 	,
    input   [63:0]  divisor  	,		    
    output  		valid_out	,
    output  [63:0]  quotient 	,
    output  [63:0]  remainder
);
////////////////////////////////////////////////
wire 			state;
reg 			state_next;
wire	[6	:0]	cycle;
reg		[6	:0] cycle_next;

localparam IDEL = 1'b0;
localparam RUN = 1'b1;

always@(*) begin
	case(state)
		IDEL: begin
			state_next = en && ~flush ? RUN : IDEL;
			cycle_next = en && ~flush ? cycle + 'b1 : 'b0;
		end
		RUN: begin
			state_next = cycle == 'd65 | flush ? IDEL : RUN;
			cycle_next = cycle == 'd65 | flush ? 'b0 : cycle + 'b1;
		end
	endcase
end

dff_ar #(1) state_dff(.clock(clock), .reset(reset), .d(state_next), .q(state));
dff_ar #(7) cycle_dff(.clock(clock), .reset(reset), .d(cycle_next), .q(cycle));
////////////////////////////////////////////////
wire [128:0] dividend_true;
wire [64:0] divisor_true;
wire [64:0] divisor_negative;

assign dividend_true = opcode ? {{65{dividend[63:63]}}, dividend} : {65'b0, dividend};
assign divisor_true = opcode ? {divisor[63:63], divisor} : {1'b0, divisor};
assign divisor_negative = ~divisor_true + 'b1;
////////////////////////////////////////////////
wire [128:0] result;
wire [128:0] result_shifted;
wire [128:0] result_next;
wire [64:0] r_adder_src0;
wire [64:0] r_adder_src1;
wire [64:0] r_adder_result;
wire q;

assign result_shifted = {result[127:0], 1'b0};
assign r_adder_src0 = result_shifted[128:64];
assign r_adder_src1 = result[128:128] == divisor_true[64:64] ? divisor_negative : divisor_true;
assign r_adder_result = r_adder_src0 + r_adder_src1;
assign q = result[128:128] == divisor_true[64:64] ? 'b1 : 'b0;
assign result_next = state == IDLE ? dividend_true : {r_adder_result, result_shifted[63:1], q};

dff #(129) result_dff(.clock(clock), .d(result_next), .q(result));
////////////////////////////////////////////////
wire correction_en;
wire [63:0] quotient_correction;
wire [64:0] remainder_correction;

assign correction_en = cycle == 'd64;

dff_en #(64) quotient_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[63:0]), .q(quotient_correction));
dff_en #(65) remainder_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[128:64]), .q(remainder_correction));
////////////////////////////////////////////////
wire valid_out_next;
wire need_correct;
wire add_correct;

wire [63:0] quotient_complement;
wire [63:0] quotient_addend;
wire [63:0] quotient_corrected;

wire [63:0] remainder_addend;
wire [63:0] remainder_corrected;

assign valid_out_next = cycle == 'd65;
assign need_correct = remainder_correction[64:64] != dividend_true[128:128];
assign add_correct = remainder_correction[64:64] != divisor_true[64:64];

assign quotient_addend = add_correct ? 64'hffff_ffff_ffff_ffff : 64'b1;
assign quotient_complement = {quotient_correction[62:0], 1'b1};
assign quotient_corrected = need_correct ? quotient_complement + quotient_addend : quotient_complement;

assign remainder_addend = add_correct ? divisor_true[63:0] : divisor_negative[63:0];
assign remainder_corrected = need_correct ? remainder_correction[63:0] + remainder_addend : remainder_correction[63:0];

dff_ar #(1) valid_out_dff_ar(.clock(clock), .reset(reset), .d(valid_out_next), .q(valid_out));
dff #(64) quotient_dff(.clock(clock), .d(quotient_corrected), .q(quotient));
dff #(64) remainder_dff(.clock(clock), .d(remainder_corrected), .q(remainder));

endmodule
