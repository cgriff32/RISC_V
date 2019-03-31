//
`include "constants.vh"

module execute(

input clk,

//Input signals
input [`XLEN-1:0] 					pc_exe,
input [`XLEN-1:0] 					rs1_exe,
input [`XLEN-1:0] 					rs2_exe,
input [`XLEN-1:0] 					instr_exe,
input [`XLEN-1:0]						imm_exe,

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0] pc_mem,
output reg [`REG_DATA_WIDTH-1:0] alu_mem,
output reg [`REG_DATA_WIDTH-1:0] rs2_mem,
output reg [`REG_DATA_WIDTH-1:0] instr_mem,

//Output wire
output [`XLEN-1:0] 					alu_exe,

//Control signals
input [`A_SEL_WIDTH-1:0]			a_sel,
input [`B_SEL_WIDTH-1:0]			b_sel,
input [`ALU_OP_WIDTH-1:0]			alu_op,

//Forwarding signals
input [`XLEN-1:0]						forward_alu,
input [`XLEN-1:0]						forward_mem
);

wire [`XLEN-1:0] alu_a;
wire [`XLEN-1:0] alu_b;
wire [`XLEN-1:0] alu_out;

	alu alu(alu_a, alu_b, alu_op, alu_out);

always_comb
begin
	
	case(a_sel)
		`A_SEL_RS1  : alu_a = rs1_exe;
		`A_SEL_PC   : alu_a = pc_exe;
		`A_SEL_ALU	: alu_a = forward_alu;
		`A_SEL_MEM	: alu_a = forward_mem;
		`A_SEL_ZERO : alu_a = `XLEN'b0;
		default     : alu_a = `XLEN'b0;
	endcase
	
	case(b_sel)
		`B_SEL_RS2  : alu_b = rs2_exe;
		`B_SEL_IMM  : alu_b = imm_exe;
		`B_SEL_FOUR : alu_b = `XLEN'd4;
		`B_SEL_ALU	: alu_b = forward_alu;
		`B_SEL_MEM	: alu_b = forward_mem;
		`B_SEL_ZERO : alu_b = `XLEN'b0;
		default     : alu_b = `XLEN'b0;
	endcase
	
	alu_exe = alu_out;
	
end

always_ff @(posedge clk)
begin

	instr_mem	<= instr_exe;
	pc_mem 		<= pc_exe;
	rs2_mem 		<= rs2_exe;
	alu_mem 		<= alu_out;
	
end

endmodule
