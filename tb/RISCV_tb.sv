`timescale 1ns/1ns
`include "constants.vh"

module RISCV_tb;

	logic clk;


	logic [31:0] 	debug;


RISCV_Multicycle DUT(

	 			.clk(clk),
	        .debug(debug)
	
	
);

initial
begin
  

end

		
  always 
  begin
    
    clk <= 0; #5;
    clk <= 1; #5;
  end

		
		
endmodule





