`timescale 1ns/1ps
module testbench;

reg clk,reset;

wire [31:0] data_out,new_PC;

TOP dut(clk,reset,data_out,new_PC);

initial begin
clk = 0;
reset = 1;
#10;
reset =0;
while(1)
begin
	if (new_PC == 32'd500<<2)
	begin
		$finish();
	end
	#10;
end
end

always 
    #5 clk = !clk; 

endmodule
