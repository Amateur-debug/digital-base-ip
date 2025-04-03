module icache_replace(

	input			clock,
	input			reset,
	
	//-------------------------------------------
	//Interface with ctrl
	input			ctrl2replace_valid	,
	input	[5	:0]	ctrl2replace_index	,
	input	[351:0]	ctrl2replace_tag_all,
		
	output	[2	:0]	replace2ctrl_way	,
	output	[43	:0]	replace2ctrl_tag	,
	input			ctrl2replace_ready	,
		
	//-------------------------------------------
	//Interface with plru
	output			replace2plru_valid	,
	output	[5	:0]	replace2plru_index	,
	
	input	[2	:0]	plru2replace_way	,	
	output			replace2plru_ready	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 	[351:0] ctrl2replace_tag_all_d1;

dff_aren #(352) tag_all_dff_aren(.clock(clock), .reset(reset), .en(ctrl2replace_valid), .d(ctrl2replace_tag_all), .q(ctrl2replace_tag_all_d1));
///////////////////////////////////////////////////////////////////////
reg	[43	:0]	tag_temp;
always@(*) begin
	case(plru2replace_way)
		3'b000: begin
			tag_temp = ctrl2replace_tag_all_d1[43:0];
		end
		3'b001: begin
			tag_temp = ctrl2replace_tag_all_d1[87:44];
		end
		3'b010: begin
			tag_temp = ctrl2replace_tag_all_d1[131:88];
		end
		3'b011: begin
			tag_temp = ctrl2replace_tag_all_d1[175:132];
		end
		3'b100: begin
			tag_temp = ctrl2replace_tag_all_d1[219:176];
		end
		3'b101: begin
			tag_temp = ctrl2replace_tag_all_d1[263:220];
		end
		3'b110: begin
			tag_temp = ctrl2replace_tag_all_d1[307:264];
		end
		3'b111: begin
			tag_temp = ctrl2replace_tag_all_d1[351:308];
		end
	endcase
end
////////////////////////////////////////////////////////////////////////
assign replace2ctrl_way = plru2replace_way;
assign replace2ctrl_tag = tag_temp;
////////////////////////////////////////////////////////////////////////
assign replace2plru_valid = ctrl2replace_valid;
assign replace2plru_index = ctrl2replace_index;
assign replace2plru_ready = ctrl2replace_ready;
////////////////////////////////////////////////////////////////////////

endmodule

