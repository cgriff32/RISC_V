`timescale 1ns/1ns
`include "constants.vh"

module issue_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
//ISSUE
typedef struct packed
{
  logic [`ALU_OP_WIDTH-1:0] decode_op_sel;
  logic [`FU_SEL_WIDTH-1:0] decode_fu_sel;
  logic decode_alu_op;
  logic [`XLEN-1:0] decode_pc;
  logic [`XLEN-1:0] decode_imm;
  logic [`REG_ADDR_WIDTH-1:0] decode_rs1;
  logic [`REG_ADDR_WIDTH-1:0] decode_rs2;
  logic [`REG_ADDR_WIDTH-1:0] decode_rd;
  logic decode_thread_id;
  
  logic prod_rs1_valid;
  logic prod_rs2_valid;
  logic [`ROB_SIZE-1:0] prod_rs1_tag;
  logic [`ROB_SIZE-1:0] prod_rs2_tag;
  
  logic [`XLEN-1:0] reg_rs1_value;
  logic [`XLEN-1:0] reg_rs2_value;
  
  logic rob_rs1_valid;
  logic rob_rs2_valid;
  logic [`XLEN-1:0] rob_rs1_value;
  logic [`XLEN-1:0] rob_rs2_value;
  logic [`ROB_SIZE-1:0] rob_tag;
  
  logic [`ROB_SIZE-1:0] cdb_tag;
  logic [`XLEN-1:0] cdb_value;
  
} issue_in;

typedef struct packed
{
  logic check_rs1;
  logic check_rs2;
  
  logic [`XLEN-1:0] rs1_value;
  logic [`XLEN-1:0] rs2_value;
  logic rs1_rdy;
  logic rs2_rdy;
  logic [`ROB_SIZE-1:0] rs1_q;
  logic [`ROB_SIZE-1:0] rs2_q;
  
  logic [`XLEN-1:0] rs1_imm_value;
  logic [`XLEN-1:0] rs2_imm_value;
  logic rs1_imm_rdy;
  logic rs2_imm_rdy;
  
  logic rs1_snooped;
  logic rs2_snooped;
  logic [`XLEN-1:0] rs1_snoop_value;
  logic [`XLEN-1:0] rs2_snoop_value;
  logic rs1_snoop_rdy;
  logic rs2_snoop_rdy;
  
  logic bypass_rs;
  logic [`XLEN-1:0] rd_bypass;
  
  logic br_comp;
  logic [`XLEN-1:0] br_offset;
  logic [`XLEN-1:0] st_offset;
  
  logic [`XLEN-1:0] pc_four;
  logic [`XLEN-1:0] imm_pc;
} issue_internal;

typedef struct packed
{
  reg [`THREAD_WIDTH-1:0] thread_id;

  reg [`XLEN-1:0] rs1_value;
  reg [`XLEN-1:0] rs2_value;
  reg rs1_rdy;
  reg rs2_rdy;
  reg [`ROB_SIZE-1:0] rs1_q;
  reg [`ROB_SIZE-1:0] rs2_q;
  reg [`ALU_OP_WIDTH-1:0] alu_op;
  
  reg rob_en;
  reg [`XLEN-1:0] rob_value;
  reg rob_valid;
  reg [`ROB_SIZE-1:0] rob_dest;
  
  reg br_en;
  reg br_comp;
  reg [`XLEN-1:0] br_offset;
  reg [`XLEN-1:0] br_pc;
  
  reg rs_en;
  reg [`ROB_SIZE-1:0] rs_tag;
  
  reg ld_en;
  reg [`XLEN-1:0] ld_offset;
  
  reg prod_en;
  reg [`REG_ADDR_WIDTH-1:0] prod_rd_addr;
  reg [`ROB_SIZE-1:0] prod_tag;
  
  logic [`REG_ADDR_WIDTH-1:0] rs1_addr;
  logic [`REG_ADDR_WIDTH-1:0] rs2_addr;
  logic [`ROB_SIZE-1:0] rs1_tag;
  logic [`ROB_SIZE-1:0] rs2_tag;
  
} issue_out;

issue_in issue_i;
issue_out issue_o;
	
issue DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.issue_i(issue_i),
	.issue_o(issue_o)
);
	
//  logic [`ALU_OP_WIDTH-1:0] decode_op_sel;
//  logic [`FU_SEL_WIDTH-1:0] decode_fu_sel;
//  logic decode_alu_op;
//  logic [`XLEN-1:0] decode_pc;
//  logic [`XLEN-1:0] decode_imm;
//  logic [`REG_ADDR_WIDTH-1:0] decode_rs1;
//  logic [`REG_ADDR_WIDTH-1:0] decode_rs2;
//  logic [`REG_ADDR_WIDTH-1:0] decode_rd;
//  logic decode_thread_id;
//  
//  logic prod_rs1_valid;
//  logic prod_rs2_valid;
//  logic [`ROB_SIZE-1:0] prod_rs1_tag;
//  logic [`ROB_SIZE-1:0] prod_rs2_tag;
//  
//  logic [`XLEN-1:0] reg_rs1_value;
//  logic [`XLEN-1:0] reg_rs2_value;
//  
//  logic rob_rs1_valid;
//  logic rob_rs2_valid;
//  logic [`XLEN-1:0] rob_rs1_value;
//  logic [`XLEN-1:0] rob_rs2_value;
//  logic [`ROB_SIZE-1:0] rob_tag;
//  
//  logic [`ROB_SIZE-1:0] cdb_tag;
//  logic [`XLEN-1:0] cdb_value;  				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/issue_tb.txt");
  
  #5
  issue_i <= 0;
  rst <= 0;
  stall_i <= 1;
  
  //Add R rs1 avail on cdb:
  issue_i.decode_op_sel <= `OP_SEL_R;
  issue_i.decode_fu_sel <= `FU_SEL_RS;
  issue_i.decode_alu_op <= `ALU_OP_AND;
  issue_i.decode_rs1 <= 10;
  issue_i.decode_rs2 <= 11;
  issue_i.decode_rd <= 12;
     
  issue_i.prod_rs1_tag <= 4;
  issue_i.prod_rs2_tag <= 6;
  issue_i.prod_rs1_valid <= 0;
  issue_i.prod_rs2_valid <= 0;
  issue_i.rob_rs1_valid <= 0;
  issue_i.rob_rs2_valid <= 1;
  issue_i.rob_rs2_value <= 128;
  issue_i.rob_tag <= 7;
  
  issue_i.cdb_tag <= 4;
  issue_i.cdb_value <= 256;
  
  #10;
  rst <= 1;
  stall_i <= 0;
  
  #10;
  
  #20;
  stall_i <= 1;
    issue_i.decode_op_sel <= `OP_SEL_R;
  issue_i.decode_fu_sel <= `FU_SEL_RS;
  issue_i.decode_alu_op <= `ALU_OP_AND;
  issue_i.decode_rs1 <= 10;
  issue_i.decode_rs2 <= 11;
  issue_i.decode_rd <= 12;
     
  issue_i.prod_rs1_tag <= 4;
  issue_i.prod_rs2_tag <= 6;
  issue_i.prod_rs1_valid <= 1;
  issue_i.prod_rs2_valid <= 0;
  issue_i.reg_rs1_value <= '1;
  issue_i.rob_rs1_valid <= 0;
  issue_i.rob_rs2_valid <= 1;
  issue_i.rob_rs2_value <= 128;
  issue_i.rob_tag <= 7;
  
  issue_i.cdb_tag <= 4;
  issue_i.cdb_value <= 256;
  
  #20;
  
  stall_i <= 0;
  
  #100;
$fdisplay(write_data, "%b",  issue_o);
$fclose(write_data);  // close the file   
$stop;
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
