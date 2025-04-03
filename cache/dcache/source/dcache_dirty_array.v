module dcache_dirty_array(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with replace
	input			replace2dirty_array_valid,  
	input   [5  :0]	replace2dirty_array_index,  
	input			replace2dirty_array_ready,	
	output  [7  :0]	dirty_array2replace_rdata,
	
	//-------------------------------------------
	//Interface with hit_write
	input			hit_write2dirty_array_valid	,  
	input   [5  :0]	hit_write2dirty_array_index	, 
	input   [2  :0]	hit_write2dirty_array_way	, 	  
	
	//-------------------------------------------
	//Interface with fill
	input			fill2dirty_array_valid	,  
	input   [5  :0]	fill2dirty_array_index	,
	input   [2  :0]	fill2dirty_array_way		
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 			cen;
wire 			wen;
reg 	[7	:0]	bwen;
wire	[5	:0]	addr;
wire	[7	:0]	din;
wire	[7	:0]	dout;
wire	[2	:0]	way_true;

assign cen = replace2dirty_array_valid || hit_write2dirty_array_valid || fill2dirty_array_valid;
assign wen = hit_write2dirty_array_valid || fill2dirty_array_valid;
assign addr = replace2dirty_array_valid ? replace2dirty_array_index :
			  hit_write2dirty_array_valid ? hit_write2dirty_array_index : fill2dirty_array_index;
assign din = hit_write2dirty_array_valid ? 'b1111_1111 : 'b0000_0000;
assign way_true = hit_write2dirty_array_valid ? hit_write2dirty_array_way : fill2dirty_array_way;

always@(*) begin
	case(way_true)
		'b000: begin
			bwen = 'b0000_0001;
		end
		'b001: begin
			bwen = 'b0000_0010;
		end
		'b010: begin
			bwen = 'b0000_0100;
		end
		'b011: begin
			bwen = 'b0000_1000;
		end
		'b100: begin
			bwen = 'b0001_0000;
		end
		'b101: begin
			bwen = 'b0010_0000;
		end
		'b110: begin
			bwen = 'b0100_0000;
		end
		'b111: begin
			bwen = 'b1000_0000;
		end
	endcase
end	
	
ram_sp_bitmask #(8, 64) u_ram_sp_bitmask(.clock(clock), .cen(cen), .wen(wen), .bwen(bwen), .addr(addr), .din(din), .dout(dout));
dcache_data_holder #(8) replace_data_holder(
	.clock		(clock						), 
	.reset		(reset						), 
	.valid_in	(replace2dirty_array_valid	), 
	.ready_in	(replace2dirty_array_ready	), 
	.data_in	(dout						), 
	.data_out	(dirty_array2replace_rdata	)
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
