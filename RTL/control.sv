//TODO:
//branch prediction?
`include "constants.vh"


module control(

input										clk,

//Control inputs
//From Decode
input [`INSTR_WIDTH-1:0]			instr_decode,
input 									br_true,

//Control outputs
//To Fetch
output logic [`PC_SEL_WIDTH-1:0]			pc_sel,

//To Decode
output logic [`IMM_SEL_WIDTH-1:0]		imm_sel,
output logic [`ALU_OP_WIDTH-1:0]			br_op,

//ID/EX registers
output reg [`B_SEL_WIDTH-1:0]		b_sel_exe, 
output reg [`A_SEL_WIDTH-1:0]		a_sel_exe, 
output reg [`ALU_OP_WIDTH-1:0]	alu_sel_exe,

//EX/MEM registers
output reg								mem_wr_mem,
output reg								mem_en_mem,

//MEM/WB registers
output reg [`WB_SEL_WIDTH-1:0] 	wb_sel_wb,
output reg								reg_en_wb,

//Forwarding/Hazard detection inputs
//From Execute
input [`REG_ADDR_WIDTH-1:0]		rs1_addr_exe,
input [`REG_ADDR_WIDTH-1:0]		rs2_addr_exe,
input [`REG_ADDR_WIDTH-1:0]		rd_addr_exe,

//From Mem
input [`REG_ADDR_WIDTH-1:0]		rd_addr_mem,

//From WB
input [`REG_ADDR_WIDTH-1:0]		rd_addr_wb,

//Hazard control (Decode)
output logic									flush_if,
output	logic								stall_if,

//Forwarding control (Execute)
output logic [`FORWARD_SEL_WIDTH-1:0]	forward_a_sel,
output logic [`FORWARD_SEL_WIDTH-1:0]	forward_b_sel

);

wire[`OP_CODE_WIDTH-1:0]	opcode = instr_decode[6:0];
wire	 	 						funct7 = instr_decode[30];
wire[2:0] 						funct3 = instr_decode[14:12];

wire[`REG_ADDR_WIDTH-1:0]	rs1_addr_decode = instr_decode[19:15];
wire[`REG_ADDR_WIDTH-1:0]	rs2_addr_decode = instr_decode[24:20];

logic								illegal_instr;
logic [`ALU_OP_WIDTH-1:0]	alu_sel_op;

//Decode control signals
logic								br_taken;
logic								jalr_taken;
logic								jal_taken;

logic								detect_hazard;

//Pipeline register wires
logic [`B_SEL_WIDTH-1:0]		b_sel_wire; 
logic [`A_SEL_WIDTH-1:0]		a_sel_wire;
logic [`ALU_OP_WIDTH-1:0]	alu_sel_wire;
logic								mem_wr_wire;
logic 								mem_en_wire;
logic [`WB_SEL_WIDTH-1:0] 	wb_sel_wire;
logic								reg_en_wire;

//Pass signals along pipeline with instruction
//Execute registers
reg								mem_wr_exe;
reg								mem_en_exe;
reg [`WB_SEL_WIDTH-1:0] 	wb_sel_exe;
reg								reg_en_exe;

//Memory registers
reg [`WB_SEL_WIDTH-1:0] 	wb_sel_mem;
reg								reg_en_mem;

always_comb
begin

	//Initial values, unchanged will cause a stall
	imm_sel 			= `IMM_SEL_I;
	b_sel_wire		= `B_SEL_IMM;
	a_sel_wire		= `A_SEL_RS1;
	alu_sel_wire		= `ALU_OP_ADD;
	br_taken			= '0;
	br_op 			= `ALU_OP_SEQ;
	jal_taken		= '0;
	jalr_taken		= '0;
	mem_wr_wire		= '0;
	mem_en_wire		= '0;
	wb_sel_wire		= `WB_SEL_ALU;
	reg_en_wire		= '0;
	illegal_instr	= '0;

	
	case(opcode)	
	`OP_LUI : begin
		a_sel_wire	= `A_SEL_ZERO;
		imm_sel 		= `IMM_SEL_U;
		reg_en_wire	= 1'b1;
	end
	
	`OP_AUIPC : begin
		a_sel_wire	= `A_SEL_PC;
		imm_sel 		= `IMM_SEL_U;
		reg_en_wire	= 1'b1;
	end
	
	`OP_JAL : begin
		a_sel_wire 	= `A_SEL_PC;
		b_sel_wire 	= `B_SEL_FOUR;
		reg_en_wire	= 1'b1;
		jal_taken	= 1'b1;
	end
	
	`OP_JALR : begin
		illegal_instr	= (funct3 != 0);
		a_sel_wire 		= `A_SEL_PC;
		b_sel_wire 		= `B_SEL_FOUR;
		reg_en_wire		= 1'b1;
		jalr_taken		= 1'b1;
	end
	
	`OP_BRANCH : begin
		b_sel_wire 	= `B_SEL_RS2;
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
		mem_en_wire = 1'b1;
		mem_wr_wire = `MEMRW_SEL_READ;
		wb_sel_wire = `WB_SEL_MEM;
	end
	
	`OP_STORE : begin
		imm_sel 		= `IMM_SEL_S;
		mem_en_wire	= 1'b1;
		mem_wr_wire	= `MEMRW_SEL_WRITE;
	end
	
	`OP_IMM : begin
		reg_en_wire 	= 1'b1;
		alu_sel_wire	= alu_sel_op;
	end
	
	`OP_R : begin
		b_sel_wire 	= `B_SEL_RS2;
		reg_en_wire	= 1'b1;
		alu_sel_wire	= alu_sel_op;
	end
	
	default : illegal_instr = 1'b1; //stall
	endcase
		
end

//Forward and Hazard detection
always_comb
begin


//Forward control
	if ((reg_en_mem) && 
		(!rd_addr_mem) && 
		(rd_addr_mem == rs1_addr_exe))
		
			forward_a_sel = `FORWARD_SEL_MEM;
	else if ((reg_en_wb) &&
		(!rd_addr_wb) &&
		(!(reg_en_mem && !rd_addr_mem && (rd_addr_mem == rs1_addr_exe))) &&
		(rd_addr_wb == rs1_addr_exe))
		
			forward_a_sel = `FORWARD_SEL_WB;
	else
	
			forward_a_sel = `FORWARD_SEL_EXE;
		
	if ((reg_en_mem) && 
		(!rd_addr_mem) && 
		(rd_addr_mem == rs2_addr_exe))
		
			forward_b_sel = `FORWARD_SEL_MEM;
	else if ((reg_en_wb) &&
		(!rd_addr_wb) &&
		(!(reg_en_mem && !rd_addr_mem && (rd_addr_mem == rs1_addr_exe))) &&
		(rd_addr_wb == rs2_addr_exe))
		
			forward_b_sel = `FORWARD_SEL_WB;
	else
	
			forward_b_sel = `FORWARD_SEL_EXE;

//Hazard Detection

	if ((mem_wr_exe == `MEMRW_SEL_READ) &&
		((rd_addr_exe == rs1_addr_decode) || (rd_addr_exe == rs2_addr_decode)))
			
			detect_hazard = 1'b1;
	else
			detect_hazard = 1'b0;

end


//PC branch select
always_comb
begin
flush_if = 1'b1;

	if (br_taken)
		pc_sel = `PC_SEL_BRANCH;
	else if (jal_taken)
		pc_sel = `PC_SEL_JAL;
	else if (jalr_taken)
		pc_sel = `PC_SEL_JALR;
	else
	begin
		pc_sel = `PC_SEL_FOUR;
		flush_if = 1'b0;
	end
end

always_ff @(posedge clk)
begin

	case(detect_hazard)
	1'b1: begin
		stall_if 		<=	1'b1;
		b_sel_exe		<= `B_SEL_IMM;
		a_sel_exe		<= `A_SEL_RS1;
		alu_sel_exe		<= `ALU_OP_ADD;
		mem_wr_exe		<= '0;
		mem_en_exe		<= '0;
		wb_sel_exe		<= `WB_SEL_ALU;
		reg_en_exe		<= '0;
	end
	1'b0: begin
		stall_if			<= 1'b0;
		b_sel_exe		<= b_sel_wire;
		a_sel_exe		<= a_sel_wire;
		alu_sel_exe		<= alu_sel_wire;
		mem_wr_exe		<= mem_wr_wire;
		mem_en_exe		<= mem_en_wire;
		wb_sel_exe		<= wb_sel_wire;
		reg_en_exe		<= reg_en_wire;
	end
	endcase

	mem_en_mem <= mem_en_exe;
	mem_wr_mem <= mem_wr_exe;
	
	wb_sel_mem <= wb_sel_exe;
	wb_sel_wb  <= wb_sel_mem;

	reg_en_mem <= reg_en_exe;
	reg_en_wb  <= reg_en_mem;

end

always_comb
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
