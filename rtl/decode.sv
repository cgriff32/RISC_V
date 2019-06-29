//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"

module decode(
	
	input clk,
	input stall_i,
	
	input instr_decode_struct_o instr_i,
	
	output decode_issue_struct_o issue_o
	
	
);

wire [`REG_ADDR_WIDTH-1:0] rs1_addr = instr_i.instr[19:15];
wire [`REG_ADDR_WIDTH-1:0] rs2_addr = instr_i.instr[24:20]; 
wire [`REG_ADDR_WIDTH-1:0] rd_addr = instr_i.instr[11:7]; 

wire[`OP_CODE_WIDTH-1:0] opcode = instr_i.instr[6:0];
wire[2:0] funct3 = instr_i.instr[14:12];
wire funct7 = instr_i.instr[30];

logic [`IMM_SEL_WIDTH-1:0] imm_wire;
logic [`IMM_SEL_WIDTH-1:0] imm_sel;
logic [`FU_SEL_WIDTH-1:0] fu_sel;
logic [`ALU_OP_WIDTH-1:0] alu_op_wire;
logic [`ALU_OP_WIDTH-1:0] alu_op;
logic [`OP_SEL_WIDTH-1:0] op_sel;

logic illegal_instr;

always_comb
begin
  imm_sel = `IMM_SEL_I;
  fu_sel = `FU_SEL_RS;
  alu_op = `ALU_OP_ADD;
  op_sel = `OP_SEL_R;

	case(opcode)

		`OP_JAL : 
		begin
		  imm_sel = `IMM_SEL_JAL;
		  fu_sel = `FU_SEL_BRANCH;
		  op_sel = `OP_SEL_JAL;
		end
		
		`OP_JALR : 
		begin
		  imm_sel = `IMM_SEL_JALR;
		  fu_sel = `FU_SEL_BRANCH;
		  op_sel = `OP_SEL_JALR;
		end
		
		`OP_BRANCH : 
		begin
		  imm_sel = `IMM_SEL_BR;
		  fu_sel = `FU_SEL_BRANCH;
		  op_sel = `OP_SEL_BRANCH;
		  case (funct3)
				`FUNCT3_BEQ : alu_op = `ALU_OP_SEQ;
				`FUNCT3_BNE : alu_op = `ALU_OP_SNE;
				`FUNCT3_BLT : alu_op = `ALU_OP_SLT;
				`FUNCT3_BLTU : alu_op = `ALU_OP_SLTU;
				`FUNCT3_BGE : alu_op = `ALU_OP_SGE;
				`FUNCT3_BGEU : alu_op = `ALU_OP_SGEU;
				default : illegal_instr = 1'b1;
			endcase // case (funct3)
		end
		
		`OP_LOAD : 
		begin
		  imm_sel = `IMM_SEL_I;
		  fu_sel = `FU_SEL_LOAD;
		  op_sel = `OP_SEL_LOAD;
		end
		
		`OP_STORE : 
		begin
		  imm_sel = `IMM_SEL_S;
		  fu_sel = `FU_SEL_LOAD;
		  op_sel = `OP_SEL_STORE;
		 end
		
		`OP_LUI : 
		begin
		  imm_sel = `IMM_SEL_U;
		  fu_sel = `FU_SEL_NONE;
		  op_sel = `OP_SEL_LUI;
		end
		
		`OP_AUIPC : 
		begin
		  imm_sel = `IMM_SEL_U;
		  fu_sel = `FU_SEL_NONE;
		  op_sel = `OP_SEL_AUIPC;
		end
		
		`OP_IMM : 
		begin
		  imm_sel = `IMM_SEL_I;
		  fu_sel = `FU_SEL_RS;
		  op_sel = `OP_SEL_IMM;
		  alu_op = alu_op_wire;
		end
		
		`OP_R : 
		begin
		  fu_sel = `FU_SEL_RS;
		  op_sel = `OP_SEL_R;
		  alu_op = alu_op_wire;
		end
		
		default : illegal_instr = 1'b1; //stall
	endcase
end

always_comb
begin
  	case(imm_sel)
		`IMM_SEL_I : imm_wire = {{21{instr_i.instr[31]}}, instr_i.instr[30:20] };
		`IMM_SEL_S : imm_wire = {{21{instr_i.instr[31]}}, instr_i.instr[30:25], instr_i.instr[11:7] };
		`IMM_SEL_B : imm_wire = {{20{instr_i.instr[31]}}, instr_i.instr[7], instr_i.instr[30:25], instr_i.instr[11:8], 1'b0};
		`IMM_SEL_J : imm_wire = {{12{instr_i.instr[31]}}, instr_i.instr[19:12], instr_i.instr[20], instr_i.instr[30:21], 1'b0};
		`IMM_SEL_U : imm_wire = {instr_i.instr[31:12], 12'b0 };
		`IMM_SEL_JAL : imm_wire = {{12{instr_i.instr[31]}}, instr_i.instr[19:12], instr_i.instr[20], instr_i.instr[30:21], 1'b0 };
    `IMM_SEL_JALR : imm_wire = {{21{instr_i.instr[31]}}, instr_i.instr[30:21], 1'b0 };
    `IMM_SEL_BR : imm_wire = {{20{instr_i.instr[31]}}, instr_i.instr[7], instr_i.instr[30:25], instr_i.instr[11:8], 1'b0 };
		default : imm_wire = {{21{instr_i.instr[31]}}, instr_i.instr[30:20] };
	endcase
end

always_comb
begin
	case(funct3)
		`FUNCT3_ADD_SUB : alu_op_wire = (funct7 && (opcode == `OP_R)) ? `ALU_OP_SUB : `ALU_OP_ADD;
		`FUNCT3_SLL : alu_op_wire = `ALU_OP_SLL;
		`FUNCT3_SLT : alu_op_wire = `ALU_OP_SLT;
		`FUNCT3_SLTU : alu_op_wire = `ALU_OP_SLTU;
		`FUNCT3_XOR : alu_op_wire = `ALU_OP_XOR;
		`FUNCT3_SRA_SRL : alu_op_wire = (funct7) ? `ALU_OP_SRA : `ALU_OP_SRL;
		`FUNCT3_OR : alu_op_wire = `ALU_OP_OR;
		`FUNCT3_AND : alu_op_wire = `ALU_OP_AND;
		default : alu_op_wire = `ALU_OP_ADD;
	endcase
end

always_ff @(posedge clk)
begin
  
  if(!stall_i)
  begin
    issue_o.imm <= imm_wire;
    issue_o.rs1 <= rs1_addr;
    issue_o.rs2 <= rs2_addr;
    issue_o.rd <= rd_addr;
    issue_o.alu_op <= alu_op;
    issue_o.pc <= instr_i.pc;
    issue_o.thread_id <= instr_i.thread_id;
    issue_o.fu_sel <= fu_sel;
  end
end
  
endmodule

