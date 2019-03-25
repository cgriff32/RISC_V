`include "constants.vh"

module alu(

input [`REG_DATA_WIDTH-1:0]	a,
input [`REG_DATA_WIDTH-1:0] 	b,

input [`ALU_OP_WIDTH-1:0] 		alu_op,

output [`REG_DATA_WIDTH-1:0] 	out

);

wire [5:0] shamt = b[5:0];

always @(*)
begin

	case(alu_op)
        `ALU_OP_ADD  : out = a + b;								
        `ALU_OP_SLL  : out = a << shamt;
        `ALU_OP_XOR  : out = a ^ b;
        `ALU_OP_OR   : out = a | b;
        `ALU_OP_AND  : out = a & b;
        `ALU_OP_SRL  : out = a >> shamt;
        `ALU_OP_SEQ  : out = {31'b0, a == b};
        `ALU_OP_SNE  : out = {31'b0, a != b};
        `ALU_OP_SUB  : out = a - b;
        `ALU_OP_SRA  : out = $signed(a) >>> shamt;
        `ALU_OP_SLT  : out = {31'b0, $signed(a) < $signed(b)};	//Set less than
        `ALU_OP_SGE  : out = {31'b0, $signed(a) >= $signed(b)};	//Set greater than or equal
        `ALU_OP_SLTU : out = {31'b0, a < b};
        `ALU_OP_SGEU : out = {31'b0, a >= b};
		  default 	   : out = '0;
	endcase
end

endmodule
