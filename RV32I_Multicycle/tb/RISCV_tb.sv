`timescale 1ns/1ns
`include "constants.vh"

module RISCV_tb;

	logic clk;
	logic [31:0] 	debug1;
logic [31:0] 	debug2;
logic [31:0] 	debug3;
logic [31:0] 	debug4;

RISCV_Multicore DUT(
  .clk(clk),
  .debug1(debug1),
  .debug2(debug2),
  .debug3(debug3),
  .debug4(debug4)
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





