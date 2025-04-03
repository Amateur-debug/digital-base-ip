module icache_hit_read(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with ctrl
	input			ctrl2hit_read_valid	,
	input	[5	:0]	ctrl2hit_read_index	,
	input	[2	:0]	ctrl2hit_read_way	,
	input	[5	:0]	ctrl2hit_read_offset,
	
	input			ctrl2hit_read_ready	,
	output	[63	:0]	hit_read2ctrl_rdata	,
	
	//-------------------------------------------
	//Interface with data_array
	output			hit_read2data_array_valid	,  
	output	[5  :0]	hit_read2data_array_index	,   
	output  [2  :0]	hit_read2data_array_way		,
	output  [1 	:0]	hit_read2data_array_offset	, 
	
	output 			hit_read2data_array_ready 	,
	input	[127:0]	data_array2hit_read_rdata	,
	
	//-------------------------------------------
	//Interface with plru
	output			hit_read2plru_valid	,  
	output  [5  :0]	hit_read2plru_index	,
	output  [2  :0]	hit_read2plru_way	
);
////////////////////////////////////////////////////////////////////////
wire 	[5	:0]	offset_d1;

dff_en #(6) offset_dff_en(.clock(clock), .en(ctrl2hit_read_valid), .d(ctrl2hit_read_offset), .q(offset_d1));
////////////////////////////////////////////////////////////////////////
assign hit_read2ctrl_rdata = offset_d1[3] ? data_array2hit_read_rdata[127:64] : data_array2hit_read_rdata[63:0];
assign hit_read2data_array_valid = ctrl2hit_read_valid;
assign hit_read2data_array_index = ctrl2hit_read_index;
assign hit_read2data_array_way = ctrl2hit_read_way;
assign hit_read2data_array_offset = ctrl2hit_read_offset[5:4];
assign hit_read2data_array_ready = ctrl2hit_read_ready;
assign hit_read2plru_valid = ctrl2hit_read_valid;
assign hit_read2plru_index = ctrl2hit_read_index;
assign hit_read2plru_way = ctrl2hit_read_way;
////////////////////////////////////////////////////////////////////////

endmodule

