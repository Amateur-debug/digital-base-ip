module dcache_plru(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with hit_read
	input			hit_read2plru_valid	,  
	input   [5  :0]	hit_read2plru_index	,
	input   [2  :0]	hit_read2plru_way	, 			
	
	//-------------------------------------------
	//Interface with hit_write
	input			hit_write2plru_valid,  
	input   [5  :0]	hit_write2plru_index, 
	input   [2  :0]	hit_write2plru_way	, 	 
	
	//-------------------------------------------
	//Interface with replace
	input			replace2plru_valid	,  
	input   [5  :0]	replace2plru_index	,  
	input			replace2plru_ready	,  	
	output  [2  :0]	plru2replace_way	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 			cen;
wire 			wen;
reg 	[6	:0]	bwen;
wire	[5	:0]	addr;
reg		[6	:0]	din;
wire	[6	:0]	dout;
wire	[2	:0]	way_true;
wire	[2	:0]	plru2replace_way_temp;

assign cen = hit_read2plru_valid || hit_write2plru_valid || replace2plru_valid;
assign wen = hit_read2plru_valid || hit_write2plru_valid;
assign addr = hit_read2plru_valid ? hit_read2plru_index :
			  hit_write2plru_valid ? hit_write2plru_index : replace2plru_index;
assign way_true = hit_read2plru_valid ? hit_read2plru_way : hit_write2plru_way;
assign plru2replace_way_temp = ~dout[0:0] && ~dout[1:1] && ~dout[3:3] ? 'b000 :
							   ~dout[0:0] && ~dout[1:1] &&  dout[3:3] ? 'b001 :
							   ~dout[0:0] &&  dout[1:1] && ~dout[3:3] ? 'b010 :
							   ~dout[0:0] &&  dout[1:1] &&  dout[3:3] ? 'b011 :
							    dout[0:0] && ~dout[1:1] && ~dout[3:3] ? 'b100 :
							    dout[0:0] && ~dout[1:1] &&  dout[3:3] ? 'b101 :
							    dout[0:0] &&  dout[1:1] && ~dout[3:3] ? 'b110 :
							    dout[0:0] &&  dout[1:1] &&  dout[3:3] ? 'b111 : 'b000;

always@(*) begin
	case(way_true)
		'b000: begin
			bwen = 'b000_1011;
			din = 'b000_1011;
		end
		'b001: begin
			bwen = 'b000_1011;
			din = 'b000_0011;
		end
		'b010: begin
			bwen = 'b001_0011;
			din = 'b001_0001;
		end
		'b011: begin
			bwen = 'b001_0011;
			din = 'b000_0001;
		end
		'b100: begin
			bwen = 'b010_0101;
			din = 'b010_0100;
		end
		'b101: begin
			bwen = 'b010_0101;
			din = 'b000_0100;
		end
		'b110: begin
			bwen = 'b100_0101;
			din = 'b100_0000;
		end
		'b111: begin
			bwen = 'b100_0101;
			din = 'b000_0000;
		end
	endcase
end	

ram_sp_bitmask_ar #(7, 64) u_ram_sp_bitmask_ar(.clock(clock), .reset(reset), .cen(cen), .wen(wen), .bwen(bwen), .addr(addr), .din(din), .dout(dout));
dcache_data_holder #(3) replace_data_holder(
	.clock		(clock						), 
	.reset		(reset						), 
	.valid_in	(replace2plru_valid			), 
	.ready_in	(replace2plru_ready			), 
	.data_in	(plru2replace_way_temp		), 
	.data_out	(plru2replace_way			)
);
endmodule
