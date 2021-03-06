//TODO:

`include "constants.vh"
module wb(

input clk,

//Data pipeline
//From MEM/WB
input [`XLEN-1:0]	alu_wb,
input [`XLEN-1:0]	mem_wb,

output logic [`XLEN-1:0]	reg_wb,

//Control signals
input[`WB_SEL_WIDTH-1:0]	wb_sel
);




always_comb
begin

	case(wb_sel)
		`WB_SEL_ALU : reg_wb = alu_wb;
		`WB_SEL_MEM : reg_wb = mem_wb;
		default	: reg_wb = alu_wb;
	endcase

end

endmodule
