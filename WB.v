module WB
#(parameter SIZE = 32)
(
	WB_select,
	r_data,
	ALU_result,
	funct3,
	rd_data
);

input WB_select;
input [SIZE-1:0] r_data;
input [SIZE-1:0] ALU_result;
input [2:0] 	funct3;
output wire [SIZE-1:0] rd_data;

wire [31:0] Decode_to_Sign_Extend_byte,Decode_to_Sign_Extend_Half_Word;
wire [31:0] sign_extended_byte,sign_extended_half_word;

MUX_2_1 #(32) Load_Half_Word
(	{16'd0,r_data[31:16]},
	{16'd0,r_data[15:0]},
	ALU_result[1],
	Decode_to_Sign_Extend_Half_Word
);

sign_extend #(32,16) sign_extend_Half_Word
(
	Decode_to_Sign_Extend_Half_Word,
	~funct3[2],
	sign_extended_half_word
);

MUX_4_1 #(32) Load_Byte
(
	{24'd0,r_data[7:0]},
	{24'd0,r_data[15:8]},
	{24'd0,r_data[23:16]},
	{24'd0,r_data[31:24]},
	ALU_result[1:0],
	Decode_to_Sign_Extend_byte
);

sign_extend #(32,8) sign_extend_byte
(
	Decode_to_Sign_Extend_byte,
	~funct3[2],
	sign_extended_byte
);

wire [31:0] data_to_WB;
MUX_4_1 #(32) MUX_4_1_select_Data_to_WB
(
	sign_extended_byte,
	sign_extended_half_word,
	r_data,
	32'd0,
	funct3[1:0],
	data_to_WB
);


MUX_2_1 #(32) ALU_or_Imm_SEL_Write_Back
(
	data_to_WB,
	ALU_result,
	WB_select,
	rd_data
);

endmodule