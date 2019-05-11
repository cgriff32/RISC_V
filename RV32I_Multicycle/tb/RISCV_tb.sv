`timescale 1ns/1ns
`include "constants.vh"

module RISCV_tb;

	logic clk;
	logic [31:0] 	debug1;

RISCV_Multicycle DUT(
  .clk(clk),
  .debug1(debug1)
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





