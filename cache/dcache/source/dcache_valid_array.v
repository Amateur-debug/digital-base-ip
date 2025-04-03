module dcache_valid_array(

	input	clock	,
	input	reset	,
	
	//-------------------------------------------
	//Interface with lookup
	input			lookup2valid_array_valid,
	input   [5  :0]	lookup2valid_array_index,
	input			lookup2valid_array_ready,
	output  [7  :0]	valid_array2lookup_rdata,
	
	//-------------------------------------------
	//Interface with fill
	input			fill2valid_array_valid	,  
	input   [5  :0]	fill2valid_array_index	,
	input   [2  :0]	fill2valid_array_way		
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 			cen;
wire 			wen;
reg 	[7	:0]	bwen;
wire	[5	:0]	addr;
reg		[7	:0]	din;
wire	[7	:0]	dout;

assign cen = lookup2valid_array_valid || fill2valid_array_valid;
assign wen = fill2valid_array_valid;
assign addr = lookup2valid_array_valid ? lookup2valid_array_index : fill2valid_array_index;

always@(*) begin
	case(fill2valid_array_way)
		'b000: begin
			bwen = 'b0000_0001;
			din = 'b0000_0001;
		end
		'b001: begin
			bwen = 'b0000_0010;
			din = 'b0000_0010;
		end
		'b010: begin
			bwen = 'b0000_0100;
			din = 'b0000_0100;
		end
		'b011: begin
			bwen = 'b0000_1000;
			din = 'b0000_1000;
		end
		'b100: begin
			bwen = 'b0001_0000;
			din = 'b0001_0000;
		end
		'b101: begin
			bwen = 'b0010_0000;
			din = 'b0010_0000;
		end
		'b110: begin
			bwen = 'b0100_0000;
			din = 'b0100_0000;
		end
		'b111: begin
			bwen = 'b1000_0000;
			din = 'b1000_0000;
		end
	endcase
end
			 
ram_sp_bitmask_ar #(8, 64) u_ram_sp_bitmask_ar(.clock(clock), .reset(reset), .cen(cen), .wen(wen), .bwen(bwen), .addr(addr), .din(din), .dout(dout));
dcache_data_holder #(8) lookup_data_holder(
	.clock		(clock						), 
	.reset		(reset						), 
	.valid_in	(lookup2valid_array_valid	), 
	.ready_in	(lookup2valid_array_ready	), 
	.data_in	(dout						), 
	.data_out	(valid_array2lookup_rdata	)
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
