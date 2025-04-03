module ram_tp_bytemask_ar
#(
    parameter   DATA_WIDTH = 32,
    parameter   ADDR_WIDTH = 5,
    parameter   BWEN_WIDTH = DATA_WIDTH / 8
)
(
    input                           clock   ,
    input                           reset   ,
    input                           cen     ,
    
    input                           wen     ,
    input       [BWEN_WIDTH - 1:0]  bwen    ,
    input       [ADDR_WIDTH - 1:0]  waddr   ,
    input       [DATA_WIDTH - 1:0]  wdata   ,
    input                           ren     ,
    input       [ADDR_WIDTH - 1:0]  raddr   ,
    output reg  [DATA_WIDTH - 1:0]  rdata   
);

localparam  DEPTH = 2 ** ADDR_WIDTH;

reg [DATA_WIDTH - 1:0] ram [DEPTH - 1:0];

integer i;
always@(posedge clock or posedge reset) begin
    if(reset) begin
        for(i = 0; i < DEPTH; i = i + 1) begin
            ram[i] <= 'b0;
        end
    end
    else if(cen && wen) begin
        ram[waddr] <= (wdata & {8{bwen}}) | (ram[waddr] & ~{8{bwen}});
    end
end

always@(posedge clock or posedge reset) begin
    if(reset) begin
        rdata <= 'b0;
    end
    else if(cen && ren) begin
        rdata <= ram[raddr];
    end
end

endmodule
