`timescale 1ns/1ns
`include "constants.vh"

module fetch_tb;

	logic clk;
	
	logic [`REG_DATA_WIDTH-1:0] pc_decode;
	logic [`REG_DATA_WIDTH-1:0] instr_decode;
	
	logic [`XLEN-1:0] pc_imem;
	logic [`XLEN-1:0] instr_imem;
	
	logic [`PC_SEL_WIDTH-1:0] pc_sel;
	logic [`XLEN-1:0] br_decode;
	logic [`XLEN-1:0] jal_decode;
	logic [`XLEN-1:0] jalr_decode;
	
	logic stall_if;
	logic flush_if;
	
fetch DUT(		.clk(clk),
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
initial
begin
  #5
  
  pc_sel <= `PC_SEL_FOUR;
  br_decode <= 32'd4;
  jal_decode <= 32'd16;
  jalr_decode <= 32'd64;
  stall_if <= 0;
  flush_if <= 0;
  
  #10;

  
  #10;
  #10;
  stall_if <= 1;
  #10;
  stall_if <= 0;
  
  
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule
