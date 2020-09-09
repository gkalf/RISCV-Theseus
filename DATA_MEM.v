module DATA_MEM
#(parameter SIZE=32)
(
	clk,
	reset ,
	addr ,
	control_registers ,
	PC_from_rs2_data_to_Store ,
	ALU_result_to_WB ,
	control_registers_WB ,
	jump_address ,
	stall_j ,
	take_branch ,
	PC_MEM ,
	immidiate_to_MEM,
	misaligned_jump_exception,
	misaligned_ldst_exception,
	prediction,
	branch_taken
);

	input 					clk;
	input 					reset;
	input [31:0] 			addr;
	input [13:0] 		   control_registers;
	input [31:0] 			PC_from_rs2_data_to_Store;
	input 					take_branch;
	input [31:0] 			PC_MEM;
	input [31:0] 			immidiate_to_MEM;
	input 					prediction;
	
	output reg [31:0] 	ALU_result_to_WB;
	output reg [9:0]   	control_registers_WB;
	output reg [31:0] 	jump_address;
	output reg 				stall_j;
	output reg 				misaligned_jump_exception;
	output reg				misaligned_ldst_exception;
	output reg 				branch_taken;
	
wire [2:0] 	funct3 = control_registers[12:10];
wire 			MEM_write = control_registers[2];
wire 			WB_select = control_registers[1];
wire			Wr_to_Rf = control_registers[3];
	
always @(posedge clk)
begin
	if (reset  == 1) begin
		ALU_result_to_WB 		<= 31'd0;
		control_registers_WB <= 10'd0;
	 end else begin
			control_registers_WB <= {control_registers[12:5],control_registers[3],control_registers[1]};
		
		if (control_registers [0] | (control_registers [13])) begin
			ALU_result_to_WB <= PC_from_rs2_data_to_Store ;
		 end else begin
			ALU_result_to_WB <= addr ;
		 end 
	 end 	
end
//funct3 | rd | Wr_to_RF | WB_select 
//    3  |  5 |     1    |     1    


always @(*)
begin

	if (control_registers[0]) begin
			jump_address = immidiate_to_MEM  + PC_MEM ;
			misaligned_ldst_exception = 1'b0;
			stall_j = (prediction)?1'b0:1'b1;
			branch_taken = 1'b1;
	end else if (control_registers[13]) begin
			jump_address = {addr[31:1],1'b0};
			misaligned_ldst_exception = 1'b0;			
			stall_j = (prediction)?1'b0:1'b1;
			branch_taken = (Wr_to_Rf)?1'b1:1'b0;
	end else if (control_registers[4] & take_branch) begin
			jump_address = PC_MEM + immidiate_to_MEM;
			stall_j = (prediction)?1'b0:1'b1;
			misaligned_ldst_exception = 1'b0;
			branch_taken = 1'b1;
	end else if (control_registers[4] & !take_branch) begin
			jump_address = PC_MEM + 4;
			stall_j = (prediction)?1'b1:1'b0;
			misaligned_ldst_exception = 1'b0;
			branch_taken = 1'b0;
	end else if ((addr[1:0] != 2'b00) & (funct3[2:0] == 3'b010) & (MEM_write | WB_select)) begin
			misaligned_ldst_exception = 1'b1;
			stall_j = 1;
			jump_address = 0;
			branch_taken = 1'b0;
	end else if ((addr[0] == 1'b1) & (funct3[1:0] == 2'b01) & (MEM_write | WB_select)) begin
			misaligned_ldst_exception = 1'b1;
			stall_j = 1;
			jump_address = 0;
			branch_taken = 1'b0;
	end else begin
			stall_j = 0;
			misaligned_ldst_exception = 1'b0; 
			jump_address = 0;
			branch_taken = 1'b0;
	end 
	
	if (jump_address[1:0] != 2'b00)
		misaligned_jump_exception = 1'b1;
	else
		misaligned_jump_exception = 1'b0;
		
		
end

endmodule
