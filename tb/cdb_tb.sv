`timescale 1ns/1ns
`include "constants.vh"

module cdb_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
  logic [2:0] cdb_req;
  logic [2:0] fu_sel;
	
cdb_arbiter DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.cdb_req(cdb_req),
	.fu_sel(fu_sel)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/cdb_tb.txt");
  
  #5
  cdb_req <= '0; //change this
  rst <= 0;
  stall_i <= 0;
  #10;
  rst <= '1;
  
  //Start TB here
  #10;
  cdb_req <= 3'b100;
  
  
  #10;
  cdb_req <= 3'b010;
  #10;
  cdb_req <= 3'b111;
  #10;
  cdb_req <= 3'b011;
  #20;
  
  #100;
$fdisplay(write_data, "%b",  fu_sel);
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

