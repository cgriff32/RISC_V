`timescale 1ns/1ns
`include "constants.vh"

module rob_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	//ROB
typedef struct packed
{ 
  logic [`ROB_SIZE-1:0] issue_rs1_tag;
  logic [`ROB_SIZE-1:0] issue_rs2_tag;
  
  logic issue_en; //tail_en
  logic issue_valid;
  logic [`XLEN-1:0] issue_value;
  logic [`REG_ADDR_WIDTH-1:0] issue_dest;
  
  logic cdb_valid; //wr_en
  logic [`XLEN-1:0] cdb_value;
  logic [`ROB_SIZE-1:0] cdb_tag;
  
  logic reg_en; //head_en
} rob_in;

typedef struct packed
{
  reg valid;
  reg [`XLEN-1:0] value;
  reg [`REG_ADDR_WIDTH-1:0] dest;
} rob_struct_t;

typedef struct packed
{ 
  logic full;
  logic empty;
  logic [`ROB_SIZE-1:0] tag;
  
  logic issue_rs1_valid;
  logic issue_rs2_valid;
  logic [`XLEN-1:0] issue_rs1_value;
  logic [`XLEN-1:0] issue_rs2_value;
  
  logic reg_en;
  logic [`REG_ADDR_WIDTH-1:0] reg_dest;
  logic [`XLEN-1:0] reg_value;
} rob_out;

	rob_in  rob_i;
	rob_out rob_o;
	
rob DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.rob_i(rob_i),
	.rob_o(rob_o)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/rob_tb.txt");
  
  #5
  rob_i <= '0; //change this
  rst <= 0;
  stall_i <= 0;
  
  rob_i.issue_rs1_tag <= 1;
  rob_i.issue_rs2_tag <= 2;
  rob_i.issue_en <= 1;
  rob_i.issue_valid <= 0;
  rob_i.issue_value <= 256;
  rob_i.issue_dest <= 8;

  #10;
  rst <= '1;
  
  //Start TB here
  #10;
  rob_i.issue_valid <= 0;
  #10;
  rob_i.cdb_valid <= 0;
  rob_i.cdb_tag <= 0;
  rob_i.cdb_value <= 16;
  
  #10;
  
  #10;
  rob_i.reg_en <= 0;
  
  #10;
  rob_i.cdb_tag <= 2;
  rob_i.cdb_valid <= 0;
  
  #10; 
  rob_i.cdb_tag <= 0;
  
  #10;
  rob_i.cdb_valid <= 1;
  rob_i.reg_en <= 1;
  #300;
$fdisplay(write_data, "%b",  rob_o);
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

