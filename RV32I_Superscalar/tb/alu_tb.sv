`timescale 1ns/1ns
`include "constants.vh"

module alu_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	
//ALU
typedef struct packed
{
  logic [`XLEN-1:0] rs_v1;
  logic [`XLEN-1:0] rs_v2;
  logic [`ALU_OP_WIDTH-1:0] rs_op;
  logic [`ROB_SIZE-1:0] rs_tag;
  
  logic fifo_en;
  logic cdb_en;
}alu_in;

typedef struct packed
{
  logic [`ROB_SIZE-1:0] tag;
  logic [`XLEN-1:0] value;
  logic fifo_empty;
  logic fifo_full;
} alu_out;

alu_in alu_i;
alu_out alu_o;
	
rs_alu DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.alu_i(alu_i),
	.alu_o(alu_o)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/alu_tb.txt");
  
  #5
  alu_i <= 0; //change this
  rst <= 0;
  stall_i <= 0;
  #10;
  rst <= '1;
  
  //Start TB here
  #10;
  alu_i.rs_v1 <= 16;
  alu_i.rs_v2 <= 32;
  alu_i.rs_op <= `ALU_OP_ADD;
  alu_i.rs_tag <= 12;
  
  
  #10;
  alu_i.cdb_en <= 1;
  #140;
  #20;
  #20;
  
  #100;
$fdisplay(write_data, "%b",  alu_o);
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

