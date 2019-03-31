//TODO:
//Forwarding/Stall control (add instr_exe, instr_mem to detect hazards)

`include "constants.vh"


module control(

input										clk,

//Control inputs
//From Decode
input [`INSTR_WIDTH-1:0]			instr_decode,
input 									br_true,

//Fetch outputs
output [`PC_SEL_WIDTH-1:0]			pc_sel,

//Decode outputs
output [`IMM_SEL_WIDTH-1:0]		imm_sel,
output [`ALU_OP_WIDTH-1:0]			br_op,

//Execute registers
output reg [`B_SEL_WIDTH-1:0]		b_sel_exe, 
output reg [`A_SEL_WIDTH-1:0]		a_sel_exe, 
output reg [`ALU_OP_WIDTH-1:0]	alu_sel_exe,

//Memory registers
output reg								mem_wr_mem,
output reg								mem_en_mem,

//Writeback registers
output reg [`WB_SEL_WIDTH-1:0] 	wb_sel_wb,
output reg								reg_en_wb,

//Hazard control
output 									flush_if,
output									stall_if,
output									stall_exe

);

wire[`OP_CODE_WIDTH-1:0]	opcode = instr_decode[6:0];
wire	 	 						funct7 = instr_decode[30];
wire[2:0] 						funct3 = instr_decode[14:12];

wire								illegal_instr;
wire [`ALU_OP_WIDTH-1:0]	alu_sel_op;

//Decode control signals
wire								br_taken;
wire								jalr_taken;
wire								jal_taken;

//Pass signals along pipeline with instruction
//Execute registers
reg								mem_wr_exe;
reg								mem_en_exe;
reg [`WB_SEL_WIDTH-1:0] 	wb_sel_exe;
reg								reg_en_exe;

//Memory registers
reg [`WB_SEL_WIDTH-1:0] 	wb_sel_mem;
reg								reg_en_mem;

//Hazard/Forwarding control
wire								check_rs1;
wire								check_rs2;

always @(*)
begin

	//Initial values, unchanged will cause a stall
	imm_sel 			= `IMM_SEL_I;
	b_sel_exe		= `B_SEL_IMM;
	check_rs2		= '0;
	a_sel_exe		= `A_SEL_RS1;
	check_rs1		= 1'b1;
	alu_sel_exe		= `ALU_OP_ADD;
	br_taken			= '0;
	br_op 			= `ALU_OP_SEQ;
	jal_taken		= '0;
	jalr_taken		= '0;
	mem_wr_exe		= '0;
	mem_en_exe		= '0;
	wb_sel_exe		= `WB_SEL_PC;
	reg_en_exe		= '0;
	illegal_instr	= '0;

	
	case(opcode)	
	`OP_LUI : begin
		a_sel_exe	= `A_SEL_ZERO;
		check_rs1 	= 1'b0;
		imm_sel 		= `IMM_SEL_U;
		reg_en_exe	= 1'b1;
	end
	
	`OP_AUIPC : begin
		a_sel_exe	= `A_SEL_PC;
		check_rs1 	= 1'b0;
		imm_sel 		= `IMM_SEL_U;
		reg_en_exe	= 1'b1;
	end
	
	`OP_JAL : begin
		a_sel_exe 	= `A_SEL_PC;
		check_rs1 	= 1'b0;
		b_sel_exe 	= `B_SEL_FOUR;
		reg_en_exe	= 1'b1;
		jal_taken	= 1'b1;
	end
	
	`OP_JALR : begin
		illegal_instr	= (funct3 != 0);
		a_sel_exe 		= `A_SEL_PC;
		b_sel_exe 		= `B_SEL_FOUR;
		reg_en_exe		= 1'b1;
		jalr_taken		= 1'b1;
	end
	
	`OP_BRANCH : begin
		check_rs2	= 1'b1;
		b_sel_exe 	= `B_SEL_RS2;
		br_taken		= br_true;
	  case (funct3)
		 `FUNCT3_BEQ  : br_op = `ALU_OP_SEQ;
		 `FUNCT3_BNE  : br_op = `ALU_OP_SNE;
		 `FUNCT3_BLT  : br_op = `ALU_OP_SLT;
		 `FUNCT3_BLTU : br_op = `ALU_OP_SLTU;
		 `FUNCT3_BGE  : br_op = `ALU_OP_SGE;
		 `FUNCT3_BGEU : br_op = `ALU_OP_SGEU;
		 default : illegal_instr = 1'b1;
	  endcase // case (funct3)
	end
	
	`OP_LOAD : begin
		mem_en_exe = 1'b1;
		mem_wr_exe = `MEMRW_SEL_READ;
		wb_sel_exe = `WB_SEL_MEM;
	end
	
	`OP_STORE : begin
		check_rs2 	= 1'b1;
		imm_sel 		= `IMM_SEL_S;
		mem_en_exe	= 1'b1;
		mem_wr_exe	= `MEMRW_SEL_WRITE;
	end
	
	`OP_IMM : begin
		reg_en_exe 	= 1'b1;
		alu_sel_exe	= alu_sel_op;
	end
	
	`OP_R : begin
		b_sel_exe 	= `B_SEL_RS2;
		check_rs2 	= 1'b1;
		reg_en_exe	= 1'b1;
		alu_sel_exe	= alu_sel_op;
	end
	
	default : illegal_instr = 1'b1; //stall
	endcase
		
end

//TODO: Handle stalls and hazards
always @(*)
begin

		

end


always @(*)
begin

	if (br_taken)
		pc_sel = `PC_SEL_BRANCH;
	else if (jal_taken)
		pc_sel = `PC_SEL_JAL;
	else if (jalr_taken)
		pc_sel = `PC_SEL_JALR;
	else
		pc_sel = `PC_SEL_FOUR;
	
end

always_ff @(posedge clk)
begin

	mem_en_mem <= mem_en_exe;
	mem_wr_mem <= mem_wr_exe;
	
	wb_sel_mem <= wb_sel_exe;
	wb_sel_wb  <= wb_sel_mem;

	reg_en_mem <= reg_en_exe;
	reg_en_wb  <= reg_en_mem;

end

always @(*)
begin
	
	case(funct3)
		`FUNCT3_ADD_SUB 	: alu_sel_op = (funct7) ? `ALU_OP_SUB : `ALU_OP_ADD;
		`FUNCT3_SLL			: alu_sel_op = `ALU_OP_SLL;
		`FUNCT3_SLT			: alu_sel_op = `ALU_OP_SLT;
		`FUNCT3_SLTU		: alu_sel_op = `ALU_OP_SLTU;
		`FUNCT3_XOR			: alu_sel_op = `ALU_OP_XOR;
		`FUNCT3_SRA_SRL	: alu_sel_op = (funct7) ? `ALU_OP_SRA : `ALU_OP_SRL;
		`FUNCT3_OR			: alu_sel_op = `ALU_OP_OR;
		`FUNCT3_AND			: alu_sel_op = `ALU_OP_AND;
		default				: alu_sel_op = `ALU_OP_ADD;
	endcase
	
end

endmodule
