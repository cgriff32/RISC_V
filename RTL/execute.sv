//
`include "constants.vh"

module execute(

input clk,

//Data pipeline
//From ID/EXE
input [`XLEN-1:0] 					pc_exe,
input [`XLEN-1:0] 					rs1_exe,
input [`XLEN-1:0] 					rs2_exe,
input [`XLEN-1:0] 					instr_exe,
input [`XLEN-1:0]						imm_exe,

//EXE/MEM registers
output reg [`REG_DATA_WIDTH-1:0] pc_mem,
output reg [`REG_DATA_WIDTH-1:0] alu_mem,
output reg [`REG_DATA_WIDTH-1:0] rs2_mem,
output reg [`REG_DATA_WIDTH-1:0] instr_mem,

//Control pipelin
//From ID/EXE
input [`A_SEL_WIDTH-1:0]			a_sel,
input [`B_SEL_WIDTH-1:0]			b_sel,
input [`ALU_OP_WIDTH-1:0]			alu_op,

//Forwarding control
input [`REG_ADDR_WIDTH-1:0]		rd_addr_exe,
output reg [`REG_ADDR_WIDTH-1:0] rd_addr_mem,
input [`XLEN-1:0]						forward_mem,
input [`XLEN-1:0]						forward_wb
);

logic [`XLEN-1:0] alu_a;
logic [`XLEN-1:0] alu_b;
logic [`XLEN-1:0] alu_out;

	alu alu(alu_a, alu_b, alu_op, alu_out);

always_comb
begin
	
	case(a_sel)
		`A_SEL_RS1  : alu_a = rs1_exe;
		`A_SEL_PC   : alu_a = pc_exe;
		`A_SEL_ALU	: alu_a = forward_mem;
		`A_SEL_MEM	: alu_a = forward_wb;
		`A_SEL_ZERO : alu_a = `XLEN'b0;
		default     : alu_a = `XLEN'b0;
	endcase
	
	case(b_sel)
		`B_SEL_RS2  : alu_b = rs2_exe;
		`B_SEL_IMM  : alu_b = imm_exe;
		`B_SEL_FOUR : alu_b = `XLEN'd4;
		`B_SEL_ALU	: alu_b = forward_mem;
		`B_SEL_MEM	: alu_b = forward_wb;
		`B_SEL_ZERO : alu_b = `XLEN'b0;
		default     : alu_b = `XLEN'b0;
	endcase
	
end

always_ff @(posedge clk)
begin

	instr_mem	<= instr_exe;
	pc_mem 		<= pc_exe;
	rs2_mem 		<= rs2_exe;
	alu_mem 		<= alu_out;
	rd_addr_mem <= rd_addr_exe;
	
end

endmodule
