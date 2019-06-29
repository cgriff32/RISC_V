//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"

module issue_decode(
	
	input clk,
	
	input [`XLEN-1:0] instr,
	input [`XLEN-1:0] pc,
	input [2:0] context_sel, 
	output instr_fifo_en,
	
	output rs_add_struct_t rs_o,
	output rs_ldst_struct_o ld_o,
	
	input [1:0] rs_full,
	
	output rs_en_o,
	output ld_en_o
	
);

wire [`REG_ADDR_WIDTH-1:0] rs1_addr = instr[19:15];
wire [`REG_ADDR_WIDTH-1:0] rs2_addr = instr[24:20]; 
wire [`REG_ADDR_WIDTH-1:0] rd_addr = instr[11:7]; 

wire[`OP_CODE_WIDTH-1:0] opcode = instr[6:0];
wire[2:0] funct3 = instr[14:12];
wire funct7 = instr[30];


always_comb
begin
ld_enable_wire = '0;
alu_enable_wire = '0;
alu_skip_wire = '0;
alu_op_wire = 'ALU_OP_ADD;
pc_sel_wire = PC_SEL_FOUR;
check_rd = '0;
check_rs1 = '0;
val_1_wire = '0;
val_1_ready_wire = '0;
check_rs2 = '0;
val_2_wire = '0;
val_2_ready_wire = '0;


	case(opcode)

		`OP_JAL : 
		begin
		  alu_skip_wire = 1;
		  pc_sel_wire = `PC_SEL_JAL;
		  check_rd = '1;
		  val_1_wire = pc;
		  val_2_wire = 4;
		end
		
		`OP_JALR : 
		begin
		  alu_skip_wire = 1;
		  pc_sel_wire = `PC_SEL_JALR;
		  check_rd = 1;
		  check_rs1_wire = 1;
		  val_2_wire = {{21{instr[31]}}, instr[30:21], 1'b0 };
		  val_2_ready_wire = 1;
		end
		
		`OP_BRANCH : 
		begin
		  pc_sel_wire = `PC_SEL_BRANCH;
		  check_rs1_wire = 1;
		  check_rs2_wire = 1;
		end
		
		`OP_LOAD : 
		begin
		  ld_enable = 1;
		  check_rd_wire = 1;
		  check_rs1_wire = 1;
		  val_2_ready = 1;
		  offset_wire = {{21{instr[31]}}, instr[30:20] }; //IMM_I
		  
		end
		
		`OP_STORE : 
		begin
		  ld_enable = 1;
		  check_rs1_wire = 1;
		  check_rs2_wire = 1;
		  offset_wire = {{21{instr[31]}}, instr[30:25], instr[11:7] }; //IMM_S
		 end
		
		`OP_LUI : 
		begin
		  alu_skip_wire_ = 1;
		  val_1_wire = {instr[31:12], 12'b0 }; //IMM_U
		  val_1_ready_wire = 1;
		  val_2_ready_wire = 1;
		end
		
		`OP_AUIPC : 
		begin
		end
		
		`OP_IMM : 
		begin
		end
		
		`OP_R : 
		begin
		end
		
		default : illegal_instr = 1'b1; //stall
	endcase
end
    
    
    
  
  
end









//logic [`XLEN-1:0] imm_wire;
//wire [`XLEN-1:0] imm_jal = {{12{instr_decode[31]}}, instr_decode[19:12], instr_decode[20], instr_decode[30:21], 1'b0 };
//wire [`XLEN-1:0] imm_jalr = {{21{instr_decode[31]}}, instr_decode[30:21], 1'b0 };
//wire [`XLEN-1:0] imm_br = {{20{instr_decode[31]}}, instr_decode[7], instr_decode[30:25], instr_decode[11:8], 1'b0 };



endmodule
