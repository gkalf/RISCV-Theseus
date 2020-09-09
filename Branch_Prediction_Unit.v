

module Branch_Prediction_Unit
#(parameter SIZE = 32,
  parameter DEPTH= 7)
(
	clk,
	reset,
	new_PC,
	control_registers_MEM,
	PC_MEM,
	jump_address,
	branch_taken,
	rom_address,
	prediction,
	prediction_propagate
);


input clk,reset;
input [SIZE-1:0] new_PC;
input [13:0] control_registers_MEM;
input [SIZE-1:0] PC_MEM;
input [SIZE-1:0] jump_address;
input branch_taken;

output wire [SIZE-1:0] rom_address;
output wire prediction;
output 		prediction_propagate;


reg [(1<<DEPTH)-1:0]      i,k,j;
reg [SIZE-1:0] Look_up      [0:(1<<DEPTH)-1];
reg [SIZE-1:0] Predicted_PC [0:(1<<DEPTH)-1];
reg [(1<<DEPTH)-1:0]		   exists;
reg [(1<<DEPTH)-1:0]			found_in;

reg [1:0]      Branch_Predicted [0:(1<<DEPTH)-1];
reg [DEPTH-1:0] pos;
wire [DEPTH-1:0] address_for_out;
reg next;

wire unconditional_branch;
wire conditional_branch,prediction_propagate;

reg prediction_decode,prediction_data,prediction_fetch;

assign prediction = prediction_data;
assign unconditional_branch = (control_registers_MEM[0] | control_registers_MEM[13]);
assign conditional_branch = control_registers_MEM[4];


assign rom_address          =	(address_for_out == 0)? new_PC:
										(Branch_Predicted[address_for_out][1] == 1'b1)?Predicted_PC[address_for_out]:new_PC;
assign prediction_propagate = (address_for_out == 0)? 1'b0:
										(Branch_Predicted[address_for_out][1] == 1'b1)?1'b1:1'b0;


always @(posedge clk)
begin
	if (reset)
		begin
			for (j=0; j<=(1<<DEPTH)-1; j=j+1)
				begin
				Look_up[j]<=0;
				Predicted_PC[j]<=0;
				end
		end
	if ((~|exists) & (unconditional_branch | conditional_branch)) begin
		Look_up[pos] 			<= PC_MEM;
		Predicted_PC[pos]		<= jump_address;
	end
end

always @(*)
begin
	//exists = 128'd0;
	for (j=0; j<=(1<<DEPTH)-1; j=j+1)
	begin
		if (Look_up[j] == PC_MEM)
			exists[j] = 1'b1;
		else
			exists[j] = 0;
	end	
end

always @(*)
begin: find_if_exists //if exists in table
	found_in=0;
	for (k=0; k<=(1<<DEPTH)-1; k=k+1)
	begin
		if (Look_up[k] == new_PC)
			found_in[k] = 1'b1;
		else
			found_in[k] = 1'b0;
	end
end

one_hot_decoder decode_dut
			(
			.a(found_in),
			.z(address_for_out)
			);
			
always @(posedge clk)
begin
	if (reset)
		pos <= 0;
	else if ((~|exists) & (unconditional_branch | conditional_branch))
		pos <= pos + 1'b1;
	else
		pos <= pos;
end		

always @(posedge clk) //update bimodal table
begin: update_Bimodal_table
	for (i=0; i<=(1<<DEPTH)-1; i=i+1)
		begin
		Branch_Predicted[i] <= Branch_Predicted[i];
		if (reset) begin
			Branch_Predicted[i] <= 0;
		end if (Look_up[i] == PC_MEM) 
			begin
				if ((Branch_Predicted[i] == 2'b00) & branch_taken)
					Branch_Predicted[i] <=	2'b01;
				else if ((Branch_Predicted[i] == 2'b01) & branch_taken)
					Branch_Predicted[i] <= 2'b11;
				else if ((Branch_Predicted[i] == 2'b11) & branch_taken)
					Branch_Predicted[i] <= 2'b11;
				else if ((Branch_Predicted[i] == 2'b10) & branch_taken )
					Branch_Predicted[i] <= 2'b11;
				else if ((Branch_Predicted[i] == 2'b11) & !branch_taken)
					Branch_Predicted[i] <= 2'b10;
				else if ((Branch_Predicted[i] == 2'b10) & !branch_taken)
					Branch_Predicted[i] <= 2'b00;
				else if ((Branch_Predicted[i] == 2'b01) & !branch_taken)
					Branch_Predicted[i] <= 2'b00;
				else if ((Branch_Predicted[i] == 2'b00) & !branch_taken)
					Branch_Predicted[i] <= 2'b00;
				else
					Branch_Predicted[i] <= 2'b01;			
			end
		else if ((~|exists) & (unconditional_branch | conditional_branch))
			Branch_Predicted[pos] <= (branch_taken)?2'b01:2'b00;
		end	
end
								   								

always @(posedge clk) //propagate prediction
begin
	if (reset) begin
		prediction_fetch	<= 0;
		prediction_decode <= 0;
		prediction_data	<= 0;
	end else begin
		prediction_fetch 	<= prediction_propagate;
		prediction_decode	<= prediction_fetch;
		prediction_data <= prediction_decode;
	end
end

	


endmodule

