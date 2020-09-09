module Dual_Port_Mem
#(
	parameter SIZE = 32,
	parameter ADDR_WIDTH = 4 	
)
(
	clk,
	funct3,
	address,
	w_data,
	MEM_write,
	data_out,
	q,addr
);


	input 						clk;
	input [2:0] 				funct3;
	input	[ADDR_WIDTH+1:0]	address;
	input [SIZE-1:0]			w_data;
	input [ADDR_WIDTH-1:0]	addr;
	input 						MEM_write;
	output reg [SIZE-1:0] 	data_out;
	output reg [SIZE-1:0] 	q;

reg [SIZE-1:0] ram[2**ADDR_WIDTH-1:0];
initial
	begin
		$readmemh("I-CSRRWI-01.elf.hex", ram);
	end

wire tx_byte = ~funct3[1] & ~funct3[0];
wire tx_half = ~funct3[1] &  funct3[0];
wire tx_word =  funct3[1];

wire byte_at_00 = tx_byte & ~address[1] & ~address[0];
wire byte_at_01 = tx_byte & ~address[1] &  address[0];
wire byte_at_10 = tx_byte &  address[1] & ~address[0];
wire byte_at_11 = tx_byte &  address[1] &  address[0];

wire half_at_00 = tx_half & ~address[1];
wire half_at_10 = tx_half &  address[1];

wire word_at_00 = tx_word;

wire byte0 = word_at_00 | half_at_00 | byte_at_00;
wire byte1 = word_at_00 | half_at_00 | byte_at_01;
wire byte2 = word_at_00 | half_at_10 | byte_at_10;
wire byte3 = word_at_00 | half_at_10 | byte_at_11;

// Writing to the memory
reg [SIZE-1:0] previous_address;



always @ (posedge clk)
begin
		q <= ram[addr];
end
	
always @(posedge clk)
begin
  
  data_out <= ram[address[ADDR_WIDTH+1:2]];

 if(MEM_write)
 begin
 	if (word_at_00)
 		ram[address[ADDR_WIDTH+1:2]][31:0] <= w_data[31:0]; 	
 	if (tx_half)
 		begin
 			if (half_at_00)
 				ram[address[ADDR_WIDTH+1:2]][15:0] <= w_data[15:0];
 			if (half_at_10)
 				ram[address[ADDR_WIDTH+1:2]][31:16] <= w_data[15:0];
 		end
 	if (tx_byte)
 		begin 	
			if(byte0)
				ram[address[ADDR_WIDTH+1:2]][7:0] <= w_data[7:0];
			if(byte1)
				ram[address[ADDR_WIDTH+1:2]][15:8] <= w_data[7:0];
			if(byte2)
				ram[address[ADDR_WIDTH+1:2]][23:16] <= w_data[7:0];
			if(byte3)
				ram[address[ADDR_WIDTH+1:2]][31:24] <= w_data[7:0];
		end
  end
end



endmodule