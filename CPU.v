module CPU
#(parameter SIZE=32)
(
	clk,
	reset,
	instruction,
	new_PC,
	MEM_write,
	byte_sel_mem,
	data_out,
	data,
	address,misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval
);

input clk;
input reset;
input [SIZE-1:0] instruction;
output[SIZE-1:0]  new_PC;
output wire [SIZE-1:0] address;
output wire [SIZE-1:0] data;
output reg MEM_write;
output wire [2:0] byte_sel_mem;
output wire [SIZE-1:0] misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval;
input [SIZE-1:0] data_out;

reg WB_5,Wr_to_RF_5;
reg [4:0] rd5;
reg [2:0] funct3_4,funct3_5;
reg [SIZE-1:0] load_instruction;
wire [SIZE-1:0] control_registers;
wire [9:0]      control_registers_WB;
wire [13:0] 	 control_registers_MEM;
wire [SIZE-1:0] rom_address, jump_address,new_PC,PC,rd_data,ALU_result_to_WB,ALU_result_to_MEM,rs2_store_data_MEM, ALU_result,PC_exec,immidiate,inputA_reg_file,inputB_reg_file,rs2_store_data,PC_MEM, immidiate_to_MEM;
wire stall,take_branch;
wire stall_j;
reg stall_j_reg,stall_reg;
wire [SIZE-1:0] mtvec_address;
wire misaligned_jump_exception;
wire misaligned_ldst_exception;
wire prediction;
wire branch_taken;
wire prediction_propagate;
always @(*)
begin
	if (misaligned_ldst_exception) begin
		MEM_write <= 0;
	end else begin
		MEM_write <= control_registers_MEM[2];
	end
	
	funct3_4   <= control_registers_MEM[12:10];
	WB_5       <= control_registers_WB[0];
	funct3_5   <= control_registers_WB[9:7];
	rd5		  <= control_registers_WB[6:2];
	Wr_to_RF_5 <= control_registers_WB[1];
	if (reset) begin
		load_instruction <= 0;
	end else if (stall_j_reg ) begin
		load_instruction <= 0;
	end else if (stall_reg) begin
		load_instruction <= 0;
	end else begin
		load_instruction <= instruction;
	end
end


always @(posedge clk)
begin
	if ((stall_j==1'b1))
		stall_j_reg <= 1'b1;
	else if (stall == 1'b1)
		stall_reg <= 1'b1;
	else
		begin
		stall_reg <= 0;
		stall_j_reg <= 0;
		end
end

assign byte_sel_mem = funct3_4;
assign address = ALU_result;
assign data    = rs2_store_data_MEM;

Fetch #(32) Fetch_inst
(
	.clk(clk),
	.reset(reset),
	.next_PC(jump_address),
	.stall(stall),
	.stall_j(stall_j),
	.new_PC(new_PC),
	.PC(PC),
	.next_stall_PC(PC),
	.misaligned_jump_exception(misaligned_jump_exception),
	.misaligned_ldst_exception(misaligned_ldst_exception),
	.mtvec_address(mtvec_address),
	.prediction_address(rom_address),
	.prediction_propagate(prediction_propagate)
);

Branch_Prediction_Unit #(32,7) Branch_Prediction_Unit_inst
(
	.clk(clk),
	.reset(reset),
	.new_PC(new_PC),
	.control_registers_MEM(control_registers_MEM),
	.PC_MEM(PC_MEM),
	.jump_address(jump_address),
	.branch_taken(branch_taken),
	.rom_address(rom_address),
	.prediction(prediction),
	.prediction_propagate(prediction_propagate)
);

Decoder #(32) Decoder_inst
(
	.clk(clk),
	.reset(reset),
	.instruction(load_instruction),
	.PC_dec(rom_address),
	.rd_en(Wr_to_RF_5),//dfsfsd
	.rd_data(rd_data),
	.rd_address(rd5),//dsadsadsa
	.stall_j(stall_j),
	.PC(PC),

	.control_registers(control_registers),
	.PC_exec(PC_exec),
	.immidiate_sign_extended(immidiate),
	.inputA_reg_file(inputA_reg_file),
	.inputB_reg_file(inputB_reg_file),
	.rs2_store_data(rs2_store_data),
	.stall(stall)
);

EXE	#(32) EXE_inst
(
	.clk(clk),
	.reset(reset),
	.control_registers(control_registers),
	.inputA_reg_file(inputA_reg_file),
	.inputB_reg_file(inputB_reg_file),
	.immidiate(immidiate),
	.PC_exec(PC_exec),
	.PC_MEM(PC_MEM),
	.ALU_result(ALU_result),
	.take_branch(take_branch),
	.rs2_store_data(rs2_store_data),
	.rs2_store_data_MEM(rs2_store_data_MEM),
	.immidiate_to_MEM(immidiate_to_MEM),
	.control_registers_MEM(control_registers_MEM),
	.control_registers_WB(control_registers_WB),
	.ALU_result_to_WB(ALU_result_to_WB),
	.ALU_result_to_MEM(ALU_result),
	.stall(stall_j),
	.misaligned_jump_exception(misaligned_jump_exception),
	.misaligned_ldst_exception(misaligned_ldst_exception),
	.mtvec_address(mtvec_address),
	.jump_address(jump_address),
	.misa(misa),
	.mtvec(mtvec),
	.mvendorid(mvendorid),
	.marchid(marchid),
	.mimpid(mimpid),
	.mhartid(mhartid),
	.mepc(mepc),
	.mcause(mcause),
	.mtval(mtval)
);

DATA_MEM #(32) DATA_MEM_inst
(
	.clk(clk),
	.reset(reset),
	.addr(ALU_result),
	.control_registers(control_registers_MEM),
	.PC_from_rs2_data_to_Store(rs2_store_data_MEM),
	.ALU_result_to_WB(ALU_result_to_WB),
	.control_registers_WB(control_registers_WB),
	.jump_address(jump_address),
	.stall_j(stall_j),
	.take_branch(take_branch),
	.PC_MEM(PC_MEM),
	.immidiate_to_MEM(immidiate_to_MEM),
	.misaligned_jump_exception(misaligned_jump_exception),
	.misaligned_ldst_exception(misaligned_ldst_exception),
	.prediction(prediction),
	.branch_taken(branch_taken)
);
		 
WB	#(32) WB_inst
(
	.WB_select(WB_5),
	.r_data(data_out),
	.ALU_result(ALU_result_to_WB),
	.funct3(funct3_5),
	.rd_data(rd_data)
);

endmodule
