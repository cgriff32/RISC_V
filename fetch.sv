//TODO: Move imem to core
`include "constants.vh"

module fetch(

input clk,

//Input signals
input [`XLEN-1:0]						br_decode,
input [`XLEN-1:0]						jal_decode,
input [`XLEN-1:0]						jalr_decode,


//Next stage registers
output reg [`REG_DATA_WIDTH-1:0]	pc_decode,
output reg [`REG_DATA_WIDTH-1:0]	instr_decode,

//Control signals
input [`PC_SEL_WIDTH-1:0]			pc_sel,

input										stall_if,
input										flush_if
);

reg [`REG_DATA_WIDTH-1:0] 	pc;
wire [`REG_DATA_WIDTH-1:0]	instr;
wire [`XLEN-1:0]				pc_wire;


reg base;
wire offset;

imem imem(pc, 
			 instr);

always_comb
begin
	
	case(pc_sel)
		`PC_SEL_BRANCH 	: begin
			pc_wire = br_decode;
		end   					
		`PC_SEL_JAL : begin
			pc_wire = jal_decode;
		end		
		`PC_SEL_JALR : begin
			pc_wire = jalr_decode;
		end
		default		: begin
			pc_wire = pc + `XLEN'd4;
		end
	endcase
	
end

always_comb
begin

	if(flush_if)
	begin
		pc_decode 		= pc;
		instr_decode 	= '0;
	end
	else
	begin
		pc_decode 		= pc;		//pc to decode stage
		instr_decode	= instr;	//instr to decode stage
	end
	
end

always_ff @(posedge clk)
begin

	if(!stall_if)
		pc <= pc_wire;
	
end



endmodule
