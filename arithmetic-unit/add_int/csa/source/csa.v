module csa(

    input	a   ,
    input   b   ,
    input   cin	,
    output  cout,
    output  s
);

assign s = a ^ b ^ cin;
assign cout = a & b | b & cin | a & cin;

endmodule
