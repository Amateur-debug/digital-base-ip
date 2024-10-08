module dcache_hit_write(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with ctrl
	input			ctrl2hit_write_valid	,
	input	[7	:0]	ctrl2hit_write_wstrb	,
	input	[5	:0]	ctrl2hit_write_index	,
	input	[2	:0]	ctrl2hit_write_way		,
	input	[5	:0]	ctrl2hit_write_offset	,
	input	[63	:0]	ctrl2hit_write_wdata	,
	
	//-------------------------------------------
	//Interface with data_array
	output			hit_write2data_array_valid	,  
	output  [15 :0]	hit_write2data_array_bwen	, 
	output  [5  :0]	hit_write2data_array_index	,  
	output  [2  :0]	hit_write2data_array_way	,
	output  [1  :0]	hit_write2data_array_offset	, 
	output  [127:0]	hit_write2data_array_wdata	,
	
	//-------------------------------------------
	//Interface with dirty_array
	output			hit_write2dirty_array_valid	,  
	output  [5  :0]	hit_write2dirty_array_index	, 
	output  [2  :0]	hit_write2dirty_array_way	, 	
	
	//-------------------------------------------
	//Interface with plru
	output			hit_write2plru_valid	,  
	output  [5  :0]	hit_write2plru_index	,
	output  [2  :0]	hit_write2plru_way	
);
////////////////////////////////////////////////////////////////////////
assign hit_write2data_array_valid = ctrl2hit_write_valid;
assign hit_write2data_array_bwen = ctrl2hit_write_offset[3] ? {ctrl2hit_write_wstrb, 8'b0} : {8'b0, ctrl2hit_write_wstrb};
assign hit_write2data_array_index = ctrl2hit_write_index;
assign hit_write2data_array_way	= ctrl2hit_write_way;
assign hit_write2data_array_offset = ctrl2hit_write_offset[5:4];
assign hit_write2data_array_wdata = ctrl2hit_write_offset[3] ? {ctrl2hit_write_wdata, 64'b0} : {64'b0, ctrl2hit_write_wdata};
assign hit_write2dirty_array_valid = ctrl2hit_write_valid;
assign hit_write2dirty_array_index = ctrl2hit_write_index;	
assign hit_write2dirty_array_way = ctrl2hit_write_way;
assign hit_write2plru_valid = ctrl2hit_write_valid;
assign hit_write2plru_index = ctrl2hit_write_index;
assign hit_write2plru_way = ctrl2hit_write_way;
////////////////////////////////////////////////////////////////////////

endmodule

