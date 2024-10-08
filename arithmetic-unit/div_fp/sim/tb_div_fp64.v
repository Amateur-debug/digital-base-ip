`timescale  1ns/1ns
module  tb_div_fp64();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//


//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//wire  define
wire 		valid_out;
wire [63:0] quotient ;
wire 		nv		 ;
wire 		dz		 ;
wire 		of		 ;
wire 		uf		 ;
wire 		nx		 ;

//reg   define
reg 	   clock    ;
reg 	   reset    ;					 
reg 	   valid_in ;
reg [2 :0] rm		;
reg [63:0] dividend ;
reg [63:0] divisor  ;

//initialize clock
initial begin
    clock   = 1'b0;
end
always  #10 clock = ~clock;

//initialize motivation
initial begin
	reset = 1'b1;					 
	valid_in = 'b0;
	rm = 'b0;
	#20;
	reset = 1'b0;
end

always@(posedge clock) begin
	if(valid_out || $time > 20 && $time < 40) begin
		valid_in <= 'b1;
		dividend <= {$random, $random};
		divisor <= {$random, $random};
	end
	else begin
		valid_in <= 'b0;
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
div_fp64 u_div_fp64(

    .clock    (clock    ),
	.reset    (reset    ),					 
    .valid_in (valid_in ),
    .rm       (rm       ),
    .dividend (dividend ),
    .divisor  (divisor  ),		    
    .valid_out(valid_out),
    .quotient (quotient ),
	.nv	      (nv	    ),
	.dz	      (dz	    ),
	.of		  (of		),
	.uf	      (uf	    ),
	.nx		  (nx		)
);


endmodule
