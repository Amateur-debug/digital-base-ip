module dcache_fill(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with ctrl		
	input			ctrl2fill_valid	,
	input	[5	:0]	ctrl2fill_index	,
	input	[2	:0]	ctrl2fill_way	,
	input	[43	:0]	ctrl2fill_tag	,
	output			fill2ctrl_ready	,
	
	//-------------------------------------------
	//Interface with data_array	
	output			fill2data_array_valid	,
	output	[5  :0]	fill2data_array_index	,  
	output  [2  :0]	fill2data_array_way		, 
	output  [1  :0]	fill2data_array_offset	, 
	output  [127:0]	fill2data_array_wdata	,
	
	//-------------------------------------------
	//Interface with tag_array	
	output			fill2tag_array_valid	,
	output  [5  :0]	fill2tag_array_index	,  
	output  [2  :0]	fill2tag_array_way		, 
	output  [43	:0]	fill2tag_array_wdata	,
	
	//-------------------------------------------
	//Interface with valid_array	
	output			fill2valid_array_valid	,  
	output  [5  :0]	fill2valid_array_index	,
	output  [2  :0]	fill2valid_array_way	, 	
	
	//-------------------------------------------
	//Interface with dirty_array	
	output			fill2dirty_array_valid	,  
	output  [5  :0]	fill2dirty_array_index	,
	output  [2  :0]	fill2dirty_array_way	, 
	
	//-------------------------------------------
	//Interface with axi	
	output			arvalid	,
	output	[63	:0]	araddr 	,
	output	[3	:0]	arid   	,
	output	[7	:0]	arlen  	,
	output	[2	:0]	arsize 	,
	output	[1	:0]	arburst	,
	input			arready	,
		
	output			rready 	,
	input			rvalid 	,
	input	[1	:0]	rresp  	,
	input	[127:0]	rdata  	,
	input			rlast  	,
	input	[3	:0]	rid    		
);
////////////////////////////////////////////////////////////////////////
localparam AXI_ID = 4'b0001;

localparam OKAY = 2'b00;
localparam EXOKAY = 2'b01;
//localparam SLVERR = 2'b10;
//localparam DECERR = 2'b11;

//localparam FIXED = 2'b00;
localparam INCR = 2'b01;
//localparam WRAP = 2'b10;
//localparam Rserved = 2'b11;
////////////////////////////////////////////////////////////////////////
localparam IDLE 			= 'b000;
localparam WFAR 			= 'b000;
localparam RD_DATA_0		= 'b001;
localparam RD_DATA_1 		= 'b010;
localparam RD_DATA_2 		= 'b011;
localparam RD_DATA_3 		= 'b100;
localparam W_DATA			= 'b101;
////////////////////////////////////////////////////////////////////////
wire	[2	:0]	state;
reg		[2	:0]	state_next;
reg				fill2ctrl_ready_temp;
reg				fill2data_array_valid_temp;
reg				fill2data_array_offset_temp;
reg				fill2tag_array_valid_temp;
reg				fill2valid_array_valid_temp;
reg				fill2dirty_array_valid_temp;
reg				arvalid_temp;
reg				rready_temp;

always@(*) begin
	case(state)
		IDLE: begin
			state_next = ctrl2fill_valid && arready ? RD_DATA_0 : IDLE;
			fill2ctrl_ready_temp = 'b0;
			fill2data_array_valid_temp = 'b0;
			fill2data_array_offset_temp = 'b0;
			fill2tag_array_valid_temp = 'b1;
			fill2valid_array_valid_temp = 'b1;
			fill2dirty_array_valid_temp = 'b1;
			arvalid_temp = ctrl2fill_valid;
			rready_temp = 'b0;
		end
		RD_DATA_0: begin
			state_next = rvalid ? RD_DATA_1 : RD_DATA_0;
			fill2ctrl_ready_temp = 'b0;
			fill2data_array_valid_temp = rvalid;
			fill2data_array_offset_temp = 'b00;
			fill2tag_array_valid_temp = 'b0;
			fill2valid_array_valid_temp = 'b0;
			fill2dirty_array_valid_temp = 'b0;
			arvalid_temp = 'b0;
			rready_temp = 'b1;
		end
		RD_DATA_1: begin
			state_next = rvalid ? RD_DATA_2 : RD_DATA_1;
			fill2ctrl_ready_temp = 'b0;
			fill2data_array_valid_temp = rvalid;
			fill2data_array_offset_temp = 'b01;
			fill2tag_array_valid_temp = 'b0;
			fill2valid_array_valid_temp = 'b0;
			fill2dirty_array_valid_temp = 'b0;
			arvalid_temp = 'b0;
			rready_temp = 'b1;
		end
		RD_DATA_2: begin
			state_next = rvalid ? RD_DATA_3 : RD_DATA_2;
			fill2ctrl_ready_temp = 'b0;
			fill2data_array_valid_temp = rvalid;
			fill2data_array_offset_temp = 'b10;
			fill2tag_array_valid_temp = 'b0;
			fill2valid_array_valid_temp = 'b0;
			fill2dirty_array_valid_temp = 'b0;
			arvalid_temp = 'b0;
			rready_temp = 'b1;
		end
		RD_DATA_3: begin
			state_next = rvalid ? IDLE : RD_DATA_3;
			fill2ctrl_ready_temp = rvalid;
			fill2data_array_valid_temp = rvalid;
			fill2data_array_offset_temp = 'b11;
			fill2tag_array_valid_temp = 'b0;
			fill2valid_array_valid_temp = 'b0;
			fill2dirty_array_valid_temp = 'b0;
			arvalid_temp = 'b0;
			rready_temp = 'b1;
		end
	endcase
end

dff_ar #(3) state_dff_ar(.clock(clock), .reset(reset), .d(state_next), .q(state));
////////////////////////////////////////////////////////////////////////
assign fill2ctrl_ready = fill2ctrl_ready_temp;
assign fill2data_array_valid = fill2data_array_valid_temp;
assign fill2data_array_index = ctrl2fill_index;
assign fill2data_array_way = ctrl2fill_way;
assign fill2data_array_offset = fill2data_array_offset_temp;
assign fill2data_array_wdata = rdata;
assign fill2tag_array_valid = fill2tag_array_valid_temp;
assign fill2tag_array_index = ctrl2fill_index;
assign fill2tag_array_way = ctrl2fill_way;
assign fill2tag_array_wdata = ctrl2fill_tag;
assign fill2valid_array_valid = fill2valid_array_valid_temp;
assign fill2valid_array_index = ctrl2fill_index;
assign fill2valid_array_way	= ctrl2fill_way;
assign fill2dirty_array_valid = fill2dirty_array_valid_temp;
assign fill2dirty_array_index = ctrl2fill_index;
assign fill2dirty_array_way	= ctrl2fill_way;
assign arvalid = arvalid_temp;
assign araddr = {8'b0, ctrl2fill_tag, ctrl2fill_index, 6'b0};
assign arid = 'b0; 
assign arlen = 'b0000_1111;	 
assign arsize = 'b100;
assign arburst = INCR;
assign rready = rready_temp;
////////////////////////////////////////////////////////////////////////

endmodule

