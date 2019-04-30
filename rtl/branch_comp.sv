`include "constants.vh"

module branch_comp(

input [`XLEN-1:0]				a,
input [`XLEN-1:0] 			b,

input [`ALU_OP_WIDTH-2:0]	br_op,

output logic out
);


always_comb
begin

	case(br_op)
        `ALU_OP_SEQ  : out = {a == b};
        `ALU_OP_SNE  : out = {a != b};
        `ALU_OP_SLT  : out = {$signed(a) < $signed(b)};	//Set less than
        `ALU_OP_SGE  : out = {$signed(a) >= $signed(b)};	//Set greater than or equal
        `ALU_OP_SLTU : out = {a < b};
        `ALU_OP_SGEU : out = {a >= b};
		  default 	   : out = 1'b0;
	endcase
end

endmodule
