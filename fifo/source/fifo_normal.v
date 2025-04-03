module    fifo_normal
#(
    parameter   DATA_WIDTH = 8,
    parameter   DEPTH = 16 
)
(
    input                           clock,
    input                           reset,

    input                           wen, 
    input       [DATA_WIDTH - 1:0]  wdata,
    output                          full,
    
    input                           ren,
    output  reg [DATA_WIDTH - 1:0]  rdata,
    output                          empty
);                                                                     

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [DATA_WIDTH - 1:0] buffer [DEPTH - 1 : 0];    
reg [ADDR_WIDTH :0] wrPtr;
reg [ADDR_WIDTH :0] rdPtr;

wire [ADDR_WIDTH - 1:0] wrPtr_true;
wire [ADDR_WIDTH - 1:0] rdPtr_true;
wire wrPtr_msb;
wire rdPtr_msb;
 
assign {wrPtr_msb, wrPtr_true} = wrPtr;
assign {rdPtr_msb, rdPtr_true} = rdPtr;

// read
always@(posedge clock or posedge reset) begin
    if(reset) begin
        rdPtr <= 'b0;
    end
    else if(ren && !empty) begin
        rdPtr <= rdPtr + 1'b1;
    end
end

always@(posedge clock or posedge reset) begin
    if(reset) begin
        rdata <= 'b0;
    end
    else if(ren) begin
        rdata <= buffer[rdPtr_true];
    end
end

// write
always@(posedge clock or posedge reset) begin
    if (reset) begin
        wrPtr <= 'b0;
    end
    else if (wen && !full) begin
        wrPtr <= wrPtr + 1'd1;
        buffer[wrPtr_true] <= wdata;
    end    
end

assign empty = wrPtr == rdPtr;
assign full = wrPtr_msb != rdPtr_msb && wrPtr_true == rdPtr_true;
 
endmodule
