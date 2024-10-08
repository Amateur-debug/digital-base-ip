module ram_sp
#(
	parameter   DATA_WIDTH = 32,			//ram位宽
    parameter   DEPTH = 16, 				//ram深度
	localparam  ADDR_WIDTH = $clog2(DEPTH),
	localparam  BWEN_WIDTH = DATA_WIDTH / 8
)
(
    input               			clock	,
    input                			cen		,
    input                	  		wen		,
    input       [ADDR_WIDTH - 1:0]	addr	,
    input       [DATA_WIDTH - 1:0]  din		,
    output reg  [DATA_WIDTH - 1:0]  dout   
);

reg [DATA_WIDTH - 1:0] ram [DEPTH - 1:0];

always@(posedge clock) begin
    if(cen && wen) begin
        ram[addr] <= din;
    end
end

always@(posedge clock) begin
    if(cen && !wen) begin
        dout <= ram[addr];
    end
end

endmodule
