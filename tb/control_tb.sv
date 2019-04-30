`timescale 1ns/1ns
`include "constants.vh"

module control_tb;

	logic clk;

//Control inputs
//From Decode
logic [`INSTR_WIDTH-1:0]			instr_decode;
logic 									br_true;

//Control outputs
//To Fetch
logic [`PC_SEL_WIDTH-1:0]			pc_sel;

//To Decode
logic [`IMM_SEL_WIDTH-1:0]		imm_sel;
logic [`ALU_OP_WIDTH-1:0]			br_op;

//ID/EX registers
logic [`B_SEL_WIDTH-1:0]		b_sel_exe; 
logic [`A_SEL_WIDTH-1:0]		a_sel_exe; 
logic [`ALU_OP_WIDTH-1:0]	alu_sel_exe;

//EX/MEM registers
logic								mem_wr_mem;
logic								mem_en_mem;

//MEM/WB registers
logic [`WB_SEL_WIDTH-1:0] 	wb_sel_wb;
logic								reg_en_wb;

//Forwarding/Hazard detection inputs
//From Execute
logic [`REG_ADDR_WIDTH-1:0]		rs1_addr_exe;
logic [`REG_ADDR_WIDTH-1:0]		rs2_addr_exe;
logic [`REG_ADDR_WIDTH-1:0]		rd_addr_exe;

//From Mem
logic [`REG_ADDR_WIDTH-1:0]		rd_addr_mem;

//From WB
logic [`REG_ADDR_WIDTH-1:0]		rd_addr_wb;

//Hazard control (Decode)
logic 									flush_if;
logic									stall_if;

//Forwarding control (Execute)
logic [`FORWARD_SEL_WIDTH-1:0]	forward_a_sel;
logic [`FORWARD_SEL_WIDTH-1:0]	forward_b_sel;


control DUT(	.clk(clk),
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

initial
begin
  
  instr_decode <= '0;
  br_true <= '0;
  rs1_addr_exe <= '0;
  rs2_addr_exe <= '0;
  rd_addr_exe <= '0;
  rd_addr_mem <= '0;
  rd_addr_wb <= '0;
  
  #5;
  
  #10;
  
  
  
  
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule




