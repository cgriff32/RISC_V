//TODO: Control signal pc_sel
//br_target from decode
//alu_exe from exe
`include "constants.vh"

module fetch(

input clk,

//Input signals
input [`XLEN-1:0] 					alu_exe,

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0]	pc_decode,
output reg [`REG_DATA_WIDTH-1:0]	instr_decode,

//Control signals
input [`PC_SEL_WIDTH-1:0]			pc_sel 
);

reg [`REG_DATA_WIDTH-1:0] 	pc;
wire [`REG_DATA_WIDTH-1:0]	w_pc;
wire [`REG_DATA_WIDTH-1:0]	instr;

imem imem(pc, 
			 instr);

initial 
begin
	pc <= `XLEN'b0;
	pc_decode <= `XLEN'b0;
	instr_decode <= `XLEN'b0;
end


always_ff @(posedge clk)
begin

	pc_decode <= pc;			//pc to decode stage
	instr_decode <= instr;	//instr to decode stage

	case(pc_sel)
		`PC_SEL_PLUS_FOUR : pc <= w_pc + `XLEN'd4;  	// PC+4
		`PC_SEL_BRANCH 	: pc <= alu_exe;    			// Take branch
		default 				: pc <= w_pc;					//Stall
	endcase

end

assign w_pc = pc;


endmodule
