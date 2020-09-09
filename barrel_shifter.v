
module barrel_shifter
#(parameter SIZE=32)
(
	inA,
	inB,
	shift_arithmetic,
	result_R,
	result_L
);

input [SIZE-1:0] inA;
input [4:0] inB;
input shift_arithmetic;
output  [SIZE-1:0] result_R;
output  [SIZE-1:0] result_L;

integer i;
reg [2*SIZE-1:0] mask [0:SIZE];

wire sign = (shift_arithmetic & inA[31]);
wire [2*SIZE-1:0] produce_mask={{32{sign}},inA};

always @*
begin
	for (i=0; i<=SIZE; i=i+1)
	begin
		mask[i] = produce_mask<<i;
	end
end


assign result_L = mask[inB[4:0]][SIZE-1:0];
	
assign result_R = mask[7'd32-inB[4:0]][2*SIZE-1:SIZE];

endmodule
