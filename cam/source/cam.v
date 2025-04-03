// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Content Addressable Memory
 */
module cam #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 5,
    parameter SLICE_WIDTH = 9,
    parameter DEPTH = 2 ** ADDR_WIDTH
)
(
    input  wire                     clock,
    input  wire                     reset,

    input  wire                     wen,
    input  wire [ADDR_WIDTH-1:0]    waddr,
    input  wire [DATA_WIDTH-1:0]    wdata,
    input  wire                     delete,
    output wire                     wready,

    input  wire [DATA_WIDTH-1:0]    compare_data,
    output wire [ADDR_WIDTH-1:0]    match_addr,
    output wire                     match
);

// total number of slices (enough to cover DATA_WIDTH with address inputs)
localparam SLICE_COUNT = (DATA_WIDTH + SLICE_WIDTH - 1) / SLICE_WIDTH;

// state
localparam [1:0] STATE_INIT = 'd0;
localparam [1:0] STATE_IDLE = 'd1;
localparam [1:0] STATE_DELETE = 'd2;
localparam [1:0] STATE_WRITE = 'd3;

wire [1:0] state;
reg [1:0] state_next;

wire state_init = state == STATE_INIT;
wire state_idle = state == STATE_IDLE;
wire state_delete = state == STATE_DELETE;
wire state_write = state == STATE_WRITE;

dff_ar #(2) state_reg (.clock(clock), .reset(reset), .d(state_next), .q(state));

// init
wire [SLICE_WIDTH-1:0] init_count;
wire [SLICE_WIDTH-1:0] init_count_next;

assign init_count_next = state_init ? init_count - 1 : init_count;

dff_ar #(SLICE_WIDTH, {SLICE_WIDTH{1'b1}}) init_count_reg (.clock(clock), .reset(reset), .d(init_count_next), .q(init_count));

// Register input waddr and wdata
wire [ADDR_WIDTH-1:0] waddr_d1;
wire [DATA_WIDTH-1:0] wdata_d1;
wire revise_info_reg_en = state_idle & (wen | delete);

dff_en #(ADDR_WIDTH + DATA_WIDTH) revise_info_reg (.clock(clock), .en(revise_info_reg_en), .d({waddr, wdata}), .q({waddr_d1, wdata_d1}));

// slice ram control
wire slice_ram_wen;
wire [DATA_WIDTH - 1:0] slice_ram_waddr;
wire [DEPTH-1:0] clear_bit;
wire [DEPTH-1:0] set_bit;

assign slice_ram_wen = state_init | state_delete | state_write;
assign slice_ram_waddr = state_init ? {SLICE_COUNT{init_count}} : 
                         state_idle & wen ? wdata : 
                         state_delete | state_write ? wdata_d1 : 'b0;
assign clear_bit = state_init ? {DEPTH{1'b1}} : 
                   state_delete ? 'b1 << waddr_d1 : 'b0;
assign set_bit = state_write ? 'b1 << waddr_d1 : 'b0;

// slice ram
wire [DEPTH-1:0] match_raw[SLICE_COUNT-1:0];

genvar slice_index;
generate
    for (slice_index = 0; slice_index < SLICE_COUNT; slice_index = slice_index + 1) begin : slice
        localparam CAM_ADDR_WIDTH = slice_index == SLICE_COUNT - 1 ? DATA_WIDTH - slice_index * SLICE_WIDTH : SLICE_WIDTH;

        wire [DEPTH-1:0] slice_ram_data;

        ram_dp #(
            .DATA_WIDTH(DEPTH),
            .ADDR_WIDTH(CAM_ADDR_WIDTH)
        )
        slice_ram_inst
        (
            .clock(clock),
            .cen(1'b1),
            .wen_a(1'b0),
            .addr_a(compare_data[slice_index * SLICE_WIDTH +: CAM_ADDR_WIDTH]),
            .din_a({DEPTH{1'b0}}),
            .dout_a(match_raw[slice_index]),
            .wen_b(slice_ram_wen),
            .addr_b(slice_ram_waddr[slice_index * SLICE_WIDTH +: CAM_ADDR_WIDTH]),
            .din_b((slice_ram_data & ~clear_bit) | set_bit),
            .dout_b(slice_ram_data)
        );

    end
endgenerate

// compare
reg [DEPTH-1:0] match_many_raw;

integer i;
always @(*) begin
    match_many_raw = {DEPTH{1'b1}};
    for (i = 0; i < SLICE_COUNT; i = i + 1) begin
        match_many_raw = match_many_raw & match_raw[i];
    end
end

priority_encoder #(DEPTH) 
priority_encoder_inst(
    .unencoded(match_many_raw),
    .valid(match),
    .encoded(match_addr)
);

// output
assign wready = state_idle;

// state transition
always @(*) begin
    case (state)
        STATE_INIT: begin
            state_next = init_count == 0 ? STATE_IDLE : STATE_INIT;
        end
        STATE_IDLE: begin
            state_next = delete ? STATE_DELETE : 
                         wen ? STATE_WRITE : STATE_IDLE;
        end
        STATE_DELETE: begin
            state_next = STATE_IDLE;
        end
        STATE_WRITE: begin
            state_next = STATE_IDLE;
        end
    endcase
end


endmodule
