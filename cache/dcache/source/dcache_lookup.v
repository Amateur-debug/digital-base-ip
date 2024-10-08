module dcache_lookup(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with ctrl	
	input			ctrl2lookup_valid		,
	input	[5	:0]	ctrl2lookup_index		,
	input	[43	:0]	ctrl2lookup_ptag		,
	
	output			lookup2ctrl_uncache		,
	output			lookup2ctrl_hit			,
	output			lookup2ctrl_vacancy		,
	output	[2	:0]	lookup2ctrl_way			,
	output	[351:0]	lookup2ctrl_tag_all		,
	input			ctrl2lookup_ready		,
	
	//-------------------------------------------
	//Interface with valid_array
	output			lookup2valid_array_valid,  
	output	[5  :0]	lookup2valid_array_index,
	output			lookup2valid_array_ready,
	input	[7  :0]	valid_array2lookup_rdata,
	
	//-------------------------------------------
	//Interface with tag_array	
	output			lookup2tag_array_valid	,  
	output	[5  :0]	lookup2tag_array_index	,
	output			lookup2tag_array_ready	,  
	input	[351:0]	tag_array2lookup_rdata		
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign lookup2valid_array_valid = ctrl2lookup_valid;
assign lookup2valid_array_index = ctrl2lookup_index;
assign lookup2valid_array_ready = ctrl2lookup_ready;
assign lookup2tag_array_valid = ctrl2lookup_valid;
assign lookup2tag_array_index = ctrl2lookup_index;
assign lookup2tag_array_ready = ctrl2lookup_ready;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [7:0]	hit_bits;
wire [2:0]	hit_way;
wire [2:0]	vacancy_way;
assign hit_bits[0:0] = ctrl2lookup_ptag == tag_array2lookup_rdata[43	:0	] && valid_array2lookup_rdata[0:0];
assign hit_bits[1:1] = ctrl2lookup_ptag == tag_array2lookup_rdata[87	:44	] && valid_array2lookup_rdata[1:1];
assign hit_bits[2:2] = ctrl2lookup_ptag == tag_array2lookup_rdata[131	:88	] && valid_array2lookup_rdata[2:2];
assign hit_bits[3:3] = ctrl2lookup_ptag == tag_array2lookup_rdata[175	:132] && valid_array2lookup_rdata[3:3];
assign hit_bits[4:4] = ctrl2lookup_ptag == tag_array2lookup_rdata[219	:176] && valid_array2lookup_rdata[4:4];
assign hit_bits[5:5] = ctrl2lookup_ptag == tag_array2lookup_rdata[263	:220] && valid_array2lookup_rdata[5:5];
assign hit_bits[6:6] = ctrl2lookup_ptag == tag_array2lookup_rdata[307	:264] && valid_array2lookup_rdata[6:6];
assign hit_bits[7:7] = ctrl2lookup_ptag == tag_array2lookup_rdata[351	:308] && valid_array2lookup_rdata[7:7];
assign hit_way = hit_bits[0:0] ? 'b000 :
				 hit_bits[1:1] ? 'b001 :
				 hit_bits[2:2] ? 'b010 :
				 hit_bits[3:3] ? 'b011 :
				 hit_bits[4:4] ? 'b100 :
				 hit_bits[5:5] ? 'b101 :
				 hit_bits[6:6] ? 'b110 :
				 hit_bits[7:7] ? 'b111 : 'b000;
assign vacancy_way = ~valid_array2lookup_rdata[0:0] ? 'b000 :
                     ~valid_array2lookup_rdata[1:1] ? 'b001 :
                     ~valid_array2lookup_rdata[2:2] ? 'b010 :
                     ~valid_array2lookup_rdata[3:3] ? 'b011 :
                     ~valid_array2lookup_rdata[4:4] ? 'b100 :
                     ~valid_array2lookup_rdata[5:5] ? 'b101 :
                     ~valid_array2lookup_rdata[6:6] ? 'b110 :
                     ~valid_array2lookup_rdata[7:7] ? 'b111 : 'b000;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign lookup2ctrl_hit = |hit_bits;
assign lookup2ctrl_vacancy = &valid_array2lookup_rdata;
assign lookup2ctrl_way = lookup2ctrl_hit ? hit_way : vacancy_way;
assign lookup2ctrl_tag_all = tag_array2lookup_rdata;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule

