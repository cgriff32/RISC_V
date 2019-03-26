//
`include "constants.vh"
module RISCV_Multicycle(

	input clk,
	
	output [31:0] debug
	
);

wire [`XLEN-1:0]	pc_decode;
wire [`XLEN-1:0]	instr_decode;

wire [`XLEN-1:0]	pc_exe;
wire [`XLEN-1:0] 	rs1_exe;
wire [`XLEN-1:0] 	rs2_exe;
wire [`XLEN-1:0] 	instr_exe;

wire [`XLEN-1:0]  alu_exe;
wire [`XLEN-1:0]	pc_mem;
wire [`XLEN-1:0]	alu_mem;
wire [`XLEN-1:0]	rs2_mem;
wire [`XLEN-1:0]	instr_mem;

wire [`XLEN-1:0]	mem_wb;
wire [`XLEN-1:0]	instr_wb;

wire				br_true;

wire 								reg_write_en; 
wire 								br_unsign; 
wire [`B_SEL_WIDTH-1:0]		b_sel; 
wire [`A_SEL_WIDTH-1:0]		a_sel; 
wire [`ALU_OP_WIDTH-1:0]	alu_sel; 
wire [`MEMRW_SEL_WIDTH-1:0] mem_write_en;
wire [`PC_SEL_WIDTH-1:0]	pc_sel;
wire [`WB_SEL_WIDTH-1:0] 	wb_sel;
wire [`IMM_SEL_WIDTH-1:0]	imm_sel;

control control(	instr_decode,
						br_true,
						reg_write_en, 
						br_unsign, 
						b_sel, 		
						a_sel, 
						alu_sel, 
						mem_write_en,
						pc_sel,
						wb_sel,
						imm_sel);

fetch fetch(		clk, 
						alu_exe, 
						pc_decode, 
						instr_decode, 
						pc_sel);

decode decode(		clk,
						pc_decode, 
						instr_decode, 
						mem_wb,
						instr_wb,
						pc_exe,
						instr_exe,
						rs1_exe,
						rs2_exe,
						reg_write_en);
					

execute execute(	clk,
						pc_exe,
						rs1_exe,
						rs2_exe,
						instr_exe,
						pc_mem,
						alu_mem,
						rs2_mem,
						instr_mem,
						alu_exe,
						imm_sel,
						br_unsign,
						a_sel,
						b_sel,
						alu_sel,
						br_true,
						alu_mem,
						mem_wb);
						

mem mem(				clk,
						pc_mem,
						instr_mem,
						alu_mem,
						rs2_mem,
						mem_wb,
						instr_wb,
						mem_write_en,
						wb_sel);
		
endmodule
