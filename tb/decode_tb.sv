`timescale 1ns/1ns
`include "constants.vh"

module decode_tb;

	logic clk;

//Data pipeline
//From IF/ID
logic	[`XLEN-1:0] 					pc_decode; 
logic	[`XLEN-1:0]						instr_decode;

//From MEM/WB
logic [`XLEN-1:0] 					mem_wb;
logic [`XLEN-1:0] 					instr_wb; 

//ID/EXE registers
logic [`REG_DATA_WIDTH-1:0]	pc_exe; 
logic [`REG_DATA_WIDTH-1:0]	instr_exe;
logic [`REG_DATA_WIDTH-1:0]	rs1_data_exe;
logic [`REG_DATA_WIDTH-1:0]	rs2_data_exe;
logic [`REG_DATA_WIDTH-1:0] imm_exe;

logic [`REG_ADDR_WIDTH-1:0]	rs1_addr_exe;
logic [`REG_ADDR_WIDTH-1:0]	rs2_addr_exe;
logic [`REG_ADDR_WIDTH-1:0]	rd_addr_exe;

//Control signals
//Input
logic [`IMM_SEL_WIDTH-1:0] 		imm_sel;
logic 									reg_write_en;
logic [`ALU_OP_WIDTH-2:0]			br_op;

//Branch control
logic [`XLEN-1:0] 					br_decode;
logic [`XLEN-1:0] 					jal_decode;
logic [`XLEN-1:0] 					jalr_decode;
logic									     br_true;
	

decode DUT(		.clk(clk),			
						//Data pipeline			
						//From IF/ID
						.pc_decode(pc_decode), 
						.instr_decode(instr_decode), 
						//From MEM/WB
						.mem_wb(mem_wb),
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
						.reg_write_en(reg_write_en),
						.br_op(br_op),
						//Branch control
						.br_decode(br_decode),
						.jal_decode(jal_decode),
						.jalr_decode(jalr_decode),
						.br_true(br_true)
						);
initial
begin
  
  pc_decode <= '0;
  instr_decode <= 32'b01010101010101010101010101010101;
  mem_wb <= '0;
  instr_wb <= '0;
  imm_sel <= `IMM_SEL_I;
  reg_write_en <= '0;
  br_op <= '0;
  
  #5;
  
  reg_write_en <= '1;
  instr_wb [11:7] <= 5'b01010;
  mem_wb <= '1;
  imm_sel <= `IMM_SEL_S;
  #10;
  imm_sel <= `IMM_SEL_B;
  #10;
  imm_sel <= `IMM_SEL_J;
   #10;
  imm_sel <= `IMM_SEL_U;
  
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
