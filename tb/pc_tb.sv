`timescale 1ns/1ns
`include "constants.vh"

module pc_tb;

	logic clk;
	logic rst;
	logic stall_i;
	
//PC
typedef struct packed
{
  logic [`XLEN-1:0] br_pc;
  logic branch_fifo_empty;
  logic [`THREAD_WIDTH-1:0] br_thread_id;
} pc_in;

typedef struct packed
{
  reg [`THREAD_WIDTH-1:0] thread_id;
  logic [`XLEN-1:0] pc_n;
} pc_internal;

typedef struct packed
{
  reg [`XLEN-1:0] pc;
  reg [2:0] thread_id;
  
  logic br_ack;
} pc_out;

pc_in pc_i;
pc_out pc_o;
	
pc DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.pc_i(pc_i),
	.pc_o(pc_o)
);
						
initial
begin
  #5
  
  pc_i <= 0;
  rst <= 1;
  
  pc_i.br_pc <= 8;
  pc_i.branch_fifo_empty <= 1;
  pc_i.br_thread_id <= 4;
  
  #10;
  pc_i.branch_fifo_empty <= 0;

  rst <= 0;
  #10;
  #10;
  stall_i <= 1;
  #10;
  stall_i <= 0;
  
  
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
