module dcache_replace(

	input			clock,
	input			reset,
	
	//-------------------------------------------
	//Interface with ctrl
	input			ctrl2replace_valid	,
	input	[5	:0]	ctrl2replace_index	,
	input	[351:0]	ctrl2replace_tag_all,
		
	output	[2	:0]	replace2ctrl_way	,
	output			replace2ctrl_dirty	,
	output	[43	:0]	replace2ctrl_tag	,
	input			ctrl2replace_ready	,
		
	//-------------------------------------------
	//Interface with plru
	output			replace2plru_valid	,
	output	[5	:0]	replace2plru_index	,
	
	input	[2	:0]	plru2replace_way	,	
	output			replace2plru_ready	,
	
	//-------------------------------------------
	//Interface with dirty_array
	output			replace2dirty_array_valid,  
	output	[5  :0]	replace2dirty_array_index,
		
	input	[7  :0]	dirty_array2replace_rdata,
	output			replace2dirty_array_ready	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 	[351:0] ctrl2replace_tag_all_d1;

dff_aren #(352) tag_all_dff_aren(.clock(clock), .reset(reset), .en(ctrl2replace_valid), .d(ctrl2replace_tag_all), .q(ctrl2replace_tag_all_d1));
///////////////////////////////////////////////////////////////////////
reg 		dirty_temp;
reg	[43	:0]	tag_temp;
always@(*) begin
	case(plru2replace_way)
		3'b000: begin
			dirty_temp = dirty_array2replace_rdata[0:0];
			tag_temp = ctrl2replace_tag_all_d1[43:0];
		end
		3'b001: begin
			dirty_temp = dirty_array2replace_rdata[1:1];
			tag_temp = ctrl2replace_tag_all_d1[87:44];
		end
		3'b010: begin
			dirty_temp = dirty_array2replace_rdata[2:2];
			tag_temp = ctrl2replace_tag_all_d1[131:88];
		end
		3'b011: begin
			dirty_temp = dirty_array2replace_rdata[3:3];
			tag_temp = ctrl2replace_tag_all_d1[175:132];
		end
		3'b100: begin
			dirty_temp = dirty_array2replace_rdata[4:4];
			tag_temp = ctrl2replace_tag_all_d1[219:176];
		end
		3'b101: begin
			dirty_temp = dirty_array2replace_rdata[5:5];
			tag_temp = ctrl2replace_tag_all_d1[263:220];
		end
		3'b110: begin
			dirty_temp = dirty_array2replace_rdata[6:6];
			tag_temp = ctrl2replace_tag_all_d1[307:264];
		end
		3'b111: begin
			dirty_temp = dirty_array2replace_rdata[7:7];
			tag_temp = ctrl2replace_tag_all_d1[351:308];
		end
	endcase
end
////////////////////////////////////////////////////////////////////////
assign replace2ctrl_way = plru2replace_way;
assign replace2ctrl_dirty = dirty_temp;
assign replace2ctrl_tag = tag_temp;
////////////////////////////////////////////////////////////////////////
assign replace2plru_valid = ctrl2replace_valid;
assign replace2plru_index = ctrl2replace_index;
assign replace2plru_ready = ctrl2replace_ready;
assign replace2dirty_array_valid = ctrl2replace_valid;
assign replace2dirty_array_index = ctrl2replace_index;
assign replace2dirty_array_ready = ctrl2replace_ready;
////////////////////////////////////////////////////////////////////////

endmodule

