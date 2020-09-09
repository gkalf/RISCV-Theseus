module MUX_4_1
#(parameter SIZE=32)
(
	input [SIZE-1:0] a,
	input [SIZE-1:0] b,
	input [SIZE-1:0] c,
	input [SIZE-1:0] d,
	input [1:0] choose_wisely,
	output reg [SIZE-1:0] out
);



always @*
begin
	out = 0;
	if (choose_wisely==2'b00)
		out = a;
	else if (choose_wisely==2'b01)
		out = b;
	else if (choose_wisely==2'b10)
		out = c;
	else if (choose_wisely==2'b11)
		out = d;
end

endmodule


