`timescale 1ns/1ns
`include "constants.vh"

module instr_tb;

	logic clk;
	logic rst;
	logic stall_i;
	
//Instr
typedef struct packed
{
  logic [`XLEN-1:0] pc_pc;
  logic [`THREAD_WIDTH-1:0] pc_thread_id;
  
  logic decode_ack;
} instr_in;

typedef struct packed
{
  logic wr_cs;
  logic rd_cs;
  logic [(`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1:0] data_in;
  logic rd_en;
  logic wr_en;
  logic [((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1):0] data_out;
  logic empty;
  logic full;
} instr_fifo_t;

typedef struct packed
{
  
  logic [`THREAD_WIDTH-1:0] thread_id;
  logic [`XLEN-1:0] pc;
  logic [`INSTR_WIDTH-1:0] instr;
  logic fifo_empty;
} instr_out;

instr_in instr_i;
instr_out instr_o;

int i;
logic [`THREAD_WIDTH-1:0] thread_id;
logic [`XLEN-1:0] pc;
	
instr DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.instr_i(instr_i),
	.instr_o(instr_o)
);
						
initial
begin
  
  #5
  instr_i <= 0;
  rst <= 0;
  stall_i <= 0;
  #10;
  rst <= 1;
  
  
  #10;
  instr_i.decode_ack <= 1;
  instr_i.pc_thread_id <= 1;
  #10;
  instr_i.pc_thread_id <= 4;
  #10;
  instr_i.pc_pc <= 16;
  #10;
  #30;
  
  
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end
		
endmodule
