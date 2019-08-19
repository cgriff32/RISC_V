//Constant.vh

// Width-related constants

`define INSTR_WIDTH     32
`define XLEN			32
`define THREAD_WIDTH 3
`define OP_CODE_WIDTH	7
`define REG_DATA_WIDTH	32
`define REG_ADDR_WIDTH 	5
`define REG_FILE_SIZE	32
`define ROB_SIZE 3
`define SHAMT_WIDTH     5

// Opcodes
`define OP_NOP 	7'b0010011

`define OP_LUI	7'b0110111
`define OP_AUIPC	7'b0010111
`define OP_JAL	7'b1101111
`define OP_JALR	7'b1100111
`define OP_BRANCH	7'b1100011
`define OP_LOAD	7'b0000011
`define OP_STORE	7'b0100011
`define OP_IMM 	7'b0010011
`define OP_R		7'b0110011

//FU Codes
`define FU_SEL_WIDTH  3
`define FU_SEL_NONE   `FU_SEL_WIDTH'b000
`define FU_SEL_RS     `FU_SEL_WIDTH'b001  //[0]
`define FU_SEL_BRANCH `FU_SEL_WIDTH'b010  //[1]
`define FU_SEL_BLANK  `FU_SEL_WIDTH'd3
`define FU_SEL_LOAD   `FU_SEL_WIDTH'b100  //[2]

// ALU FUNCT3 encodings
`define FUNCT3_ADD_SUB	 0
`define FUNCT3_SLL     	1
`define FUNCT3_SLT     	2
`define FUNCT3_SLTU    	3
`define FUNCT3_XOR     	4
`define FUNCT3_SRA_SRL 	5
`define FUNCT3_OR      	6
`define FUNCT3_AND     	7

// Branch FUNCT3 encodings
`define BRANCH_OP_WIDTH 4

`define FUNCT3_BEQ	 0
`define FUNCT3_BNE  	1
`define FUNCT3_BLT  	4
`define FUNCT3_BGE  	5
`define FUNCT3_BLTU 	6
`define FUNCT3_BGEU 	7

// ALU Funct Codes
`define ALU_OP_WIDTH 5

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

`define OP_SEL_WIDTH 2

`define OP_SEL_NONE `OP_SEL_WIDTH'd0
//Branch OP sel
`define OP_SEL_JAL			`OP_SEL_WIDTH'd1
`define OP_SEL_JALR		`OP_SEL_WIDTH'd2
`define OP_SEL_BRANCH		`OP_SEL_WIDTH'd3

//Load/store OP sel
`define OP_SEL_LOAD `OP_SEL_WIDTH'd1
`define OP_SEL_STORE `OP_SEL_WIDTH'd2

//LUI/AUIPC OP sel
`define OP_SEL_LUI `OP_SEL_WIDTH'd1
`define OP_SEL_AUIPC `OP_SEL_WIDTH'd2

//R/IMM OP sel
`define OP_SEL_IMM `OP_SEL_WIDTH'd1
`define OP_SEL_R    `OP_SEL_WIDTH'd2

//imm_sel
`define IMM_SEL_WIDTH 	3
`define IMM_SEL_I			  `IMM_SEL_WIDTH'd0
`define IMM_SEL_S			  `IMM_SEL_WIDTH'd1
`define IMM_SEL_B			  `IMM_SEL_WIDTH'd2
`define IMM_SEL_J			  `IMM_SEL_WIDTH'd3
`define IMM_SEL_U			  `IMM_SEL_WIDTH'd4
`define IMM_SEL_JAL	  `IMM_SEL_WIDTH'd5
`define IMM_SEL_JALR  `IMM_SEL_WIDTH'd6
`define IMM_SEL_BR			 `IMM_SEL_WIDTH'd7

