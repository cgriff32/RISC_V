//
`include "constants.vh"

module execute(
	
	input clk,
	input rst,
	
	//Data pipeline
	//From ID/EXE
	input [`XLEN-1:0] pc_exe,
	input [`XLEN-1:0] rs1_exe,
	input [`XLEN-1:0] rs2_exe,
	input [`XLEN-1:0] instr_exe,
	input [`XLEN-1:0] imm_exe,
	
	//EXE/MEM registers
	output reg [`REG_DATA_WIDTH-1:0] pc_mem,
	output reg [`REG_DATA_WIDTH-1:0] alu_mem,
	output reg [`REG_DATA_WIDTH-1:0] rs2_mem,
	output reg [`REG_DATA_WIDTH-1:0] instr_mem,
	
	//Control pipelin
	//From ID/EXE
	input [`A_SEL_WIDTH-1:0] a_sel,
	input [`B_SEL_WIDTH-1:0] b_sel,
	input [`ALU_OP_WIDTH-1:0] alu_op,
	
	//Forwarding control
	input [`REG_ADDR_WIDTH-1:0] rd_addr_exe,
	output reg [`REG_ADDR_WIDTH-1:0] rd_addr_mem,
	input [`FORWARD_SEL_WIDTH-1:0]  forward_a_sel,
	input [`FORWARD_SEL_WIDTH-1:0]  forward_b_sel,
	input [`XLEN-1:0] forward_mem,
	input [`XLEN-1:0] forward_wb
);

logic [`XLEN-1:0] alu_a;
logic [`XLEN-1:0] alu_b;
logic [`XLEN-1:0] forward_b;
logic [`XLEN-1:0] alu_out;

alu alu(
	alu_a, 
	alu_b, 
	alu_op, 
	alu_out
);

always_comb
begin
	case(forward_a_sel)
		`FORWARD_SEL_EXE : 
		begin
			case(a_sel)
				`A_SEL_RS1 : alu_a = rs1_exe;
				`A_SEL_PC : alu_a = pc_exe;
				`A_SEL_ZERO : alu_a = `XLEN'b0;
				default : alu_a = `XLEN'b0;
			endcase
		end
		`FORWARD_SEL_MEM : alu_a = forward_mem;
		`FORWARD_SEL_WB : alu_a = forward_wb;
		default : alu_a = `XLEN'b0;
	endcase
	
	case(forward_b_sel)
		`FORWARD_SEL_EXE : forward_b = rs2_exe;
		`FORWARD_SEL_MEM : forward_b = forward_mem;
		`FORWARD_SEL_WB : forward_b = forward_wb;
		default : forward_b = rs2_exe;
		
	endcase
	case(b_sel)
		`B_SEL_RS2 : alu_b = forward_b;
		`B_SEL_IMM : alu_b = imm_exe;
		`B_SEL_FOUR : alu_b = `XLEN'd4;
		`B_SEL_ZERO : alu_b = `XLEN'b0;
		default : alu_b = forward_b;
	endcase
end

always_ff @(posedge clk, negedge rst)
begin
	if(!rst)
	begin
		instr_mem <= '0;
		pc_mem <= '0;
		rs2_mem <= '0;
		alu_mem <= '0;
		rd_addr_mem <= '0;
	end
	else
	begin
		instr_mem <= instr_exe;
		pc_mem <= pc_exe;
		rs2_mem <= forward_b;
		alu_mem <= alu_out;
		rd_addr_mem <= rd_addr_exe;
	end
end

endmodule
