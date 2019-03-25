//
`include "constants.vh"
module RISCV_Multicycle(

	input clk,
	
	input [`REG_DATA_WIDTH-1:0] 	pc_decode,
	input [`REG_DATA_WIDTH-1:0] 	instr_decode,
	
	input [`REG_DATA_WIDTH-1:0] 	pc_exe,
	input [`REG_DATA_WIDTH-1:0] 	rs1_exe,
	input [`REG_DATA_WIDTH-1:0] 	rs2_exe,
	input [`REG_DATA_WIDTH-1:0] 	instr_exe,
	
	input [`REG_DATA_WIDTH-1:0]	pc_mem,
	input [`REG_DATA_WIDTH-1:0]	alu_mem,
	input [`REG_DATA_WIDTH-1:0]	rs2_mem,
	input [`REG_DATA_WIDTH-1:0] 	instr_mem,
	
	input [`REG_DATA_WIDTH-1:0] 	mem_wb,
	input [`REG_DATA_WIDTH-1:0] 	instr_wb,
	
	input 								reg_write_en, 
	input 								br_unsign, 
	input 								b_sel, 
	input 								a_sel, 
	input 								alu_sel, 
	input 								mem_write_en,
	input [1:0] 						pc_sel,
	input [1:0] 						wb_sel,
	input [2:0] 						imm_sel
	
);

wire [31:0] instr, curr_instr;

fetch fetch(clk, 
				alu_exe, 
				pc_decode, 
				instr_decode, 
				pc_sel);

decode decode( clk,
				   pc_decode, 
					instr_decode, 
					mem_wb,
					instr_wb,
					pc_exe,
					instr_exe,
					rs1_exe,
					rs2_exe,
					imm_sel,
					reg_write_en);
					

execute execute();

mem mem(clk,
			pc_mem,
			instr_mem,
			alu_mem,
			rs2_mem,
			mem_wb,
			instr_wb,
			mem_write_en,
			wb_sel);

endmodule
