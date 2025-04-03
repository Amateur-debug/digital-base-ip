module dcache_tag_array(

	input	clock	,
	input	reset	,
	
	//-------------------------------------------
	//Interface with lookup
	input			lookup2tag_array_valid,  
	input   [5  :0]	lookup2tag_array_index,
	input			lookup2tag_array_ready,  
	output  [351:0]	tag_array2lookup_rdata,
	
	//-------------------------------------------
	//Interface with fill
	input			fill2tag_array_valid	,
	input   [5  :0]	fill2tag_array_index	,  
	input   [2  :0]	fill2tag_array_way		, 
	input   [43	:0]	fill2tag_array_wdata	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 			cen		[7:0];
wire 			wen		[7:0];
wire	[5	:0]	addr	[7:0];
wire	[43	:0]	din		[7:0];
wire	[43	:0]	dout	[7:0];

genvar i;
generate
	for(i = 0; i < 8; i = i + 1) begin: dcache_tag_array
		assign cen[i] = lookup2tag_array_valid || fill2tag_array_valid && fill2tag_array_way == i;			
		assign wen[i] = fill2tag_array_valid && fill2tag_array_way == i;				
		assign addr[i] = lookup2tag_array_valid ? lookup2tag_array_index : fill2tag_array_index;
		assign din[i] = fill2tag_array_wdata;						
		ram_sp #(44, 64) u_ram_sp(.clock(clock), .cen(cen[i]), .wen(wen[i]), .addr(addr[i]), .din(din[i]), .dout(dout[i]));
	end
endgenerate
dcache_data_holder #(352) lookup_data_holder(
	.clock		(clock																		), 
	.reset		(reset																		), 
	.valid_in	(lookup2tag_array_valid														), 
	.ready_in	(lookup2tag_array_ready														), 
	.data_in	({dout[7], dout[6], dout[5], dout[4], dout[3], dout[2], dout[1], dout[0]}	), 
	.data_out	(tag_array2lookup_rdata														)
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
                                               