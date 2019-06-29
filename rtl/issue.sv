//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"

module issue(
	
	input clk,
	input stall_i,
	
	input decode_issue_struct_o decode_i,
	input rob_issue_struct_o rob_i,
	input cdb_o cdb_i,
	input prod_o prod_i,
	input rs_full_i,
	input load_full_i,
	input branch_full_i,
	
	output issue_rs_struct_o rs_o,
	output issue_branch_struct_o branch_o,
	output issue_load_struct_o load_o,
	output issue_prod_struct_o prod_table_o,
	
	
);

logic check_rs1;
logic check_rs2;

logic bypass_rd;

always_comb
begin
  check_rs1 = '0;
  check_rs2 = '0;
  rs1_value = '0;
  rs1_rdy = 0;
  rs1_q = '0;
  rs2_value = '0;
  rs2_rdy = 0;
  rs2_q = '0;
  
  bypass_rs = '0;
  rd_bypass = '0;

  case(decode_i.fu_sel)
    `FU_SEL_BRANCH : 
    begin
      case(decode_i.op_sel)
        `OP_SEL_JAL :
        begin
          bypass_rs = 1;
          rd_bypass = pc_four;
          rs1_value = decode_i.pc;
          rs1_rdy = 1;
          rs2_value = decode_i.imm;
          rs2_rdy = 1;
        end
        
        `OP_SEL_JALR :
        begin
          bypass_rs = 1;
          rd_bypass = pc_four;
        end
        
        `OP_SEL_BRANCH :
        begin
        end
      endcase
    end
    
    `FU_SEL_RS :
    begin
      case(decode_i.op_sel)
        `OP_SEL_IMM :
        begin
          if(!decode_i.rs1) //rs1 addr == 0
          begin
            rs1_value = '0;
            rs1_rdy = 1;
          end
          else
          begin
            if(cdb_rs1) //rs1 on cdb
            begin
              rs1_value = cdb_i.value 
              rs1_rdy = 1;
            end
            else if(rob_rs1) //check rob here
            begin
              rs1_value = rob_i.rs1_value
              rs1_rdy = 1;
            end
            else
            begin
              rs1_q = decode_i.rs1;
            end   
          rs2_value = decode_i.imm;
          rs2_rdy = 1;
          end
        end
        
        `OP_SEL_R :
        begin
        end
      endcase
    end
    
    `FU_SEL_LOAD : 
    begin
      case(decode_i.op_sel)
        `OP_SEL_LOAD :
        begin
        end
        
        `OP_SEL_STORE :
        begin
        end
      endcase
    end
    
    `FU_SEL_NONE : 
    begin
      case(decode_i.op_sel)
        `OP_SEL_LUI : 
        begin
          bypass_rs = 1;
          rd_bypass = decode_i.imm;
        end
        
        `OP_SEL_AUIPC : 
        begin
          bypass_rs = 1;
          rd_bypass = imm_pc;
        end
      endcase    
    end
  endcase
end

//find rs1/rs2
always_comb
begin
    
  rs1_snooped = '0;
  rs2_snooped = '0;

  if(cdb_i.tag == decode_i.rs1)
    rs1_cdb = '1;    
  if(cdb_i.tag == decode_i.rs2)
    rs2_cdb = '1;
end

assign pc_four = decode_i.pc + 4;
assign imm_pc = decode_i.imm + decode_i.pc;


endmodule
