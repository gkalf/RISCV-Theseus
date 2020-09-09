module TOP
(
	clk,
	reset,
	data_out,
	rom_address,misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval
);

input clk;
input reset;
output wire [31:0] data_out,rom_address;
output wire [31:0] misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval;



wire [31:0] load_instruction,address,data;
wire MEM_write,stall_j;
wire [2:0] byte_sel_mem;
CPU #(32) CPU_inst
(
	.clk(clk),
	.reset(reset),
	.instruction(load_instruction),
	.new_PC(rom_address),
	.MEM_write(MEM_write),
	.byte_sel_mem(byte_sel_mem),
	.data_out(data_out),
	.data(data),
	.address(address),
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


Dual_Port_Mem #(32,12) RAM
(
	.clk(clk),
	.funct3(byte_sel_mem),
	.address(address[13:0]),
	.w_data(data),
	.MEM_write(MEM_write),
	.data_out(data_out),
	.addr(rom_address[13:2]),
	.q(load_instruction)
);

endmodule
