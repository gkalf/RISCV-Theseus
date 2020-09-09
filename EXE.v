module EXE
#(parameter SIZE=32)
(
	clk,
	reset,
	control_registers,
	inputA_reg_file,
	inputB_reg_file,
	immidiate,
	PC_exec,
	PC_MEM,
	ALU_result,
	take_branch,
	rs2_store_data,
	rs2_store_data_MEM,
	immidiate_to_MEM,
	control_registers_MEM,
	control_registers_WB,
	ALU_result_to_WB,
	ALU_result_to_MEM,
	stall,
	misaligned_jump_exception,
	misaligned_ldst_exception,
	mtvec_address,
	jump_address,misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval
);


input 				clk;
input 				reset;
input [SIZE-1:0]	   control_registers;
input [SIZE-1:0]	inputA_reg_file;
input [SIZE-1:0]	inputB_reg_file;
input [SIZE-1:0]	immidiate;
input [SIZE-1:0]	PC_exec;
input [SIZE-1:0]	rs2_store_data;
input [9:0]	   	control_registers_WB;
input [SIZE-1:0]	ALU_result_to_WB;
input [SIZE-1:0]	ALU_result_to_MEM;
input					stall;
input 				misaligned_jump_exception;
input					misaligned_ldst_exception;
input [SIZE-1:0]	jump_address;

output reg [13:0] 	   control_registers_MEM;
output reg [SIZE-1:0]	rs2_store_data_MEM;
output reg [SIZE-1:0] 	immidiate_to_MEM;
output reg [SIZE-1:0]	PC_MEM;
output reg [SIZE-1:0] 	ALU_result;
output reg					take_branch;
output wire [SIZE-1:0] 	mtvec_address;

output [SIZE-1:0] misa,mtvec,mvendorid,marchid,mimpid,mhartid,mepc,mcause,mtval;

wire [4:0] rs1_tmp = control_registers[27:23];
wire [4:0] rs2_tmp = control_registers[22:18];
wire [4:0] rd5 	= control_registers_WB[6:2];
wire [4:0] rd4 	= control_registers_MEM[9:5];
wire       rd4_en = control_registers_MEM[3];
wire 		  rd5_en = control_registers_WB[1];
reg [31:0] inputA_reg, inputB_reg, inputB_to_store;

reg [31:0] mvendorid;//f11_read_only
reg [31:0] marchid;//f12
reg [31:0] mimpid; //13
reg [31:0] mhartid;//14

reg [31:0] mstatus;//300
reg [31:0] misa;
reg [31:0] medeleg;
reg [31:0] mideleg;
reg [31:0] mie;
reg [31:0] mtvec;
reg [31:0] mcounteren;

reg [31:0] mscratch;//340
reg [31:0] mepc;
reg [31:0] mcause;
reg [31:0] mtval;
reg [31:0] mip;

reg [31:0] cycle; //c00
reg [31:0] mcycle;//B00

reg [31:0] instret;//c02
reg [31:0] minster;//b02
reg [31:0] hpmcounter3;//c03
reg [31:0] mhpmcounter3;//b03
reg [31:0] hpmcounter4; //c04
reg [31:0] mhpmcounter4;//b04

reg [31:0] mcycleh;//b80;
reg [31:0] minstreth;//b81;
reg [31:0] mhpmcounter3h;//b83
reg [31:0] mhpmcounter4h;//b84
reg [31:0] csr_write;

assign mtvec_address = {mtvec[31:2],2'b00};
		//forward data to rs2_data 3rd stage
		//add r2,rx,rx
		//sw  r2,0
always @(*) //forward unit
begin
		if ((rd4_en | rd5_en))
		begin
			if ((rs2_tmp == rd4) & (rs2_tmp == rd5) & rd4_en & rd5_en & (rs2_tmp != 0))
				inputB_to_store = ALU_result_to_MEM;
			else if ((rs2_tmp == rd4) & (rs2_tmp != 0) & rd4_en)
				inputB_to_store = ALU_result_to_MEM;
			else if ((rs2_tmp == rd5) & (rs2_tmp != 0)  & rd5_en)
				inputB_to_store = ALU_result_to_WB;
			else
				inputB_to_store = rs2_store_data;
			
		end else
			inputB_to_store = rs2_store_data;
		
		//forward from 4th and 5th stage
		if ((rd4_en | rd5_en))
		begin
			if ((rs1_tmp == rd4) & (rs1_tmp == rd5) & rd4_en & rd5_en & (rs1_tmp != 0))
				inputA_reg = ALU_result_to_MEM;
			else if ((rs1_tmp == rd4) & (rs1_tmp != 0)  & rd4_en)
				inputA_reg = ALU_result_to_MEM;
			else if ((rs1_tmp == rd5) & (rs1_tmp != 0) & rd5_en)
				inputA_reg = ALU_result_to_WB;
			else
				inputA_reg = inputA_reg_file;
			
			if ((rs2_tmp == rd4) & (rs2_tmp == rd5) & rd4_en & rd5_en & (rs2_tmp != 0))
				inputB_reg = ALU_result_to_MEM;
			else if ((rs2_tmp == rd4) & (rs2_tmp != 0) & rd4_en)
				inputB_reg = ALU_result_to_MEM;
			else if ((rs2_tmp == rd5) & (rs2_tmp != 0)  & rd5_en)
				inputB_reg = ALU_result_to_WB;
			else
				inputB_reg = inputB_reg_file;
			
		end else begin
			inputA_reg = inputA_reg_file;
			inputB_reg = inputB_reg_file;
		end
	
end

wire [1:0] ALU_A_src = control_registers[29:28];
wire       ALU_B_src = control_registers[30];

reg  [31:0] inputA,inputB;


//ALU_Source
always @(*)
begin
	
	inputA=0;
	if (ALU_A_src == 2'd0)
		inputA = inputA_reg;
	else if (ALU_A_src == 2'd1)
		inputA = PC_exec;
	else if (ALU_A_src == 2'd2)
		inputA = 0;
	
	inputB=0;
	if (ALU_B_src == 1'd0)
		inputB = inputB_reg;
	else if (ALU_B_src == 1'd1)
		inputB = immidiate;

end

wire 	ALU_code_3 = control_registers[16];
wire 	[2:0] ALU_code_2_0 = control_registers[15:13]; 
wire 	ALU_code_4 = control_registers[17];
reg 	[31:0] csr_val;

wire 	signed [31:0] B = inputB;
wire 	signed [31:0] A = inputA;

wire  [31:0]  B_uint = inputB;
wire  [31:0]  A_uint = inputA;
reg   [31:0] inputB2;
reg   [31:0] sum,result;
reg branch;


always @(*)
begin
			branch = 0;
			result = 0;
			sum = 0;
			if( ALU_code_3 == 1 )
				inputB2 = ~(inputB);
			else
				inputB2 = inputB;

			 sum = inputA + inputB2 + {30'b0,ALU_code_3};

			if ({ALU_code_4,ALU_code_2_0} == 4'd8)begin//return exception_handler;
					result = {mepc[31:2],2'b00};
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd15)begin//CSRRCI
					result=csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd14)begin// CSRRSI
					result=csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd13)begin	//CSRRWI
					result= csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd11)begin //CSRRC
					result = csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd10)begin	//CSRRS
					result = csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd9)begin	//CSRRW
					result = csr_val;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd7)begin 
					result = A & B;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd6)begin
					result = A | B;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd5)begin 
					if (ALU_code_3)
						result = A >>> B_uint[4:0]; //add sra
					else
						result = A_uint >> B_uint[4:0];
					
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd4)begin 
					result = A ^ B;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd3)begin 
					result = (A_uint<B_uint)?1:0; //to be done
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd2)begin 
					result = (A<B)?1:0;
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd1)begin
					result = A_uint << B_uint[4:0];
			end else if ({ALU_code_4,ALU_code_2_0} == 4'd0)begin
					result = sum;
			end 

			//calculate branch;
			if (ALU_code_2_0 == 3'd0) begin
					branch = (A == B)?1'd1:1'd0;
			end else if (ALU_code_2_0 == 3'd1) begin
					branch = (A != B)?1'd1:1'd0;
			end else if (ALU_code_2_0 == 3'd4) begin//blt
					branch = (A<B)?1'd1:1'd0;
			end else if (ALU_code_2_0 == 3'd5) begin //bge
					branch = (A>=B)?1'd1:1'd0;
			end else if (ALU_code_2_0 == 3'd6) begin
					branch = (A_uint<B_uint)?1'd1:1'd0;
			end else if (ALU_code_2_0 == 3'd7) begin
					branch = (A_uint>=B_uint)?1'd1:1'd0;
			end

end



always @(posedge clk)
begin
	if (reset | stall)
		begin
			take_branch				<= 0;
			ALU_result   			<= 0;
			immidiate_to_MEM 		<= 0;
			rs2_store_data_MEM 	<= 0;
			PC_MEM 					<= 0;
			control_registers_MEM<= 0;
		end
	else
		begin
			control_registers_MEM<= {control_registers[31],control_registers[12:0]};
			take_branch 			<= branch;
			ALU_result 				<= result;
			immidiate_to_MEM 		<= immidiate;
			rs2_store_data_MEM 	<= inputB_to_store;
			PC_MEM 					<= PC_exec;
		end			
end
//jump_r |funct3 | rd | Branch | Wr_to_RF | MEM_write | WB_select | jump 
//   1   |    3  |  5 |    1   |     1    |     1     |      1    |   1


always @(*)
begin
	case(inputB[11:0])
			12'h300:
				csr_val <= mstatus;
			12'h301:
				csr_val <=misa;
			12'h302: 
				csr_val <= medeleg;
			12'h303:
				csr_val <= mideleg;
			12'h304:
				csr_val <= mie;
			12'h305:
				csr_val <= mtvec;
			12'hF11://mvendor;
				csr_val <= mvendorid;
			12'hf12:
				csr_val <= marchid;
			12'hf13:
				csr_val <= mimpid;
			12'hf14:
				csr_val <= mhartid;
			12'h340:
				csr_val <= mscratch;
			12'h341:
				csr_val <= mepc;
			12'h342:
				csr_val <= mcause;
			12'h343://mtval = 0 <= csr_val
				csr_val <= mtval;
			12'h344:
				csr_val <= mip;
		default:
			csr_val = 0;
	endcase
end


always @(*)
begin
	csr_write = 0;
	if ({ALU_code_4,ALU_code_2_0} == 15)begin//CSRRCI
			csr_write = ~{27'd0,rs1_tmp} & (csr_val); 
	end else if ({ALU_code_4,ALU_code_2_0} == 14)begin// CSRRSI
			csr_write = {27'd0,rs1_tmp} | csr_val;
	end else if ({ALU_code_4,ALU_code_2_0} == 13)begin	//CSRRWI;
			csr_write = {27'd0,rs1_tmp};
	end else if ({ALU_code_4,ALU_code_2_0} == 11)begin //CSRRC
			csr_write = ~inputA & (csr_val);
	end else if ({ALU_code_4,ALU_code_2_0} == 10)begin	//CSRRS
			csr_write = inputA | csr_val;
	end else if ({ALU_code_4,ALU_code_2_0} == 9)begin	//CSRRW
			csr_write = inputA;
	end
end



always @(posedge clk)
begin
	if (reset == 1)
	begin
		mvendorid <= 0;//f11_read_only
		marchid <= 0;//f12
		mimpid <= 0; //13
		mhartid <= 0;//14

		mstatus <= 0;//300
		misa<= 0;
		medeleg <= 0;
		mideleg <= 0;
		mie <= 0;
		mtvec <= 0;
		mcounteren <= 0;

		mscratch <= 0;//340
		mepc<= 0;
		mcause<= 0;
		mtval<= 0;
		mip<= 0;

	end else if (stall == 1'b1) begin
		mvendorid 	<= mvendorid;//f11_read_only
		marchid 		<= marchid;//f12
		mimpid 		<= mimpid; //13
		mhartid 		<= mhartid;//14

		mstatus		<= mstatus;//300
		misa			<= misa;
		medeleg 		<= medeleg;
		mideleg 		<= mideleg;
		mie 			<= mie;
		mtvec 		<= mtvec;
		mcounteren	<= mcounteren;

		mscratch 	<= mscratch;//340
		mepc			<= mepc;
		mcause		<= mcause;
		mtval			<= mtval;
		mip			<= mip;

	end else begin
		case(inputB[11:0])
			12'h300:
				mstatus <= csr_write;
			12'h301:
				misa <= 0;
			12'h302: 
				medeleg <=csr_write;
			12'h303:
				mideleg <= csr_write;
			12'h304:
				mie <= csr_write;
			12'h305:
				mtvec <= csr_write;
			12'hF11://mvendor;
				mvendorid <= 0;
			12'hf12:
				marchid <= 0;
			12'hf13:
				mimpid <= 0;
			12'hf14:
				mhartid <= 0;
			12'h340:
				mscratch <= csr_write;
			12'h341:
				mepc <= {csr_write[31:2],2'b00};
			12'h342:
				mcause <= csr_write;
			12'h343://mtval = 0 <= csr_write
				mtval <= csr_write;
			12'h344:
				mip <=0;			
	endcase
	end
	if (misaligned_jump_exception)
		begin
			mtval <= jump_address;
			mepc  <= PC_MEM;
		end
		
	if (misaligned_ldst_exception)
		begin
			mtval <= {29'd0,ALU_result_to_MEM[1:0]};
			mepc  <= PC_MEM;
			
			if (control_registers_MEM[2]) //if caused by store
				mcause<={1'b0,30'd6};
			else if (control_registers_MEM[1]) //if caused by load
				mcause<={1'b0,30'd4};
			else 
				mcause<=0;
		end
end
endmodule




