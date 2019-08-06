//TODO:

`include "constants.vh"
module mem(
	
	input clk,
	input rst,
	
	//Data pipeline
	//From EXE/MEM
	input [`XLEN-1:0] instr_mem,
	input [`XLEN-1:0] alu_mem,
	
	//MEM/WB registers
	output reg [`XLEN-1:0] mem_wb,
	output reg [`XLEN-1:0] alu_wb,
	output reg [`XLEN-1:0] instr_wb,
	
	//Data memory signals
	input [`XLEN-1:0] mem_data,
	
	//Control signals
	input mem_wr,
	input mem_en,
	
	//Forwarding signals
	input [`REG_ADDR_WIDTH-1:0] rd_addr_mem,
	output reg [`REG_ADDR_WIDTH-1:0] rd_addr_wb
);

always_ff @(posedge clk, negedge rst)
begin
	if(!rst)
	begin
		instr_wb <= '0;
		rd_addr_wb <= '0;
		alu_wb <= '0;
		mem_wb <= '0;
	end
	else
	begin
		instr_wb <= instr_mem;
		rd_addr_wb <= rd_addr_mem;
		alu_wb <= alu_mem;
		mem_wb <= mem_data;
	end
end

endmodule
