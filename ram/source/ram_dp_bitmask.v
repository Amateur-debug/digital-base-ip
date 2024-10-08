module ram_dp_bitmask
#(
	parameter   DATA_WIDTH = 32,			//ram位宽
    parameter   DEPTH = 16, 				//ram深度
	localparam  ADDR_WIDTH = $clog2(DEPTH)
)
(
    input               			clock   ,
    input                			cen     ,
	
    input                	  		wen_a   ,
    input       [DATA_WIDTH - 1:0]  bwen_a  ,
    input       [ADDR_WIDTH - 1:0]  addr_a  ,
    input       [DATA_WIDTH - 1:0]	din_a	,
    output reg  [DATA_WIDTH - 1:0]  dout_a	,
	
	input                	  		wen_b   ,
    input       [DATA_WIDTH - 1:0]  bwen_b  ,
    input       [ADDR_WIDTH - 1:0]  addr_b  ,
    input       [DATA_WIDTH - 1:0]  din_b	,
    output reg  [DATA_WIDTH - 1:0]  dout_b   
);

reg	[DATA_WIDTH - 1:0]	ram [DEPTH - 1:0];

always@(posedge clock) begin
    if(cen && wen_a) begin
        ram[addr_a] <= (din_a & bwen_a) | (ram[addr_a] & ~bwen_a);
    end
	if(cen && wen_b) begin
		ram[addr_b] <= (din_b & bwen_b) | (ram[addr_b] & ~bwen_b);
    end
end

always@(posedge clock) begin
    if(cen && !wen_a) begin
		dout_a <= ram[addr_a];
	end
end

always@(posedge clock) begin
    if(cen && !wen_b) begin
		dout_b <= ram[addr_b];
	end
end

endmodule
