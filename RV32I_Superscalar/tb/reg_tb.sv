`timescale 1ns/1ns
`include "constants.vh"

module reg_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	logic [`REG_ADDR_WIDTH-1:0] rd_addr;
	logic [`XLEN-1:0] rd_data;
	
	logic [`REG_ADDR_WIDTH-1:0] r1_addr;
	logic [`REG_ADDR_WIDTH-1:0] r2_addr;
	logic [`XLEN-1:0] r1_data;
	logic [`XLEN-1:0] r2_data;
	
	logic write_en;
	
regfile DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.rd_addr(rd_addr),
	.rd_data(rd_data),
	
	.r1_data(r1_data),
	.r2_data(r2_data),
	.r1_addr(r1_addr),
	.r2_addr(r2_addr),
	
	.write_en(write_en)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/reg_tb.txt");
  
  #5
  rst <= 0;
  stall_i <= 0;
  //change this
  rd_addr <= 10;
  rd_data <= 256;
  
  r1_addr <= 13;
  r2_addr <= 5;
  
  write_en <= 1;

  #10;
  rst <= '1;
  
  //Start TB here
  #30;
  rd_addr <= 13;
  rd_data <= 128;
  #300;
$fdisplay(write_data, "%b",  {r1_data,r2_data});
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

