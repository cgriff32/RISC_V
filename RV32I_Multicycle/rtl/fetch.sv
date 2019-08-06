//TODO:

`include "constants.vh"

module fetch(
	
	input clk,
	input rst,
	
	//IF/ID registers
	output reg [`REG_DATA_WIDTH-1:0] pc_decode,
	output reg [`REG_DATA_WIDTH-1:0] instr_decode,
	
	//Instruction memory signals
	output [`XLEN-1:0] pc_imem,
	input [`XLEN-1:0] instr_imem,
	
	//Control signals
	input [`PC_SEL_WIDTH-1:0] pc_sel,
	input [`XLEN-1:0] br_decode,
	input [`XLEN-1:0] jal_decode,
	input [`XLEN-1:0] jalr_decode,
	
	//Hazard control
	input stall_if,
	input flush_if
);

reg [`REG_DATA_WIDTH-1:0] pc = `XLEN'b0;
wire [`REG_DATA_WIDTH-1:0] instr;
logic [`XLEN-1:0] pc_wire;

assign pc_imem = pc;

always_comb
begin
	
	case(pc_sel)
		`PC_SEL_BRANCH : pc_wire = br_decode;
		`PC_SEL_JAL : pc_wire = jal_decode;
		`PC_SEL_JALR : pc_wire = jalr_decode;
		default: pc_wire = pc + `XLEN'd4;
	endcase
	
end

always_ff @(posedge clk, negedge rst)
begin
	if(!rst)
	begin
		pc_decode <= '0;
		instr_decode <= '0;
		pc <= '0;
	end
	else
	begin
		if(stall_if)
		begin
			pc_decode <= pc_decode;
			pc <= pc;
		end
		else if(flush_if)
		begin
			pc_decode <= '0;
			pc  <= pc_wire;
			instr_decode<= '0;
		end
		else 
		begin
			pc_decode <= pc;//pc to decode stage
			pc  <= pc_wire;
			instr_decode <= instr_imem;//instr to decode stage
		end
	end
end

endmodule
