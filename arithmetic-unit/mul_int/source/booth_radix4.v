module booth_radix4
#(
	parameter DATA_WIDTH = 32
)
(

    input		[2				:0]	y,
    input		[DATA_WIDTH - 1	:0]	x,

    output	reg	[DATA_WIDTH - 1	:0]	p,
    output	reg						c
);

wire	y2;
wire	y1;
wire	y0;
wire	sel_negative;
wire	sel_double_negative;
wire	sel_positive;
wire	sel_double_positive;

assign y2 = y[2:2];
assign y1 = y[1:1];
assign y0 = y[0:0];
assign sel_negative =  y2 & (y1 & ~y0 | ~y1 & y0);
assign sel_positive = ~y2 & (y1 & ~y0 | ~y1 & y0);
assign sel_double_negative =  y2 & ~y1 & ~y0;
assign sel_double_positive = ~y2 &  y1 &  y0;

always@(*) begin
    if(sel_negative == 1'b1) begin
        p = ~x;
        c = 1'b1;
    end
    else if(sel_positive == 1'b1) begin
        p = x;
        c = 1'b0;
    end
    else if(sel_double_negative == 1'b1) begin
        p = ~(x << 1);
        c = 1'b1;
    end
    else if(sel_double_positive == 1'b1) begin
        p = x << 1;
        c = 1'b0;
    end
    else begin
        p = 'b0;
        c = 1'b0;
    end
end

endmodule
