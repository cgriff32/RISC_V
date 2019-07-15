//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"

module decode(
	
	input clk,
	input rst,
	input stall_i,
	
	input decode_in decode_i,
	output decode_out decode_o
	
	
);

decode_internal decode_t;

assign decode_t.rs1_addr = decode_i.instr_instr[19:15];
assign decode_t.rs2_addr = decode_i.instr_instr[24:20]; 
assign decode_t.rd_addr = decode_i.instr_instr[11:7]; 

assign decode_t.opcode = decode_i.instr_instr[6:0];
assign decode_t.funct3 = decode_i.instr_instr[14:12];
assign decode_t.funct7 = decode_i.instr_instr[30];


always_comb
begin
  decode_t.imm_sel = `IMM_SEL_I;
  decode_t.fu_sel = `FU_SEL_RS;
  decode_t.alu_op = `ALU_OP_ADD;
  decode_t.op_sel = `OP_SEL_NONE;
  decode_t.illegal_instr = 0;

	case(decode_t.opcode)

		`OP_JAL : 
		begin
		  decode_t.imm_sel = `IMM_SEL_JAL;
		  decode_t.fu_sel = `FU_SEL_BRANCH;
		  decode_t.op_sel = `OP_SEL_JAL;
		end
		
		`OP_JALR : 
		begin
		  decode_t.imm_sel = `IMM_SEL_JALR;
		  decode_t.fu_sel = `FU_SEL_BRANCH;
		  decode_t.op_sel = `OP_SEL_JALR;
		end
		
		`OP_BRANCH : 
		begin
		  decode_t.imm_sel = `IMM_SEL_BR;
		  decode_t.fu_sel = `FU_SEL_BRANCH;
		  decode_t.op_sel = `OP_SEL_BRANCH;
		  case (decode_t.funct3)
				`FUNCT3_BEQ : decode_t.alu_op = `ALU_OP_SEQ;
				`FUNCT3_BNE : decode_t.alu_op = `ALU_OP_SNE;
				`FUNCT3_BLT : decode_t.alu_op = `ALU_OP_SLT;
				`FUNCT3_BLTU : decode_t.alu_op = `ALU_OP_SLTU;
				`FUNCT3_BGE : decode_t.alu_op = `ALU_OP_SGE;
				`FUNCT3_BGEU : decode_t.alu_op = `ALU_OP_SGEU;
				default : decode_t.illegal_instr = 1'b1;
			endcase // case (funct3)
		end
		
		`OP_LOAD : 
		begin
		  decode_t.imm_sel = `IMM_SEL_I;
		  decode_t.fu_sel = `FU_SEL_LOAD;
		  decode_t.op_sel = `OP_SEL_LOAD;
		end
		
		`OP_STORE : 
		begin
		  decode_t.imm_sel = `IMM_SEL_S;
		  decode_t.fu_sel = `FU_SEL_LOAD;
		  decode_t.op_sel = `OP_SEL_STORE;
		 end
		
		`OP_LUI : 
		begin
		  decode_t.imm_sel = `IMM_SEL_U;
		  decode_t.fu_sel = `FU_SEL_NONE;
		  decode_t.op_sel = `OP_SEL_LUI;
		end
		
		`OP_AUIPC : 
		begin
		  decode_t.imm_sel = `IMM_SEL_U;
		  decode_t.fu_sel = `FU_SEL_NONE;
		  decode_t.op_sel = `OP_SEL_AUIPC;
		end
		
		`OP_IMM : 
		begin
		  decode_t.imm_sel = `IMM_SEL_I;
		  decode_t.fu_sel = `FU_SEL_RS;
		  decode_t.op_sel = `OP_SEL_IMM;
		  decode_t.alu_op = decode_t.alu_op_wire;
		end
		
		`OP_R : 
		begin
		  decode_t.fu_sel = `FU_SEL_RS;
		  decode_t.op_sel = `OP_SEL_R;
		  decode_t.alu_op = decode_t.alu_op_wire;
		end
		
		default : decode_t.illegal_instr = 1'b1; //stall
	endcase
end

always_comb
begin
  	case(decode_t.imm_sel)
		`IMM_SEL_I : decode_t.imm_wire = {{21{decode_i.instr_instr[31]}}, decode_i.instr_instr[30:20] };
		`IMM_SEL_S : decode_t.imm_wire = {{21{decode_i.instr_instr[31]}}, decode_i.instr_instr[30:25], decode_i.instr_instr[11:7] };
		`IMM_SEL_B : decode_t.imm_wire = {{20{decode_i.instr_instr[31]}}, decode_i.instr_instr[7], decode_i.instr_instr[30:25], decode_i.instr_instr[11:8], 1'b0};
		`IMM_SEL_J : decode_t.imm_wire = {{12{decode_i.instr_instr[31]}}, decode_i.instr_instr[19:12], decode_i.instr_instr[20], decode_i.instr_instr[30:21], 1'b0};
		`IMM_SEL_U : decode_t.imm_wire = {decode_i.instr_instr[31:12], 12'b0 };
		`IMM_SEL_JAL : decode_t.imm_wire = {{12{decode_i.instr_instr[31]}}, decode_i.instr_instr[19:12], decode_i.instr_instr[20], decode_i.instr_instr[30:21], 1'b0 };
    `IMM_SEL_JALR : decode_t.imm_wire = {{21{decode_i.instr_instr[31]}}, decode_i.instr_instr[30:21], 1'b0 };
    `IMM_SEL_BR : decode_t.imm_wire = {{20{decode_i.instr_instr[31]}}, decode_i.instr_instr[7], decode_i.instr_instr[30:25], decode_i.instr_instr[11:8], 1'b0 };
		default : decode_t.imm_wire = {{21{decode_i.instr_instr[31]}}, decode_i.instr_instr[30:20] };
	endcase
end

always_comb
begin
	case(decode_t.funct3)
		`FUNCT3_ADD_SUB : decode_t.alu_op_wire = (decode_t.funct7 && (decode_t.opcode == `OP_R)) ? `ALU_OP_SUB : `ALU_OP_ADD;
		`FUNCT3_SLL : decode_t.alu_op_wire = `ALU_OP_SLL;
		`FUNCT3_SLT : decode_t.alu_op_wire = `ALU_OP_SLT;
		`FUNCT3_SLTU : decode_t.alu_op_wire = `ALU_OP_SLTU;
		`FUNCT3_XOR : decode_t.alu_op_wire = `ALU_OP_XOR;
		`FUNCT3_SRA_SRL : decode_t.alu_op_wire = (decode_t.funct7) ? `ALU_OP_SRA : `ALU_OP_SRL;
		`FUNCT3_OR : decode_t.alu_op_wire = `ALU_OP_OR;
		`FUNCT3_AND : decode_t.alu_op_wire = `ALU_OP_AND;
		default : decode_t.alu_op_wire = `ALU_OP_ADD;
	endcase
end

always_ff @(posedge clk)
begin
  if(!rst)
  begin
      decode_o.imm <= '0;
      decode_o.rs1 <= '0;
      decode_o.rs2 <= '0;
      decode_o.rd <= '0;
      decode_o.alu_op <= '0;
      decode_o.pc <= '0;
      decode_o.thread_id <= '0;
      decode_o.fu_sel <= '0;
      decode_o.op_sel <= '0;
      decode_o.issue_stall <= '1;
  end
  else
  begin
    decode_o.issue_stall <= stall_i;
    if(!stall_i)
    begin
      if(decode_t.illegal_instr)
      begin
        decode_o.imm <= '0;
        decode_o.rs1 <= '0;
        decode_o.rs2 <= '0;
        decode_o.rd <= '0;
        decode_o.alu_op <= '0;
        decode_o.pc <= '0;
        decode_o.thread_id <= '0;
        decode_o.fu_sel <= '0;
        decode_o.op_sel <= '0;
        decode_o.issue_stall = 1;
      end
      else
      begin
        decode_o.imm <= decode_t.imm_wire;
        decode_o.rs1 <= decode_t.rs1_addr;
        decode_o.rs2 <= decode_t.rs2_addr;
        decode_o.rd <= decode_t.rd_addr;
        decode_o.alu_op <= decode_t.alu_op;
        decode_o.pc <= decode_i.instr_pc;
        decode_o.thread_id <= decode_i.instr_thread_id;
        decode_o.fu_sel <= decode_t.fu_sel;
        decode_o.op_sel <= decode_t.op_sel;
      end
    end
 end
end
  
  assign decode_o.issue_ack = |(decode_t.op_sel) && !stall_i;

endmodule

