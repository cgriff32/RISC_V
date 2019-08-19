`timescale 1ns/1ns
`include "constants.vh"

module br_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	logic full;
	
//Branch control
typedef struct packed
{  
  logic issue_en;
  
  logic [`XLEN-1:0] issue_v1;
  logic [`XLEN-1:0] issue_v2;
  logic issue_v1_rdy;
  logic issue_v2_rdy;
  logic [`ROB_SIZE-1:0] issue_v1_q;
  logic [`ROB_SIZE-1:0] issue_v2_q;
  
  logic issue_thread_id;
  logic issue_comp;
  logic [5:0] issue_op ;
  logic [`XLEN-1:0] issue_offset;
  logic [`XLEN-1:0] issue_pc;
  
  logic cdb_valid;
  logic cdb_tag;
  logic cdb_value;
  
  logic pc_ack;
} branch_in;

typedef struct packed
{
  logic busy ;
  
  logic [`XLEN-1:0] v1;
  logic v1_rdy ;
  logic [`ROB_SIZE-1:0] q1;
  
  logic [`XLEN-1:0] v2;
  logic v2_rdy ;
  logic [`ROB_SIZE-1:0] q2;
} branch_unkilled_t;

typedef struct packed
{
  logic wr_cs;
  logic rd_cs;
  logic [((`THREAD_WIDTH+`XLEN)-1):0] data_in;
  logic rd_en;
  logic wr_en;
  logic [((`THREAD_WIDTH+`XLEN)-1):0] data_out;
  logic empty;
  logic full;
} branch_fifo_t;

typedef struct packed
{
  reg busy ;
  
  reg [`XLEN-1:0] v1;
  reg v1_rdy ;
  reg [`ROB_SIZE-1:0] q1;
  
  reg [`XLEN-1:0] v2;
  reg v2_rdy ;
  reg [`ROB_SIZE-1:0] q2;
} branch_internal;

typedef struct packed
{
  logic [`XLEN-1:0] pc_n;
  logic [2:0] thread_id;
  logic fifo_empty;
} branch_out;

branch_in br_i;
branch_out br_o;
	
br_control DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.br_i(br_i),
	.br_o(br_o),
	
	.full_o(full)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/br_tb.txt");
  
  #5
  rst <= 0;
  stall_i <= 1;
  br_i <= 0;
  
  #10;
  //Add R rs1 avail on cdb:
  br_i.issue_en <= '1;
  br_i.issue_v1 <= 256;
  br_i.issue_v2 <= 128;
  br_i.issue_v1_rdy <= '1;
  br_i.issue_v2_rdy <= '1;
  br_i.issue_v1_q <= '0;
  br_i.issue_v2_q <= 10;
  br_i.issue_thread_id <= '0;
  br_i.issue_comp <= '0;
  br_i.issue_op <= `ALU_OP_SEQ;
  br_i.issue_offset <= 256;
  br_i.issue_pc <= '0;
  br_i.cdb_valid <= '1;
  br_i.cdb_tag <= '0;
  br_i.cdb_value <= '0;
  br_i.pc_ack <= '0;
  
  #10;
  rst <= 1;
  stall_i <= 0;
  
  #40;
  #140;
  br_i.pc_ack <= 1;
  #20;
  br_i.pc_ack <= 0;
  #20;
  
  #100;
$fdisplay(write_data, "%b",  br_o);
$fclose(write_data);  // close the file   
$stop;
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
