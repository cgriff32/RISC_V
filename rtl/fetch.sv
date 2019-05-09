//TODO:


`include "constants.vh"

module fetch(

input clk,

//IF/ID registers
output reg [`REG_DATA_WIDTH-1:0]	pc_decode,
output reg [`REG_DATA_WIDTH-1:0]	instr_decode,

//Instruction memory signals
output [`XLEN-1:0]					pc_imem,
input [`XLEN-1:0]						instr_imem,

//Control signals
input [`PC_SEL_WIDTH-1:0]			pc_sel,
input [`XLEN-1:0]						br_decode,
input [`XLEN-1:0]						jal_decode,
input [`XLEN-1:0]						jalr_decode,

//Hazard control
input										stall_if,
input										flush_if
);

reg [`REG_DATA_WIDTH-1:0] 	pc = `XLEN'b0;
wire [`REG_DATA_WIDTH-1:0]	instr;
logic [`XLEN-1:0]				pc_wire;


reg base;
wire offset;

initial
  begin
    pc_decode <= '0;
    instr_decode <= '0;
end

assign pc_imem = pc;

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

always_ff @(posedge clk)
begin

	if(stall_if)
	begin
	  pc_decode <= pc_decode;
	  pc <= pc;
		//instr_decode	<= '0;
	end
	else if(flush_if)
	begin
		pc_decode 		<= '0;
		pc 			 <= pc_wire;
		instr_decode	<= '0;
	end
	else 
	begin
		pc_decode	 <= pc;		//pc to decode stage
		pc 			 <= pc_wire;
		instr_decode <= instr_imem;	//instr to decode stage
	end
	
end



endmodule