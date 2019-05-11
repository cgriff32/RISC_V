`timescale 1ns/1ns
`include "constants.vh"

module execute_tb;

	logic clk;

//Data pipeline
//From ID/EXE
logic [`XLEN-1:0] 					pc_exe;
logic [`XLEN-1:0] 					rs1_exe;
logic [`XLEN-1:0] 					rs2_exe;
logic [`XLEN-1:0] 					instr_exe;
logic [`XLEN-1:0]						imm_exe;

//EXE/MEM registers
logic [`REG_DATA_WIDTH-1:0] pc_mem;
logic [`REG_DATA_WIDTH-1:0] alu_mem;
logic [`REG_DATA_WIDTH-1:0] rs2_mem;
logic [`REG_DATA_WIDTH-1:0] instr_mem;

//Control pipelin
//From ID/EXE
logic [`A_SEL_WIDTH-1:0]			a_sel;
logic [`B_SEL_WIDTH-1:0]			b_sel;
logic [`ALU_OP_WIDTH-1:0]			alu_op;

//Forwarding control
logic [`REG_ADDR_WIDTH-1:0]		rd_addr_exe;
logic [`REG_ADDR_WIDTH-1:0] rd_addr_mem;
logic [`XLEN-1:0]						forward_mem;
logic [`XLEN-1:0]						forward_wb;
	
execute DUT(	.clk(clk),
						//Data pipeline
						//From ID/EXE
						.pc_exe(pc_exe),
						.rs1_exe(rs1_exe),
						.rs2_exe(rs2_exe),
						.instr_exe(instr_exe),
						.imm_exe(imm_exe),						
						//EXE/MEM registers
						.pc_mem(pc_mem),
						.alu_mem(alu_mem),
						.rs2_mem(rs2_mem),
						.instr_mem(instr_mem),
						//Control pipeline
						//From ID/EXE
						.a_sel(a_sel),
						.b_sel(b_sel),
						.alu_op(alu_op),
						//Forwarding control
						.rd_addr_exe(rd_addr_exe),
						.rd_addr_mem(rd_addr_mem),
						.forward_mem(forward_mem),
						.forward_wb(forward_wb)
						);

initial
begin
    #5;
  pc_exe <= 32'd1;
  rs1_exe <= 32'd2;
  rs2_exe <= 32'd3;
  instr_exe <= '0;
  imm_exe <= 32'd4;
  a_sel <= `A_SEL_ZERO;
  b_sel <= `B_SEL_ZERO;
  alu_op <= `ALU_OP_ADD;
  rd_addr_exe <= 32'd5;
  forward_mem <= 32'd6;
  forward_wb <= 32'd7;
    #10;
  
  b_sel <= `B_SEL_FOUR;
  #10;
    b_sel <= `B_SEL_MEM;
  #10;
    b_sel <= `B_SEL_FOUR;
  #10;
    b_sel <= `B_SEL_ALU;
  #10;
    b_sel <= `B_SEL_MEM;
  #10;
    b_sel <= `B_SEL_ZERO;
  #10;
  
end
  
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

