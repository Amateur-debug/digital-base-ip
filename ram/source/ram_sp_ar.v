module ram_sp_ar
#(
	parameter   DATA_WIDTH = 32,			//ram位宽
    parameter   DEPTH = 16, 				//ram深度
	localparam  ADDR_WIDTH = $clog2(DEPTH),
	localparam  BWEN_WIDTH = DATA_WIDTH / 8
)
(
    input               			clock	,
	input               			reset	,
    input                			cen		,
    input                	  		wen		,
    input       [ADDR_WIDTH - 1:0]	addr	,
    input       [DATA_WIDTH - 1:0]  din		,
    output reg  [DATA_WIDTH - 1:0]  dout   
);

reg [DATA_WIDTH - 1:0] ram [DEPTH - 1:0];
integer i;

always@(posedge clock or posedge reset) begin
	if(reset) begin
		for(i = 0; i < DEPTH; i = i + 1) begin
            ram[i] <= 'b0;
        end
	end
    else if(cen && wen) begin
        ram[addr] <= din;
    end
end

always@(posedge clock or posedge reset) begin
	if(reset) begin
		dout <= 'b0;
	end
    else if(cen && !wen) begin
        dout <= ram[addr];
    end
end

endmodule
