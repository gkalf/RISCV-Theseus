module MUX_2_1
#(parameter SIZE=32)
(
	a,
	b,
	choose_wisely,
	c
);

input [SIZE-1:0] a,b;
input choose_wisely;
output wire [SIZE-1:0] c;


assign c = (choose_wisely)?a:b;

endmodule
