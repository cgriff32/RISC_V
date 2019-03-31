`include "constants.vh"

module branch_comp(

input [`XLEN-1:0]				a,
input [`XLEN-1:0] 			b,

input [`ALU_OP_WIDTH-2:0]	br_op,

output [`XLEN-1:0] 			out
);


always_comb
begin

	case(br_op)
        `ALU_OP_SEQ  : out = {31'b0, a == b};
        `ALU_OP_SNE  : out = {31'b0, a != b};
        `ALU_OP_SLT  : out = {31'b0, $signed(a) < $signed(b)};	//Set less than
        `ALU_OP_SGE  : out = {31'b0, $signed(a) >= $signed(b)};	//Set greater than or equal
        `ALU_OP_SLTU : out = {31'b0, a < b};
        `ALU_OP_SGEU : out = {31'b0, a >= b};
		  default 	   : out = 32'b0;
	endcase
end

endmodule
