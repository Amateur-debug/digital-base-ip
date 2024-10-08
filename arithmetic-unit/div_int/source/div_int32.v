module div_int32(

    input		    clock       ,
	input		    reset       ,					 
    input		    en    		,
    input    		opcode      ,
    input   [31:0]  dividend    ,
    input   [31:0]  divisor     ,		    
    output  		valid_out   ,
	output  		almost_valid,
    output  [31:0]  quotient    ,
    output  [31:0]  remainder
);
////////////////////////////////////////////////
wire state;
reg state_next;
wire [5:0] cycle;
reg [5:0] cycle_next;

localparam IDEL = 1'b0;
localparam RUN = 1'b1;

always@(*) begin
	case(state)
		IDEL: begin
			state_next = en ? RUN : IDEL;
			cycle_next = en ? cycle + 'b1 : 'b0;
		end
		RUN: begin
			state_next = cycle == 'd33 ? IDEL : RUN;
			cycle_next = cycle == 'd33 ? 'b0 : cycle + 'b1;
		end
	endcase
end

dff_ar #(1) state_dff(.clock(clock), .reset(reset), .d(state_next), .q(state));
dff_ar #(6) cycle_dff(.clock(clock), .reset(reset), .d(cycle_next), .q(cycle));
////////////////////////////////////////////////
wire [64:0] dividend_true;
wire [32:0] divisor_true;
wire [32:0] divisor_negative;

assign dividend_true = opcode ? {{33{dividend[31:31]}}, dividend} : {33'b0, dividend};
assign divisor_true = opcode ? {divisor[31:31], divisor} : {1'b0, divisor};
assign divisor_negative = ~divisor_true + 'b1;
////////////////////////////////////////////////
wire [64:0] result;
wire [64:0] result_shifted;
wire [64:0] result_next;
wire [32:0] r_adder_src0;
wire [32:0] r_adder_src1;
wire [32:0] r_adder_result;
wire q;

assign result_shifted = {result[63:0], 1'b0};
assign r_adder_src0 = result_shifted[64:32];
assign r_adder_src1 = result[64:64] == divisor_true[32:32] ? divisor_negative : divisor_true;
assign r_adder_result = r_adder_src0 + r_adder_src1;
assign q = result[64:64] == divisor_true[32:32] ? 'b1 : 'b0;
assign result_next = state == IDEL ? dividend_true : {r_adder_result, result_shifted[31:1], q};

dff #(65) result_dff(.clock(clock), .d(result_next), .q(result));
////////////////////////////////////////////////
wire almost_valid_next;
assign almost_valid_next = cycle == 'd32;
dff_ar #(1) almost_valid_dff(.clock(clock), .reset(reset), .d(almost_valid_next), .q(almost_valid));
////////////////////////////////////////////////
wire correction_en;
wire [31:0] quotient_correction;
wire [32:0] remainder_correction;

assign correction_en = cycle == 'd32;

dff_en #(32) quotient_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[31:0]), .q(quotient_correction));
dff_en #(33) remainder_correction_dff_en(.clock(clock), .en(correction_en), .d(result_next[64:32]), .q(remainder_correction));
////////////////////////////////////////////////
wire valid_out_next;
wire need_correct;
wire add_correct;

wire [31:0] quotient_complement;
wire [31:0] quotient_addend;
wire [31:0] quotient_corrected;

wire [31:0] remainder_addend;
wire [31:0] remainder_corrected;

assign valid_out_next = cycle == 'd33;
assign need_correct = remainder_correction[32:32] != dividend_true[64:64];
assign add_correct = remainder_correction[32:32] != divisor_true[32:32];

assign quotient_addend = add_correct ? 32'hffff_ffff : 32'b1;
assign quotient_complement = {quotient_correction[30:0], 1'b1};
assign quotient_corrected = need_correct ? quotient_complement + quotient_addend : quotient_complement;

assign remainder_addend = add_correct ? divisor_true[31:0] : divisor_negative[31:0];
assign remainder_corrected = need_correct ? remainder_correction[31:0] + remainder_addend : remainder_correction[31:0];

dff_ar #(1) valid_out_dff_ar(.clock(clock), .reset(reset), .d(valid_out_next), .q(valid_out));
dff #(32) quotient_dff(.clock(clock), .d(quotient_corrected), .q(quotient));
dff #(32) remainder_dff(.clock(clock), .d(remainder_corrected), .q(remainder));

endmodule
