module dcache_wback(

	input	clock,
	input	reset,
	
	//-------------------------------------------
	//Interface with ctrl			
	input			ctrl2wback_valid,
	input	[5	:0]	ctrl2wback_index,
	input	[2	:0]	ctrl2wback_way	,
	input	[43	:0]	ctrl2wback_tag	,
	output			wback2ctrl_ready,
	
	//-------------------------------------------
	//Interface with data_array		
	output			wback2data_array_valid	,
	output	[5	:0]	wback2data_array_index	,
	output	[2	:0]	wback2data_array_way	,
	output	[1	:0]	wback2data_array_offset	,
	
	output			wback2data_array_ready	,
	input	[127:0]	data_array2wback_rdata	,
	
	//-------------------------------------------
	//Interface with axi	
	output			awvalid	,
	output	[63	:0]	awaddr	,
	output	[3	:0]	awid	,
	output	[7	:0]	awlen	,
	output	[2	:0]	awsize	,
	output	[1	:0]	awburst	,
	input			awready	,       
		
	output		   	wvalid	,
	output	[127:0]	wdata	,
	output	[15	:0] wstrb	,
	output			wlast	,
	input 		   	wready	,
			
	output			bready	,
	input			bvalid	,
	input	[1	:0]	bresp 	,
	input 	[3	:0]	bid   	
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
localparam W_DATA_0 		= 'b001;
localparam W_DATA_1 		= 'b010;
localparam W_DATA_2 		= 'b011;
localparam W_DATA_3 		= 'b100;
localparam RESPONSE 		= 'b101;
////////////////////////////////////////////////////////////////////////
wire	[2	:0]	state;
reg		[2	:0]	state_next;
reg				wback2ctrl_ready_temp;
reg				wback2data_array_valid_temp;
reg		[1	:0]	wback2data_array_offset_temp;
reg				wback2data_array_ready_temp;
reg				awvalid_temp;
reg				wvalid_temp;
reg				bready_temp;
reg				wlast_temp;

always@(*) begin
	case(state)
		IDLE: begin
			state_next = ctrl2wback_valid && awready ? W_DATA_0 : IDLE;
			wback2ctrl_ready_temp  = 'b0;
			wback2data_array_valid_temp = 'b1;
			wback2data_array_offset_temp = 'b00;
			wback2data_array_ready_temp = 'b0;
			awvalid_temp = ctrl2wback_valid;
			wvalid_temp = 'b0;
			bready_temp = 'b0;
			wlast_temp = 'b0;
		end
		W_DATA_0: begin
			state_next = wready ? W_DATA_1 : W_DATA_0;
			wback2ctrl_ready_temp  = 'b0;
			wback2data_array_valid_temp = wready;
			wback2data_array_offset_temp = 'b01;
			wback2data_array_ready_temp = wready;
			awvalid_temp = 'b0;
			wvalid_temp = 'b1;
			bready_temp = 'b0;
			wlast_temp = 'b0;
		end
		W_DATA_1: begin
			state_next = wready ? W_DATA_2 : W_DATA_1;
			wback2ctrl_ready_temp  = 'b0;
			wback2data_array_valid_temp = wready;
			wback2data_array_offset_temp = 'b10;
			wback2data_array_ready_temp = wready;
			awvalid_temp = 'b0;
			wvalid_temp = 'b1;
			bready_temp = 'b0;
			wlast_temp = 'b0;
		end
		W_DATA_2: begin
			state_next = wready ? W_DATA_3 : W_DATA_2;
			wback2ctrl_ready_temp  = 'b0;
			wback2data_array_valid_temp = wready;
			wback2data_array_offset_temp = 'b11;
			wback2data_array_ready_temp = wready;
			awvalid_temp = 'b0;
			wvalid_temp = 'b1;
			bready_temp = 'b0;
			wlast_temp = 'b0;
		end
		W_DATA_3: begin
			state_next = wready ? RESPONSE : W_DATA_3;
			wback2ctrl_ready_temp  = 'b0;
			wback2data_array_valid_temp = 'b0;
			wback2data_array_offset_temp = 'b0;
			wback2data_array_ready_temp = wready;
			awvalid_temp = 'b0;
			wvalid_temp = 'b1;
			bready_temp = 'b0;
			wlast_temp = 'b1;
		end
		RESPONSE: begin
			state_next = bvalid ? IDLE : RESPONSE;
			wback2ctrl_ready_temp  = bvalid;
			wback2data_array_valid_temp = 'b0;
			wback2data_array_offset_temp = 'b0;
			wback2data_array_ready_temp = bvalid;
			awvalid_temp = 'b0;
			wvalid_temp = 'b0;
			bready_temp = 'b1;
			wlast_temp = 'b0;
		end
	endcase
end

dff_ar #(3) state_dff_ar(.clock(clock), .reset(reset), .d(state_next), .q(state));
////////////////////////////////////////////////////////////////////////
assign wback2ctrl_ready = wback2ctrl_ready_temp;
assign wback2data_array_index = ctrl2wback_index;
assign wback2data_array_way = ctrl2wback_way;
assign wback2data_array_offset = wback2data_array_offset_temp;
assign wback2data_array_ready = wback2data_array_ready_temp;
assign awvalid = awvalid_temp;
assign awaddr = {8'b0, ctrl2wback_tag, ctrl2wback_index, 6'b0};
assign awid	= 'b0;
assign awlen = 'b0000_1111;	
assign awsize = 'b100;	
assign awburst = INCR;
assign wvalid = wvalid_temp;
assign wdata = data_array2wback_rdata;
assign wstrb = 'b1111_1111_1111_1111;
assign wlast = wlast_temp;
////////////////////////////////////////////////////////////////////////

endmodule

