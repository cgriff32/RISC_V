//Constant.vh

// Width-related constants

`define INSTR_WIDTH     32
`define XLEN				32
`define OP_CODE_WIDTH	7
`define REG_DATA_WIDTH	32
`define REG_ADDR_WIDTH 	5
`define REG_FILE_SIZE	32
`define SHAMT_WIDTH     5

// Opcodes

`define OP_NOP 	7'b0010011

`define OP_LUI		7'b0110111
`define OP_AUIPC	7'b0010111
`define OP_JAL		7'b1101111
`define OP_JALR	7'b1100111
`define OP_BRANCH	7'b1100011
`define OP_LOAD	7'b0000011
`define OP_STORE	7'b0100011
`define OP_IMM 	7'b0010011
`define OP_R		7'b0110011

// ALU FUNCT3 encodings

`define FUNCT3_ADD_SUB	0
`define FUNCT3_SLL     	1
`define FUNCT3_SLT     	2
`define FUNCT3_SLTU    	3
`define FUNCT3_XOR     	4
`define FUNCT3_SRA_SRL 	5
`define FUNCT3_OR      	6
`define FUNCT3_AND     	7

// Branch FUNCT3 encodings

`define FUNCT3_BEQ	0
`define FUNCT3_BNE  	1
`define FUNCT3_BLT  	4
`define FUNCT3_BGE  	5
`define FUNCT3_BLTU 	6
`define FUNCT3_BGEU 	7

// ALU Funct Codes

`define ALU_OP_WIDTH 4

`define ALU_OP_SEQ  `ALU_OP_WIDTH'd0
`define ALU_OP_SNE  `ALU_OP_WIDTH'd1
`define ALU_OP_SLT  `ALU_OP_WIDTH'd2
`define ALU_OP_SLTU `ALU_OP_WIDTH'd3
`define ALU_OP_SGE  `ALU_OP_WIDTH'd4
`define ALU_OP_SGEU `ALU_OP_WIDTH'd5
`define ALU_OP_SRL  `ALU_OP_WIDTH'd6
`define ALU_OP_SRA  `ALU_OP_WIDTH'd7
`define ALU_OP_ADD  `ALU_OP_WIDTH'd8
`define ALU_OP_SUB  `ALU_OP_WIDTH'd9
`define ALU_OP_SLL  `ALU_OP_WIDTH'd10
`define ALU_OP_XOR  `ALU_OP_WIDTH'd11
`define ALU_OP_OR   `ALU_OP_WIDTH'd12
`define ALU_OP_AND  `ALU_OP_WIDTH'd13


//pc_sel

`define PC_SEL_WIDTH 		2
`define PC_SEL_JAL			`PC_SEL_WIDTH'd0
`define PC_SEL_JALR			`PC_SEL_WIDTH'd1
`define PC_SEL_BRANCH 		`PC_SEL_WIDTH'd2
`define PC_SEL_FOUR			`PC_SEL_WIDTH'd3

//imm_sel

`define IMM_SEL_WIDTH 	3
`define IMM_SEL_I			`IMM_SEL_WIDTH'd0
`define IMM_SEL_S			`IMM_SEL_WIDTH'd1
`define IMM_SEL_B			`IMM_SEL_WIDTH'd2
`define IMM_SEL_J			`IMM_SEL_WIDTH'd3
`define IMM_SEL_U			`IMM_SEL_WIDTH'd4

//a_sel

`define A_SEL_WIDTH 	3
`define A_SEL_RS1		`A_SEL_WIDTH'd0
`define A_SEL_PC		`A_SEL_WIDTH'd1
`define A_SEL_ALU		`A_SEL_WIDTH'd2
`define A_SEL_MEM		`A_SEL_WIDTH'd3
`define A_SEL_ZERO	`A_SEL_WIDTH'd4

//b_sel

`define B_SEL_WIDTH 	3
`define B_SEL_RS2		`B_SEL_WIDTH'd0
`define B_SEL_IMM		`B_SEL_WIDTH'd1
`define B_SEL_FOUR	`B_SEL_WIDTH'd2
`define B_SEL_ALU		`B_SEL_WIDTH'd3
`define B_SEL_MEM		`B_SEL_WIDTH'd4
`define B_SEL_ZERO	`B_SEL_WIDTH'd5

//forward_sel
`define FORWARD_SEL_WIDTH	2
`define FORWARD_SEL_EXE	`FORWARD_SEL_WIDTH'd0
`define FORWARD_SEL_MEM	`FORWARD_SEL_WIDTH'd1
`define FORWARD_SEL_WB	`FORWARD_SEL_WIDTH'd2


//memrw_sel

`define MEMRW_SEL_WIDTH	1
`define MEMRW_SEL_READ	`MEMRW_SEL_WIDTH'd0
`define MEMRW_SEL_WRITE	`MEMRW_SEL_WIDTH'd1

//wb_sel

`define WB_SEL_WIDTH 2
`define WB_SEL_ALU	`WB_SEL_WIDTH'd0
`define WB_SEL_MEM	`WB_SEL_WIDTH'd1

