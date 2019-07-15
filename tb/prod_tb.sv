`timescale 1ns/1ns
`include "constants.vh"

module prod_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	logic issue_en;
	logic [`REG_ADDR_WIDTH-1:0] rd_addr;
	logic [`ROB_SIZE-1:0] rd_tag;
	
	logic [`REG_ADDR_WIDTH-1:0] r1_addr;
	logic [`REG_ADDR_WIDTH-1:0] r2_addr;
	logic [`ROB_SIZE-1:0] r1_tag;
	logic [`ROB_SIZE-1:0] r2_tag;
	logic r1_valid;
	logic r2_valid;
	
	logic rob_en;
	logic [`REG_ADDR_WIDTH-1:0] rob_dest;
	logic [`ROB_SIZE-1:0] rob_tag;
	
	
prod_table DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.issue_en(issue_en),
	.rd_addr(rd_addr),
	.rd_tag(rd_tag),
	
	.r1_tag(r1_tag),
	.r2_tag(r2_tag),
	.r1_addr(r1_addr),
	.r2_addr(r2_addr),
	.r1_valid(r1_valid),
	.r2_valid(r2_valid),
	
	.rob_en(rob_en),
	.rob_dest(rob_dest),
	.rob_tag(rob_tag)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/prod_tb.txt");
  
  #5
  rst <= 0;
  stall_i <= 0;
  //change this
  
  issue_en <= 1;
  rd_addr <= 10;
  rd_tag <= 7;
  
  r1_addr <= 10;
  r2_addr <= 5;
  
  rob_en <= 0;
  rob_dest <= 10;
  rob_tag <= 7;
  
  #10;
  rst <= '1;
  
  //Start TB here
  #10;
  rob_en <= 1;
  #300;
$fdisplay(write_data, "%b",  {r1_valid,r1_tag,r2_valid,r2_tag});
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

