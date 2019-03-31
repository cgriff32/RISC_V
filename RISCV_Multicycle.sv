//TODO:
//Control path
//Pipeline flush
//Branch Prediction


`include "constants.vh"
module RISCV_Multicycle(

	input 			clk,
	
	output [31:0] 	debug
	
);
//Pipeline registers
//Fetch/Decode
wire [`XLEN-1:0]					pc_decode;
wire [`XLEN-1:0]					instr_decode;

//Decode/Execute
wire [`XLEN-1:0]					pc_exe;
wire [`XLEN-1:0] 					rs1_exe;
wire [`XLEN-1:0] 					rs2_exe;
wire [`XLEN-1:0] 					instr_exe;
wire [`XLEN-1:0] 					imm_exe;

//Execute/Memory
wire [`XLEN-1:0]					pc_mem;
wire [`XLEN-1:0]					alu_mem;
wire [`XLEN-1:0]					rs2_mem;
wire [`XLEN-1:0]					instr_mem;

//Memory/Write Back
wire [`XLEN-1:0]					mem_wb;
wire [`XLEN-1:0]					instr_wb;

//Forward/Hazard/Branch signals
//From Decode
wire [`XLEN-1:0]  				br_decode;
wire [`XLEN-1:0]  				jal_decode;
wire [`XLEN-1:0]  				jalr_decode;

//Control Signals
//Input
//From Decode
wire									br_true;
wire [`ALU_OP_WIDTH-1:0]		br_op;

//Output
wire [`PC_SEL_WIDTH-1:0]		pc_sel;
wire [`IMM_SEL_WIDTH-1:0]		imm_sel;
wire [`B_SEL_WIDTH-1:0]			b_sel_exe; 
wire [`A_SEL_WIDTH-1:0]			a_sel_exe; 
wire [`ALU_OP_WIDTH-1:0]		alu_sel_exe; 
wire [`MEMRW_SEL_WIDTH-1:0]	mem_wr_mem;
wire [`MEMRW_SEL_WIDTH-1:0]	mem_en_mem;
wire [`WB_SEL_WIDTH-1:0] 		wb_sel_wb;
wire [`WB_SEL_WIDTH-1:0] 		reg_en_wb;

control control(	.clk(clk),
						.instr_decode(instr_decode),
						.br_true(br_true),
						.br_op(br_op),
						.pc_sel(pc_sel),
						.imm_sel(imm_sel),
						.b_sel_exe(b_sel_exe),
						.a_sel_exe(a_sel_exe),
						.alu_sel_exe(alu_sel_exe),
						.mem_wr_mem(mem_wr_mem),
						.mem_en_mem(mem_en_mem),
						.wb_sel_wb(wb_sel_wb),
						.reg_en_wb(reg_en_wb)
						);

fetch fetch(		.clk(clk),
						.br_decode(br_decode),
						.jal_decode(jal_decode),
						.jalr_decode(jalr_decode),
						.pc_decode(pc_decode), 
						.instr_decode(instr_decode), 
						.pc_sel(pc_sel)
						);

decode decode(		.clk(clk),
						.pc_decode(pc_decode), 
						.instr_decode(instr_decode), 
						.mem_wb(mem_wb),
						.instr_wb(instr_wb),
						.br_decode(br_decode),
						.jal_decode(jal_decode),
						.jalr_decode(jalr_decode),
						.pc_exe(pc_exe),
						.instr_exe(instr_exe),
						.rs1_exe(rs1_exe),
						.rs2_exe(rs2_exe),
						.imm_exe(imm_exe),
						.imm_sel(imm_sel),
						.reg_write_en(reg_en_wb),
						.br_op(br_op),
						.br_true(br_true)
						);
					

execute execute(	.clk(clk),
						.pc_exe(pc_exe),
						.rs1_exe(rs1_exe),
						.rs2_exe(rs2_exe),
						.instr_exe(instr_exe),
						.imm_exe(imm_exe),
						.pc_mem(pc_mem),
						.alu_mem(alu_mem),
						.rs2_mem(rs2_mem),
						.instr_mem(instr_mem),
						.a_sel(a_sel_exe),
						.b_sel(b_sel_exe),
						.alu_op(alu_sel_exe)
						);
						

mem mem(				.clk(clk),
						.pc_mem(pc_mem),
						.instr_mem(instr_mem),
						.alu_mem(alu_mem),
						.rs2_mem(rs2_mem),
						.mem_wb(mem_wb),
						.instr_wb(instr_wb),
						.mem_wr(mem_wr_mem),
						.mem_en(mem_en_mem),
						.wb_sel(wb_sel_wb)
						);
						
initial 
begin
	debug <= '0;
end

always_ff@(posedge clk)
begin
	debug <= debug + 1;
end
		
endmodule
