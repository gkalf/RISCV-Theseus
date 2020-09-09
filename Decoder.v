module Decoder
#(parameter SIZE = 32)
(

	clk,
	reset,
	instruction,
	PC_dec,
	rd_en,
	rd_data,
	rd_address,
	stall_j,
	PC,

	control_registers,
	PC_exec,
	immidiate_sign_extended,
	inputA_reg_file,
	inputB_reg_file,
	rs2_store_data,
	stall

);

input									clk;
input									reset;
input		[SIZE-1:0]				instruction;
input		[SIZE-1:0]			 	PC_dec;
input		               	  	rd_en;
input 	[SIZE-1:0]			 	rd_data;
input		[4:0]				rd_address;
input									stall_j;
input		[SIZE-1:0]				PC;

output 	reg [SIZE-1:0]	  		control_registers;
output 	reg [SIZE-1:0]	  		PC_exec;
output	reg [SIZE-1:0]			immidiate_sign_extended;
output  	reg [SIZE-1:0]			inputA_reg_file;
output  	reg [SIZE-1:0]			inputB_reg_file;
output  	reg [SIZE-1:0]			rs2_store_data;
output	reg					stall;

reg [SIZE-1:0] Reg_file[0:SIZE-1];

wire [6:0]   opcode = instruction[6:0];
wire [4:0]   rs1_tmp= instruction[19:15];
wire [4:0]   rs2_tmp= instruction[24:20];		
wire [4:0]   rd     = instruction[11:7];
//R_type
wire [6:0]   funct7 = instruction[31:25];
wire [2:0]   funct3 = instruction[14:12];
//I_type
wire [31:0]  I_imm  = {{20{instruction[31]}},instruction[31:20]};
//S_type
wire [31:0]  S_imm  = {{20{instruction[31]}},instruction[31:25],instruction[11:7]};
//B_type
wire [31:0]  B_imm  = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
wire [31:0]  U_imm  = {instruction[31:12],12'd0};
wire [31:0]  J_imm  = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};

reg  [4:0] ALU_code;
reg	Wr_to_RF;
reg	jump;
reg	Branch;
reg	[1:0] ALU_A_src;
reg 	ALU_B_src;
reg	rs1_en;
reg	rs2_en;
reg	MEM_write;
reg	WB_select;
reg  [SIZE-1:0] imm_tmp;
reg 	jump_r;

always @(*)
begin
	ALU_code = 0;
	Wr_to_RF = 0;
	jump = 0;
	jump_r = 0;
	Branch = 0;
	Wr_to_RF = 0;
	ALU_A_src = 0;
	ALU_B_src = 0;
	rs1_en = 0;
	rs2_en = 0;
	MEM_write = 0;
	WB_select = 0;
	imm_tmp = 0;

	case(opcode)
	
		7'h37 : //lui
			begin
			ALU_A_src = 2;
			ALU_B_src = 1;
			Wr_to_RF = 1;
			imm_tmp = U_imm;
			end
		7'h17 : //auipc
			begin
			ALU_A_src = 1;
			ALU_B_src = 1;
			Wr_to_RF = 1;
			imm_tmp = U_imm;
			end
		7'h6f : // jump
			begin
			jump = 1;
			Wr_to_RF = 1;
			imm_tmp = J_imm;
			end
		7'h67 : //jalr
			begin
			Wr_to_RF = 1;
			jump_r = 1;
			rs1_en = 1;
			ALU_B_src = 1;
			imm_tmp = I_imm;
			end
		7'h63 : //branch
			begin
			Branch = 1;
			rs1_en = 1;
			rs2_en = 1;
			imm_tmp = B_imm;
			ALU_code = {2'b00, funct3};
			end
		7'h03 : //load immidiate
			begin
			ALU_B_src = 1;
			Wr_to_RF = 1;
			rs1_en = 1;
			WB_select = 1;
			imm_tmp = I_imm;
			end
		7'h23 : //store 
			begin
			ALU_B_src = 1;
			rs1_en = 1;
			rs2_en = 1;
			MEM_write = 1;
			imm_tmp = S_imm;
			end
		7'h13 : 
			begin
			ALU_B_src = 1;
			Wr_to_RF = 1;
			rs1_en = 1;
			imm_tmp = I_imm;
			if( (funct3  == 3'd2) | (funct3  == 3'd3) ) 
			begin
				ALU_code = {2'b01, funct3};
			end
			else
			begin
				if( funct3  == 3'd5 ) 
				begin
					ALU_code = {1'b0, funct7[5], funct3};
				end
				else
				begin
					ALU_code = {2'b0, funct3 };
				end
			end
			end
		7'h33 : 
			begin
			Wr_to_RF = 1;
			rs1_en = 1;
			rs2_en = 1;
			if( (funct3  == 3'd2) | (funct3  == 3'd3) ) 
				ALU_code = {2'b01, funct3 };
			else
				begin
					if( (funct3  == 3'd5) | (funct3  == 3'd0)) 
						ALU_code = {1'b0, funct7[5], funct3 };
					else
						ALU_code = {2'b00, funct3 };
				end 
			end
		7'h73 :
			begin
				Wr_to_RF = 1;
				imm_tmp = I_imm;
				ALU_code = {1'b1,1'b0, funct3};
				if ((rs2_tmp == 5'b00010) & (funct7 == 7'b0011000) & (funct3 == 0)) begin
					jump_r = 1'b1;
					Wr_to_RF = 0;
				end else begin
					if ( (funct3[2] == 1))begin
						ALU_B_src = 1;
					end else begin
						rs1_en = 1;
						ALU_B_src = 1;
					end 
				end
			end
		default:
			begin
				ALU_code = 0;
				Wr_to_RF = 0;
				jump = 0;
				jump_r = 0;
				Branch = 0;
				Wr_to_RF = 0;
				ALU_A_src = 0;
				ALU_B_src = 0;
				rs1_en = 0;
				rs2_en = 0;
				MEM_write = 0;
				WB_select = 0;
				imm_tmp = 0;
			end
	endcase
end

wire [4:0] rd3 		= control_registers[9:5];
wire       rd3_en 	= control_registers[3];
wire       WB_select3=control_registers[1];
	

always @(*)
begin
	//LOAD r2,0(0)
	//addi  r2,r2,0
	if ((WB_select3) & ((rs2_tmp == rd3) | (rs1_tmp == rd3)) & ((rs1_tmp !=0) & (rs2_tmp != 0)) & rd3_en)
		stall = 1;
	else
		stall = 0;

end
integer i;
always @(posedge clk)
begin
		if (reset)
		begin
			for (i=0; i<=31; i=i+1)
			begin
				Reg_file[i] <=0;
			end
		end
		
		if( rd_en ) begin 
			Reg_file[rd_address]   	<= rd_data;
			Reg_file[0]   				<= 0;			
		end else begin 
			Reg_file[0]   			<= 0;
		end

		if ((stall  == 1) | (stall_j == 1) | (reset==1'b1) ) begin 
			inputA_reg_file   <= 0;
			inputB_reg_file  <= 0;
			immidiate_sign_extended   <= 0;
			rs2_store_data   <= 0;
			PC_exec   <= 0;
			control_registers   <= 0;
		 end else begin 
		 	
			inputA_reg_file   <= (rs1_en == 1'b1)?(rd_en & (rs1_tmp == rd_address) & (rs1_tmp!=0))?rd_data:Reg_file[rs1_tmp ]:32'd0;
			inputB_reg_file   <= (rs2_en == 1'b1)?(rd_en & (rs2_tmp == rd_address) & (rs2_tmp!=0))?rd_data:Reg_file[rs2_tmp ]:32'd0;
			
			immidiate_sign_extended   <= imm_tmp;
			if (jump  | jump_r  ) begin 
				rs2_store_data   <= PC_dec;
			end else begin 
				rs2_store_data   <= (rs2_en == 1'b1)?(rd_en &(rs2_tmp == rd_address)&(rs2_tmp!=0))?rd_data:Reg_file[rs2_tmp ]:32'd0;
			end

			PC_exec   <= PC;
			control_registers   <= {jump_r,ALU_B_src,ALU_A_src,rs1_tmp,rs2_tmp,ALU_code,funct3,rd,Branch,Wr_to_RF,MEM_write,WB_select,jump};
		end	/*
jump_r |B_src | A_src |	rs1 | rs2 |	ALU_code | funct3 | rd | Branch | Wr_to_RF | MEM_write | WB_select | jump 
   1   |  1   |   2   |  5  |  5  |    5     |    3   |  5 |    1   |     1    |     1     |      1    |   1       																										

			*/

end



endmodule

