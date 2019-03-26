//
`include "constants.vh"

module execute(

input clk,

//Input signals
input [`XLEN-1:0] 					pc_exe,
input [`XLEN-1:0] 					rs1_exe,
input [`XLEN-1:0] 					rs2_exe,
input [`XLEN-1:0] 					instr_exe,

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0] pc_mem,
output reg [`REG_DATA_WIDTH-1:0] alu_mem,
output reg [`REG_DATA_WIDTH-1:0] rs2_mem,
output reg [`REG_DATA_WIDTH-1:0] instr_mem,

//Output wire
output [`XLEN-1:0] 					alu_exe,

//Control signals
input [`IMM_SEL_WIDTH-1:0] 		imm_sel,
input 									br_unsign,
input [`A_SEL_WIDTH-1:0]			a_sel,
input [`B_SEL_WIDTH-1:0]			b_sel,
input [`ALU_OP_WIDTH-1:0]			alu_op,

output									br_true,

//Forwarding signals
input [`XLEN-1:0]						forward_alu,
input [`XLEN-1:0]						forward_mem
);

wire [`XLEN-1:0] signex_imm;
wire [`XLEN-1:0] alu_a;
wire [`XLEN-1:0] alu_b;
wire [`XLEN-1:0] alu_out;

	alu alu(alu_a, alu_b, alu_op, alu_out);

always @(*)
begin

	case(imm_sel)
		`IMM_SEL_I : signex_imm = { {21{instr_exe[31]}}, instr_exe[30:20] };
		`IMM_SEL_S : signex_imm = { {21{instr_exe[31]}}, instr_exe[30:25], instr_exe[11:7] };
		`IMM_SEL_B : signex_imm = { {20{instr_exe[31]}}, instr_exe[7], instr_exe[30:25], instr_exe[11:8], 1'b0};
		`IMM_SEL_J : signex_imm = { {12{instr_exe[31]}}, instr_exe[19:12], instr_exe[20], instr_exe[30:21], 1'b0};
		`IMM_SEL_U : signex_imm = { instr_exe[31:12], 12'b0 };
		default    : signex_imm = { {21{instr_exe[31]}}, instr_exe[30:20] };
	endcase
	
	case(a_sel)
		`A_SEL_RS1  : alu_a = rs1_exe;
		`A_SEL_PC   : alu_a = pc_exe;
		`A_SEL_ALU	: alu_a = forward_alu;
		`A_SEL_MEM	: alu_a = forward_mem;
		default     : alu_a = `XLEN'b0;
	endcase
	
	case(b_sel)
		`B_SEL_RS2  : alu_b = rs2_exe;
		`B_SEL_IMM  : alu_b = signex_imm;
		`B_SEL_FOUR : alu_b = `XLEN'd4;
		default     : alu_b = `XLEN'b0;
	endcase
	
	br_true = alu_out[0];
	alu_exe[`XLEN-1:0] = alu_out[`XLEN-1:0];
	
end

always_ff @(posedge clk)
begin

	instr_mem <= instr_exe;
	pc_mem <= pc_exe;
	rs2_mem <= rs2_exe;
	alu_mem <= alu_out;
	
end

endmodule
