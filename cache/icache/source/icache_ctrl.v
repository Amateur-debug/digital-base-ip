module icache_ctrl(

	input			clock		,
	input			reset		,
					
	input			in_valid	,
	input	[1	:0]	opcode		,
	input	[5	:0]	index		,
	input	[5	:0]	offset		,
	output			out_ready	,
					
	output			out_valid	,
	output	[63 :0]	rdata		,
	input			in_ready	,
					
	input			ptag_valid	,
	input	[43	:0]	ptag		,
	output			ptag_ready	,
	
	//-------------------------------------------
	//Interface with lookup
	output			ctrl2lookup_valid		,
	output	[5	:0]	ctrl2lookup_index		,
	output	[43	:0]	ctrl2lookup_ptag		,
	
	input			lookup2ctrl_uncache		,
	input			lookup2ctrl_hit			,
	input			lookup2ctrl_vacancy		,
	input	[2	:0]	lookup2ctrl_way			,
	input	[351:0]	lookup2ctrl_tag_all		,
	output			ctrl2lookup_ready		,	
	
	//-------------------------------------------
	//Interface with hit_read
	output			ctrl2hit_read_valid	,
	output	[5	:0]	ctrl2hit_read_index	,
	output	[2	:0]	ctrl2hit_read_way	,
	output	[5	:0]	ctrl2hit_read_offset,
	
	output			ctrl2hit_read_ready	,
	input	[63	:0]	hit_read2ctrl_rdata	,
	
	//-------------------------------------------
	//Interface with replace
	output			ctrl2replace_valid	,
	output	[5	:0]	ctrl2replace_index	,
	output	[351:0]	ctrl2replace_tag_all,
		
	output			ctrl2replace_ready	,
	input	[2	:0]	replace2ctrl_way	,
	input	[43	:0]	replace2ctrl_tag	,
	
	//-------------------------------------------
	//Interface with fill
	output			ctrl2fill_valid	,
	output	[5	:0]	ctrl2fill_index	,
	output	[2	:0]	ctrl2fill_way	,
	output	[43	:0]	ctrl2fill_tag	,
	input			fill2ctrl_ready	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`include "icache_opcode.vh"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 	[1	:0]	opcode_d1;
wire 	[5	:0]	index_d1;
wire 	[5	:0] offset_d1;

dff_aren #(2) opcode_dff_aren(.clock(clock), .reset(reset), .en(in_valid), .d(opcode), .q(opcode_d1));
dff_aren #(6) index_dff_aren(.clock(clock), .reset(reset), .en(in_valid), .d(index), .q(index_d1));
dff_aren #(6) offset_dff_aren(.clock(clock), .reset(reset), .en(in_valid), .d(offset), .q(offset_d1));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE = 'b000;
localparam LOOKUP = 'b001;
localparam HIT_READ = 'b010;
localparam REPLACE = 'b011;
localparam FILL = 'b100;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire	[2	:0]	state;
reg		[2	:0]	state_next;
reg				out_ready_temp;
reg				out_valid_temp;
reg				ptag_ready_temp;
reg				ctrl2lookup_valid_temp;
reg 			ctrl2lookup_ready_temp;
reg				ctrl2hit_read_valid_temp;
reg				ctrl2hit_read_ready_temp;
reg				ctrl2replace_valid_temp;
reg				ctrl2replace_ready_temp;
reg				ctrl2fill_valid_temp;
reg		[5	:0]	index_temp;
reg		[2	:0]	way_temp;
reg		[43	:0]	tag_temp;

always@(*) begin
	out_ready_temp = 'b0;
    out_valid_temp = 'b0;
	ptag_ready_temp = 'b0;
    ctrl2lookup_valid_temp = 'b0;
    ctrl2lookup_ready_temp = 'b0;
    ctrl2hit_read_valid_temp = 'b0;
    ctrl2hit_read_ready_temp = 'b0;
    ctrl2replace_valid_temp = 'b0;
    ctrl2replace_ready_temp = 'b0;
    ctrl2fill_valid_temp = 'b0;
    index_temp = 'b0;
    way_temp = 'b0;
	tag_temp = 'b0;
	case(state)
		IDLE: begin
			state_next = in_valid ? LOOKUP : IDLE;
			out_ready_temp = 'b1;			
			ctrl2lookup_valid_temp = in_valid;
			ctrl2hit_read_ready_temp = 'b1;
			ctrl2replace_ready_temp = 'b1;
			index_temp = index;
			tag_temp = ptag;
		end
		LOOKUP: begin
			state_next = ~ptag_valid ? LOOKUP : 
						 lookup2ctrl_hit ? (opcode_d1 == DCACHE_RD ? HIT_READ : IDLE) :
						 lookup2ctrl_vacancy ? FILL : REPLACE;
			ctrl2lookup_ready_temp = ~ptag_valid ? 'b0 : 
									 lookup2ctrl_hit ? 'b1 : 'b0;								
			ctrl2hit_read_valid_temp = ptag_valid && lookup2ctrl_hit && opcode_d1 == DCACHE_RD;
			ctrl2replace_valid_temp = ptag_valid && ~lookup2ctrl_hit && ~lookup2ctrl_vacancy;
			ctrl2fill_valid_temp = ptag_valid && ~lookup2ctrl_hit && lookup2ctrl_vacancy;
			index_temp = index_d1;
			way_temp = lookup2ctrl_way;
			tag_temp = ptag;
		end
		HIT_READ: begin
			state_next = in_ready ? IDLE : HIT_READ;
			ctrl2hit_read_ready_temp = in_ready;
			out_valid_temp = 'b1;
		end
		REPLACE: begin
			state_next = fill2ctrl_ready ? FILL : REPLACE;
			ctrl2replace_ready_temp = 'b0;
			ctrl2fill_valid_temp = 'b1;
			index_temp = index_d1;
			way_temp = replace2ctrl_way;
			tag_temp = replace2ctrl_tag;
		end
		FILL: begin
			state_next = opcode_d1 == DCACHE_RD ? HIT_READ : IDLE;
			ctrl2hit_read_valid_temp = opcode_d1 == DCACHE_RD;
		end
		default: begin
			state_next = IDLE;
		end
	endcase
end

dff_ar #(3) state_dff_ar(.clock(clock), .reset(reset), .d(state_next), .q(state));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign out_ready = out_ready_temp;
assign out_valid = out_valid_temp;
assign rdata = hit_read2ctrl_rdata;
assign ctrl2lookup_valid = ctrl2lookup_valid_temp;
assign ctrl2lookup_index = index_temp;
assign ctrl2lookup_ptag = tag_temp;
assign ctrl2lookup_ready = ctrl2lookup_ready_temp;
assign ctrl2hit_read_valid = ctrl2hit_read_valid_temp;
assign ctrl2hit_read_index = index_temp;
assign ctrl2hit_read_way = way_temp;
assign ctrl2hit_read_offset = offset_d1;
assign ctrl2hit_read_ready = ctrl2hit_read_ready_temp;
assign ctrl2replace_valid = ctrl2replace_valid_temp;
assign ctrl2replace_index = index_temp;
assign ctrl2replace_tag_all = lookup2ctrl_tag_all;
assign ctrl2replace_ready = ctrl2replace_ready_temp;
assign ctrl2fill_valid = ctrl2fill_valid_temp;	
assign ctrl2fill_index = index_temp;
assign ctrl2fill_way = way_temp;
assign ctrl2fill_tag = tag_temp;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule

