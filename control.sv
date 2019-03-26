//
`include "constants.vh"


module control(

input [`INSTR_WIDTH-1:0]		instr_decode,
input 								br_true,

output 								reg_write_en, 
output 								br_unsign, 
output 								b_sel, 
output 								a_sel, 
output 								alu_sel, 
output 								mem_write_en,
output [`PC_SEL_WIDTH-1:0]		pc_sel,
output [`WB_SEL_WIDTH-1:0] 	wb_sel,
output [`IMM_SEL_WIDTH-1:0]	imm_sel
);

wire[`OP_CODE_WIDTH-1:0]	opcode = instr_decode[6:0];
wire	 	 						funct7 = instr_decode[30];
wire[2:0] 						funct3 = instr_decode[14:12];



always @(*)
begin
	reg_write_en 	<= 0;
	br_unsign		<= 0;
	b_sel				<= 0;
	a_sel				<= 0;
	alu_sel			<= 0;
	mem_write_en	<= 0;
	pc_sel			<= '0;
	wb_sel			<= '0;
	imm_sel			<= '0;
	
	case(opcode)
	`OP_LUI : begin
	end
	`OP_AUIPC : begin
	end
	`OP_JAL : begin
	end
	`OP_JALR : begin
	end
	`OP_BRANCH : begin
	end
	`OP_LOAD : begin
	end
	`OP_STORE : begin
	end
	`OP_IMM : begin
	end
	`OP_R : begin
	end
	default : ; //stall
	endcase
	
end

endmodule
