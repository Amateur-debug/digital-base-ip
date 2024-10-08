`timescale  1ns/1ns
module  tb_div_int32();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//


//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//wire  define
wire 		valid_out;
wire [31:0] quotient ;
wire [31:0] remainder;

//reg   define
reg 	   clock    ;
reg 	   reset    ;					 
reg 	   valid_in ;
reg  	   opcode   ;
reg [31:0] dividend ;
reg [31:0] divisor  ;

//initialize clock
initial begin
    clock   = 1'b0;
end
always  #10 clock = ~clock;

//initialize motivation
initial begin
	reset = 1'b1;					 
	valid_in = 'b0;
	opcode = 'b0;
	#20;
	opcode = 'b0;
	reset = 1'b0;
end

always@(posedge clock) begin
	if(valid_out || $time > 20 && $time < 40) begin
		valid_in <= 'b1;
		dividend <= $random;
		divisor <= $random;
	end
	else begin
		valid_in <= 'b0;
	end
end

//self-check
wire [31:0] quotient_ref;
wire [31:0] remainder_ref;
wire ok;

/*
//sign
assign quotient_ref = $signed(dividend) / $signed(divisor);
assign remainder_ref = $signed(dividend) - $signed(quotient_ref) * $signed(divisor);
assign ok = quotient_ref == quotient && remainder_ref == remainder;
*/

//unsign
assign quotient_ref = dividend / divisor;
assign remainder_ref = dividend - quotient_ref * divisor;
assign ok = quotient_ref == quotient && remainder_ref == remainder;


//simulation finish
always @(posedge clock) begin
	if (!ok && valid_out) begin
		$display("Error: dividend = %h, divisor = %h, quotient = %h, remainder = %h, quotient_ref = %h, remainder_ref = %h", 
				 dividend, divisor, quotient, remainder, quotient_ref, remainder_ref);
		$finish;
	end
end

always begin
    #100;
    if ($time >= 10000) begin
        $finish ;
    end
end
//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
div_int u_div_int(

    .clock    (clock    ),
	.reset    (reset    ),					 
    .valid_in (valid_in ),
    .opcode   (opcode   ),
    .dividend (dividend ),
    .divisor  (divisor  ),		    
    .valid_out(valid_out),
    .quotient (quotient ),
    .remainder(remainder)
);


endmodule
