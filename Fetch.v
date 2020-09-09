module Fetch
#(parameter SIZE=32)
(
	clk,
	reset,
	next_PC,
	stall,
	stall_j,
	new_PC,
	PC,
	next_stall_PC,
	misaligned_jump_exception,
	misaligned_ldst_exception,
	mtvec_address,
	prediction_address,
	prediction_propagate
);

	input							clk;
	input							reset;

	input 	  [SIZE-1:0]   next_PC;
	input 	  [SIZE-1:0]	next_stall_PC;
	input							stall;
	input							stall_j;
	input							misaligned_jump_exception;
	input 						misaligned_ldst_exception;
	input			[SIZE-1:0]	mtvec_address;
	input			[SIZE-1:0]	prediction_address;
	input 						prediction_propagate;

	output reg [SIZE-1:0] 		new_PC;
	output reg [SIZE-1:0]    	PC;
	

	always @(posedge clk)
	begin
		PC <= new_PC  ;
		if (reset == 1)
			new_PC <= 0;
		else if (misaligned_jump_exception | misaligned_ldst_exception)
			new_PC <= mtvec_address;
		else if (stall)  
			new_PC <= PC;
		else if (stall_j ) 
			new_PC <= next_PC;
		else if (prediction_propagate)
			new_PC <= prediction_address;
		else 
			new_PC <= new_PC+4;
	end	

	
endmodule
