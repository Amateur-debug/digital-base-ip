module dcache_data_array(

	input	clock	,
	input	reset	,
	
	//-------------------------------------------
	//Interface with hit_read	
	input			hit_read2data_array_valid	,  
	input	[5  :0]	hit_read2data_array_index	,   
	input   [2  :0]	hit_read2data_array_way		,
	input   [1 	:0]	hit_read2data_array_offset	, 
	input 			hit_read2data_array_ready 	,
	output	[127:0]	data_array2hit_read_rdata	,
	
	//-------------------------------------------
	//Interface with hit_write	
	input			hit_write2data_array_valid	,  
	input   [15 :0]	hit_write2data_array_bwen	, 
	input   [5  :0]	hit_write2data_array_index	,  
	input   [2  :0]	hit_write2data_array_way	,
	input   [1  :0]	hit_write2data_array_offset	, 
	input   [127:0]	hit_write2data_array_wdata	,
	
	//-------------------------------------------
	//Interface with fill	
	input			fill2data_array_valid	,
	input   [5  :0]	fill2data_array_index	,  
	input   [2  :0]	fill2data_array_way		, 
	input   [1  :0]	fill2data_array_offset	, 
	input   [127:0]	fill2data_array_wdata	,
	
	//-------------------------------------------
	//Interface with wback	
	input			wback2data_array_valid	,  
	input	[5  :0]	wback2data_array_index	,   
	input   [2  :0]	wback2data_array_way	,
	input   [1  :0]	wback2data_array_offset	,
	input			wback2data_array_ready	,
	output	[127:0]	data_array2wback_rdata			
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 			cen		[7:0];
wire 			wen;
wire	[15	:0]	bwen;
wire	[7	:0]	addr;
wire	[127:0]	din;
wire	[127:0]	dout	[7:0];
wire	[2	:0]	way_true;
wire	[2	:0]	way_true_d1;

assign way_true = hit_read2data_array_valid ? hit_read2data_array_way :
				  hit_write2data_array_valid ? hit_write2data_array_way : 
				  fill2data_array_valid ? fill2data_array_way : wback2data_array_way;
assign wen = hit_write2data_array_valid || fill2data_array_valid;
assign bwen = hit_write2data_array_valid ? hit_write2data_array_bwen : 'b1111_1111_1111_1111;
assign addr = hit_read2data_array_valid ? {hit_read2data_array_index, hit_read2data_array_offset} :
			  hit_write2data_array_valid ? {hit_write2data_array_index, hit_write2data_array_offset} : 
			  fill2data_array_valid ? {fill2data_array_index, fill2data_array_offset} : {wback2data_array_index, wback2data_array_offset};
assign din = hit_write2data_array_valid ? hit_write2data_array_wdata : fill2data_array_wdata;

dff_en #(3) way_true_dff_en(.clock(clock), .en(hit_read2data_array_valid || hit_write2data_array_valid || fill2data_array_valid || wback2data_array_valid), .d(way_true), .q(way_true_d1));
genvar i;
generate
	for(i =0; i < 8; i = i + 1) begin: dcache_data_array
		assign cen[i] = way_true == i && (hit_read2data_array_valid || hit_write2data_array_valid || fill2data_array_valid || wback2data_array_valid);
		ram_sp_bytemask #(128, 256) u_ram_sp_bytemask(.clock(clock), .cen(cen[i]), .wen(wen), .bwen(bwen), .addr(addr), .din(din), .dout(dout[i]));
	end
endgenerate
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire	[127:0]	rdata_temp;
assign rdata_temp = dout[way_true_d1];

dcache_data_holder #(128) hit_read_data_holder(
	.clock		(clock						), 
	.reset		(reset						), 
	.valid_in	(hit_read2data_array_valid	), 
	.ready_in	(hit_read2data_array_ready	), 
	.data_in	(rdata_temp					), 
	.data_out	(data_array2hit_read_rdata	)
);
dcache_data_holder #(128) wback_data_holder(
	.clock		(clock					), 
	.reset		(reset					), 
	.valid_in	(wback2data_array_valid	), 
	.ready_in	(wback2data_array_ready	), 
	.data_in	(rdata_temp				), 
	.data_out	(data_array2wback_rdata	)
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
                                               