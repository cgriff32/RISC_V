`timescale 1ns/1ns
`include "constants.vh"

module decode_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
//DECODE
typedef struct packed
{
  logic [`XLEN-1:0] instr_pc;
  logic [2:0] instr_thread_id;
  logic [`INSTR_WIDTH-1:0] instr_instr;
  
} decode_in;

typedef struct packed
{
  logic [`REG_ADDR_WIDTH-1:0] rs1_addr;
  logic [`REG_ADDR_WIDTH-1:0] rs2_addr; 
  logic [`REG_ADDR_WIDTH-1:0] rd_addr; 
  
  logic [`OP_CODE_WIDTH-1:0] opcode;
  logic [2:0] funct3;
  logic funct7;
  
  logic [`IMM_SEL_WIDTH-1:0] imm_wire;
  logic [`IMM_SEL_WIDTH-1:0] imm_sel;
  logic [`FU_SEL_WIDTH-1:0] fu_sel;
  logic [`ALU_OP_WIDTH-1:0] alu_op_wire;
  logic [`ALU_OP_WIDTH-1:0] alu_op;
  logic [`OP_SEL_WIDTH-1:0] op_sel;
  
  logic illegal_instr;
} decode_internal;

typedef struct packed
{
  reg [`OP_SEL_WIDTH-1:0] op_sel;
  reg [`ALU_OP_WIDTH-1:0] alu_op;
  reg [`REG_ADDR_WIDTH-1:0] rs1;
  reg [`REG_ADDR_WIDTH-1:0] rs2;
  reg [`REG_ADDR_WIDTH-1:0] rd;
  reg [`XLEN-1:0] imm;
  reg [`XLEN-1:0] pc;
  reg [2:0] thread_id;
  reg [`FU_SEL_WIDTH-1:0] fu_sel;
} decode_out;

decode_in decode_i;
decode_out decode_o;
	
decode DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.decode_i(decode_i),
	.decode_o(decode_o)
);
				
  //logic [`XLEN-1:0] instr_pc;
  //logic [2:0] instr_thread_id;
  //logic [`INSTR_WIDTH-1:0] instr_instr;
  				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/decode_tb.txt");
  #5
  decode_i <= 0;
  rst <= 1;
  
  stall_i <= 1;
  decode_i.instr_instr <= 32'b00000000101101010000011000110011;
  
  #10;
  rst <= 0;
  
  stall_i <= 0;
  #10;
  
  
  
$fdisplay(write_data, "%b", decode_o);
$fclose(write_data);  // close the file   
$stop;
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
