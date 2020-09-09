module sign_extend
#(parameter SIZE = 32,
  parameter Position_of_sign = 12)
(
	sign_extend,
	enable,
	sign_extended
);

input enable;
input [SIZE-1:0] sign_extend;
output reg [SIZE-1:0] sign_extended;

wire [31:0] temp= {{(SIZE-Position_of_sign){sign_extend[Position_of_sign-1]}},sign_extend[Position_of_sign-1:0]};


always @*
begin
	if (enable)
		begin
			if 	(sign_extend[Position_of_sign-1] == 1'b1)
				sign_extended = temp;
			else
				sign_extended = sign_extend;
		end
	else begin
		sign_extended = sign_extend;

	end
end

endmodule
