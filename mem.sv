//TODO: Move dmem to core

`include "constants.vh"
module mem(

input clk,

//Input signals
input [`XLEN-1:0]						pc_mem, 
input [`XLEN-1:0]						instr_mem,
input [`XLEN-1:0]						alu_mem,
input [`XLEN-1:0] 					rs2_mem,

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0]	mem_wb,
output reg [`REG_DATA_WIDTH-1:0] instr_wb,

//Control signals
input										mem_wr,
input										mem_en,
input[`WB_SEL_WIDTH-1:0] 			wb_sel
);

wire[`XLEN-1:0] 			mem_data;

dmem dmem(clk, alu_mem, rs2_mem, mem_data, mem_wr, mem_en);

always_ff @(posedge clk)
begin

	instr_wb <= instr_mem;

	case(wb_sel)
		`WB_SEL_PC 	: mem_wb <= pc_mem + 32'd4;
		`WB_SEL_ALU : mem_wb <= alu_mem;
		`WB_SEL_MEM : mem_wb <= mem_data;
	endcase
	
end

endmodule
