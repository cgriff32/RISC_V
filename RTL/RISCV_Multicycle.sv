//TODO:
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

//Instruction memory signals
wire [`XLEN-1:0] 					pc_imem;
wire [`XLEN-1:0] 					instr_imem;

//Decode/Execute
wire [`XLEN-1:0]					pc_exe;
wire [`XLEN-1:0] 					rs1_data_exe;
wire [`XLEN-1:0] 					rs2_data_exe;
wire [`XLEN-1:0] 					instr_exe;
wire [`XLEN-1:0] 					imm_exe;

//Execute/Memory
wire [`XLEN-1:0]					pc_mem;
wire [`XLEN-1:0]					alu_mem;
wire [`XLEN-1:0]					rs2_data_mem;
wire [`XLEN-1:0]					instr_mem;

//Data memory signals
wire [`XLEN-1:0] 					mem_data;

//Memory/Write Back
wire [`XLEN-1:0]					mem_wb;
wire [`XLEN-1:0]					alu_wb;
wire [`XLEN-1:0]					reg_wb;
wire [`XLEN-1:0]					instr_wb;

//Branch signals
//From Decode
wire [`XLEN-1:0]  				br_decode;
wire [`XLEN-1:0]  				jal_decode;
wire [`XLEN-1:0]  				jalr_decode;

//Control Signals
//Input
//From Decode
wire									br_true;

//Output
//To Fetch
wire [`PC_SEL_WIDTH-1:0]		pc_sel;

//To Decode
wire [`ALU_OP_WIDTH-1:0]		br_op;
wire [`IMM_SEL_WIDTH-1:0]		imm_sel;

//To Execute
wire [`B_SEL_WIDTH-1:0]			b_sel_exe; 
wire [`A_SEL_WIDTH-1:0]			a_sel_exe; 
wire [`ALU_OP_WIDTH-1:0]		alu_sel_exe; 

//To Mem
wire [`MEMRW_SEL_WIDTH-1:0]	mem_wr_mem;
wire [`MEMRW_SEL_WIDTH-1:0]	mem_en_mem;

//To WB
wire [`WB_SEL_WIDTH-1:0] 		wb_sel_wb;
wire [`WB_SEL_WIDTH-1:0] 		reg_en_wb;

//Forwarding/Hazard detection
//Input
//From Execute
wire [`REG_ADDR_WIDTH-1:0]		rs1_addr_exe;
wire [`REG_ADDR_WIDTH-1:0]		rs2_addr_exe;
wire [`REG_ADDR_WIDTH-1:0]		rd_addr_exe;

//From Mem
wire [`REG_ADDR_WIDTH-1:0]		rd_addr_mem;

//From WB
wire [`REG_ADDR_WIDTH-1:0]		rd_addr_wb;

//Output
//To Fetch
wire									flush_if;
wire									stall_if;

//To Execute
wire [`FORWARD_SEL_WIDTH-1:0]	forward_a_sel;
wire [`FORWARD_SEL_WIDTH-1:0]	forward_b_sel;

control control(	.clk(clk),
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
						//Forwarding control
						//To Execute
						.forward_a_sel(forward_a_sel),
						.forward_b_sel(forward_b_sel)
						);

fetch fetch(		.clk(clk),
						//Data pipeline
						//IF/ID registers
						.pc_decode(pc_decode), 
						.instr_decode(instr_decode), 
						//Instruction memory signals
						.pc_imem(pc_imem),
						.instr_imem(instr_imem),
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
						
imem imem(			.pc(pc_imem), 
						.instr(instr_imem)
						);

decode decode(		.clk(clk),			
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
						//Branch control
						.br_decode(br_decode),
						.jal_decode(jal_decode),
						.jalr_decode(jalr_decode),
						.br_true(br_true)
						);
					

execute execute(	.clk(clk),
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
						//Control pipeline
						//From ID/EXE
						.a_sel(a_sel_exe),
						.b_sel(b_sel_exe),
						.alu_op(alu_sel_exe),
						//Forwarding control
						.rd_addr_exe(rd_addr_exe),
						.rd_addr_mem(rd_addr_mem),
						.forward_mem(alu_mem),
						.forward_wb(reg_wb)
						);
						

mem mem(				.clk(clk),
						//Data pipeline
						//From EXE/MEM
						.pc_mem(pc_mem),
						.instr_mem(instr_mem),
						.alu_mem(alu_mem),
						.rs2_mem(rs2_data_mem),
						//MEM/WB resigsters
						.mem_wb(mem_wb),
						.alu_wb(alu_wb),
						.instr_wb(instr_wb),
						//Data memory signals
						.mem_data(mem_data),
						//Control pipeline
						//From EXE/MEM
						.mem_wr(mem_wr_mem),
						.mem_en(mem_en_mem),
						//Forwarding control
						.rd_addr_mem(rd_addr_mem),
						.rd_addr_wb(rd_addr_wb)
						);
						
						
dmem dmem(			.clk(clk), 
						.mem_addr(alu_mem), 
						.mem_write_data(rs2_data_mem), 
						.mem_read_data(mem_data), 
						.write_en(mem_wr_mem), 
						.mem_en(mem_en_mem)
						);
						
wb wb(				.clk(clk),
          //Data pipeline
          //From MEM/WB
					.alu_wb(alu_wb),
					.mem_wb(mem_wb),
					.reg_wb(reg_wb),
					//Control signals
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
