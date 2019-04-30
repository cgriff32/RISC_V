`timescale 1ns/1ns
`include "constants.vh"

module memory_tb;

	logic clk;

//Data pipeline
//From EXE/MEM
logic [`XLEN-1:0]						pc_mem; 
logic [`XLEN-1:0]						instr_mem;
logic [`XLEN-1:0]						alu_mem;
logic [`XLEN-1:0] 					rs2_mem;

//MEM/WB registers
logic [`REG_DATA_WIDTH-1:0]	mem_wb;
logic [`REG_DATA_WIDTH-1:0]	alu_wb;
logic  [`REG_DATA_WIDTH-1:0] instr_wb;

//Data memory signals
logic [`XLEN-1:0]						mem_data;

//Control signals
logic										mem_wr;
logic										mem_en;

//Forwarding signals
logic [`REG_ADDR_WIDTH-1:0]		rd_addr_mem;
logic [`REG_ADDR_WIDTH-1:0]	rd_addr_wb;
	
mem DUT(				.clk(clk),
						//Data pipeline
						//From EXE/MEM
						.pc_mem(pc_mem),
						.instr_mem(instr_mem),
						.alu_mem(alu_mem),
						.rs2_mem(rs2_mem),
						//MEM/WB resigsters
						.mem_wb(mem_wb),
						.alu_wb(alu_wb),
						.instr_wb(instr_wb),
						//Data memory signals
						.mem_data(mem_data),
						//Control pipeline
						//From EXE/MEM
						.mem_wr(mem_wr),
						.mem_en(mem_en),
						//Forwarding control
						.rd_addr_mem(rd_addr_mem),
						.rd_addr_wb(rd_addr_wb)
						);
						
						
dmem dmem(			.clk(clk), 
						.mem_addr(alu_mem), 
						.mem_write_data(rs2_mem), 
						.mem_read_data(mem_data), 
						.write_en(mem_wr), 
						.mem_en(mem_en)
						);

initial
begin
  
  pc_mem <= '0;
  instr_mem <= '0;
  alu_mem <= '0;
  rs2_mem <= '1;
  mem_wr <= '0;
  mem_en <= '0;
  rd_addr_mem <= '0;
  
  #5;
  
  mem_en <= '1;
  mem_wr <= '1;
  
  #10;
  
  mem_wr <= '0;
  
  
  
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule


