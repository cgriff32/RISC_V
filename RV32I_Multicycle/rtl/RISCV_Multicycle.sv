//TODO:
//Branch Prediction


`include "constants.vh"
module RISCV_Multicycle(
	input clk,
	input rst,

	

	//To Mem
	output [`DMEM_WIDTH-1:0] dmem_addr,
	output [`XLEN-1:0] dmem_data_in,
	
	output  rden_dmem,
	output  wren_dmem,
	output [3:0] mem_byte_mem,
	input [`XLEN-1:0] dmem_data_out,
	
	
	output [`IMEM_WIDTH-1:0] pc_imem,
	input [`XLEN-1:0] imem_data_out,
	output rden_imem,
	
	output led 
	
);


//Pipeline registers
//Fetch/Decode
logic [`XLEN-1:0] pc_decode;
logic [`XLEN-1:0] instr_decode;

//Decode/Execute
logic [`XLEN-1:0] pc_exe;
logic [`XLEN-1:0] rs1_data_exe;
logic [`XLEN-1:0] rs2_data_exe;
logic [`XLEN-1:0] instr_exe;
logic [`XLEN-1:0] imm_exe;

//Execute/Memory
logic [`XLEN-1:0] pc_mem;
logic [`XLEN-1:0] alu_mem;
logic [`XLEN-1:0] instr_mem;
logic [`XLEN-1:0] rs2_data_mem;
logic [`XLEN-1:0] mem_data;

//Memory/Write Back
logic [`XLEN-1:0] mem_wb;
logic [`XLEN-1:0] alu_wb;
logic [`XLEN-1:0] reg_wb;
logic [`XLEN-1:0] instr_wb;
logic mem_wr_mem;
logic mem_en_mem;

//Branch signals
//From Decode
logic [`XLEN-1:0] br_decode;
logic [`XLEN-1:0] jal_decode;
logic [`XLEN-1:0] jalr_decode;

//Control Signals
	//Input
//From Decode
logic br_true;

//Output
//To Fetch
logic [`PC_SEL_WIDTH-1:0] pc_sel;

//To Decode
logic [`ALU_OP_WIDTH-1:0] br_op;
logic [`IMM_SEL_WIDTH-1:0] imm_sel;

//To Execute
logic [`B_SEL_WIDTH-1:0] b_sel_exe; 
logic [`A_SEL_WIDTH-1:0] a_sel_exe; 
logic [`ALU_OP_WIDTH-1:0] alu_sel_exe; 

//To WB
logic [`WB_SEL_WIDTH-1:0] wb_sel_wb;
logic [`WB_SEL_WIDTH-1:0] reg_en_wb;

//Forwarding/Hazard detection
	//Input
//From Execute
logic [`REG_ADDR_WIDTH-1:0] rs1_addr_exe;
logic [`REG_ADDR_WIDTH-1:0] rs2_addr_exe;
logic [`REG_ADDR_WIDTH-1:0] rd_addr_exe;

//From Mem
logic [`REG_ADDR_WIDTH-1:0] rd_addr_mem;

//From WB
logic [`REG_ADDR_WIDTH-1:0] rd_addr_wb;

//Output
//To Fetch
logic flush_if;
logic stall_if;
logic flush_id;

//To Decode
logic [`FORWARD_SEL_WIDTH-1:0] branch_a_sel;
logic [`FORWARD_SEL_WIDTH-1:0] branch_b_sel;

//To Execute
logic [`FORWARD_SEL_WIDTH-1:0] forward_a_sel;
logic [`FORWARD_SEL_WIDTH-1:0] forward_b_sel;

logic temp;


control control(
	.clk(clk),
	.rst(rst),
	.led(led),
	//Control signals
	//From Decode
	.instr_decode(instr_decode),
	.br_true(br_true),
	//To Fetch
	.pc_sel(pc_sel),
	//To Decode
	.imm_sel(imm_sel),
	.br_op(br_op),
	//Control pipeline
	//ID/EXE registers
	.b_sel_exe(b_sel_exe),
	.a_sel_exe(a_sel_exe),
	.alu_sel_exe(alu_sel_exe),
	//EXE/MEM registers
	.mem_wr_mem(mem_wr_mem),
	.mem_en_mem(mem_en_mem),
	.mem_byte_mem(mem_byte_mem),
	.rden_dmem(rden_dmem),
	.wren_dmem(wren_dmem),
	//MEM/WB registers
	.wb_sel_wb(wb_sel_wb),
	.reg_en_wb(reg_en_wb),
	//Forwarding/Hazard detection
	//From Execute
	.rs1_addr_exe(rs1_addr_exe),
	.rs2_addr_exe(rs2_addr_exe),
	.rd_addr_exe(rd_addr_exe),
	//From Mem
	.rd_addr_mem(rd_addr_mem),
	//From WB
	.rd_addr_wb(rd_addr_wb),
	//Hazard control
	//To Decode
	.flush_if(flush_if),
	.stall_if(stall_if),
	.flush_id(flush_id),
	//Forwarding control
	//To Execute
	.forward_a_sel(forward_a_sel),
	.forward_b_sel(forward_b_sel),
	.branch_a_sel(branch_a_sel),
	.branch_b_sel(branch_b_sel)
);



fetch fetch(
	.clk(clk),
	.rst(rst),
	//Data pipeline
	//IF/ID registers
	.pc_decode(pc_decode), 
	.instr_decode(instr_decode), 
	//Instruction memory signals
	.pc_imem(pc_imem),
	.instr_imem(imem_data_out),
	.rden_imem(temp),
	//Control signals
	//From Decode
	.pc_sel(pc_sel),
	.br_decode(br_decode),
	.jal_decode(jal_decode),
	.jalr_decode(jalr_decode),
	//Hazard control
	.flush_if(flush_if),
	.stall_if(stall_if)
);

assign rden_imem = temp;

decode decode(
	.clk(clk),
	.rst(rst),
	//Data pipeline
	//From IF/ID
	.pc_decode(pc_decode), 
	.instr_decode(instr_decode), 
	//From MEM/WB
	.mem_wb(reg_wb),
	.instr_wb(instr_wb),
	//ID/EXE registers
	.pc_exe(pc_exe),
	.instr_exe(instr_exe),
	.rs1_data_exe(rs1_data_exe),
	.rs2_data_exe(rs2_data_exe),
	.imm_exe(imm_exe),
	.rs1_addr_exe(rs1_addr_exe),
	.rs2_addr_exe(rs2_addr_exe),
	.rd_addr_exe(rd_addr_exe),
	//Control signals
	//Input
	.imm_sel(imm_sel),
	.reg_write_en(reg_en_wb),
	.br_op(br_op),
	//Forwarding control
	.branch_a_sel(branch_a_sel),
	.branch_b_sel(branch_b_sel),
	.forward_mem(alu_mem),
	.forward_wb(reg_wb),
	//Branch control
	.br_decode(br_decode),
	.jal_decode(jal_decode),
	.jalr_decode(jalr_decode),
	.br_true(br_true),
	.flush_id(flush_id)
);


execute execute(
	.clk(clk),
	.rst(rst),
	//Data pipeline
	//From ID/EXE
	.pc_exe(pc_exe),
	.rs1_exe(rs1_data_exe),
	.rs2_exe(rs2_data_exe),
	.instr_exe(instr_exe),
	.imm_exe(imm_exe),
	//EXE/MEM registers
	.pc_mem(pc_mem),
	.alu_mem(alu_mem),
	.rs2_mem(rs2_data_mem),
	.instr_mem(instr_mem),
	//Data memory signals
	.dmem_addr(dmem_addr),
	.dmem_data(dmem_data_in),
	//Control pipeline
	//From ID/EXE
	.a_sel(a_sel_exe),
	.b_sel(b_sel_exe),
	.alu_op(alu_sel_exe),
	//Forwarding control
	.rd_addr_exe(rd_addr_exe),
	.rd_addr_mem(rd_addr_mem),
	.forward_a_sel(forward_a_sel),
	.forward_b_sel(forward_b_sel),
	.forward_mem(alu_mem),
	.forward_wb(reg_wb)
);

mem mem(
	.clk(clk),
	.rst(rst),
	//Data pipeline
	//From EXE/MEM
	.instr_mem(instr_mem),
	.alu_mem(alu_mem),
	//MEM/WB resigsters
	.mem_wb(mem_wb),
	.alu_wb(alu_wb),
	.instr_wb(instr_wb),
	//Data memory signals
	.dmem_data(dmem_data_out),
	//Control pipeline
	//From EXE/MEM
	.mem_wr(mem_wr_mem),
	.mem_en(mem_en_mem),
	//Forwarding control
	.rd_addr_mem(rd_addr_mem),
	.rd_addr_wb(rd_addr_wb)
);

wb wb(
	.clk(clk),
	//Data pipeline
	//From MEM/WB
	.alu_wb(alu_wb),
	.mem_wb(mem_wb),
	.reg_wb(reg_wb),
	//Control signals
	.wb_sel(wb_sel_wb)
);

endmodule
