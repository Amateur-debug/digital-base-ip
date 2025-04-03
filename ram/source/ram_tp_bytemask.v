module ram_tp_bytemask
#(
    parameter   DATA_WIDTH = 32,
    parameter   ADDR_WIDTH = 5,
    parameter   BWEN_WIDTH = DATA_WIDTH / 8
)
(
    input                           clock   ,
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

always@(posedge clock) begin
    if(cen && wen) begin
        ram[waddr] <= (wdata & {8{bwen}}) | (ram[waddr] & ~{8{bwen}});
    end
end

always@(posedge clock) begin
    if(cen && ren) begin
        rdata <= ram[raddr];
    end
end

endmodule
