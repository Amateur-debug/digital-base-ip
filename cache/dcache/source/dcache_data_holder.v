module dcache_data_holder
#(
	parameter DATA_WIDTH = 32
)
(

	input						clock	,
	input						reset	,
							
	input						valid_in,
	input						ready_in,		
	input	[DATA_WIDTH - 1:0]	data_in	,
	output	[DATA_WIDTH - 1:0]	data_out									
);
////////////////////////////////////////////////////////////////////////
localparam IDLE = 'b00;
localparam RUN = 'b01;
localparam HOLD = 'b10;
////////////////////////////////////////////////////////////////////////
wire	[1				:0]	state;
reg							state_next;
reg		[DATA_WIDTH - 1	:0] data_out_temp;
wire 						save_en;
wire	[DATA_WIDTH - 1	:0]	data_saved;


always@(*) begin
	case(state)
		IDLE: begin
			state_next = valid_in ? RUN : IDLE;
			data_out_temp = 'b0;
		end
		RUN: begin
			state_next = ~ready_in ? HOLD : 
						 valid_in ? RUN : IDLE;
			data_out_temp = data_in;
		end
		HOLD: begin
			state_next = ~ready_in ? HOLD : 
						 valid_in ? RUN : IDLE;
			data_out_temp = data_saved;
		end
		default: begin
			state_next = IDLE;
			data_out_temp = 'b0;
		end
		
	endcase
end

assign data_out = data_out_temp;
assign save_en = state == RUN;

dff_ar #(2) state_dff_ar(.clock(clock), .reset(reset), .d(state_next), .q(state));
dff_aren #(DATA_WIDTH) data_in_dff_aren(.clock(clock), .reset(reset), .en(save_en), .d(data_in), .q(data_saved));
////////////////////////////////////////////////////////////////////////

endmodule

