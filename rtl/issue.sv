//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates
//snoop for values (reg file, rob, cdb)


//TODO: update prodtable


`include "constants.vh"
`include "struct.v"

module issue(
	
	input clk,
	input rst,
	input stall_i,
	
	input issue_in issue_i,
	output issue_out issue_o
);

issue_internal issue_t;

always_comb
begin
  issue_t.check_rs1 = 0;
  issue_t.check_rs2 = 0;
  
  issue_t.rs1_imm_value = '0;
  issue_t.rs2_imm_value = '0;
  issue_t.rs1_imm_rdy = 0;
  issue_t.rs2_imm_rdy = 0;
  
  issue_t.bypass_rs = '0;
  issue_t.rd_bypass = '0;
  issue_t.br_comp = '0;
  issue_t.br_offset = '0;
  
  issue_t.st_offset = '0;

  case(issue_i.decode_fu_sel)
    `FU_SEL_BRANCH : 
    begin
      case(issue_i.decode_op_sel)
        `OP_SEL_JAL :
        begin
          //to ROB
          issue_t.bypass_rs = 1;
          issue_t.rd_bypass = issue_t.pc_four;
          //to branch control
          issue_t.rs1_imm_value = issue_i.decode_pc;
          issue_t.rs1_imm_rdy = 1;
          issue_t.rs2_imm_value = issue_i.decode_imm;
          issue_t.rs2_imm_rdy = 1;
        end
        
        `OP_SEL_JALR :
        begin
          //to ROB
          issue_t.bypass_rs = 1;
          issue_t.rd_bypass = issue_t.pc_four;
          //to branch control
          issue_t.rs2_imm_value = issue_i.decode_imm;
          issue_t.rs2_imm_rdy = 1;
        end
        
        `OP_SEL_BRANCH :
        begin
          //to branch control
          issue_t.br_comp = '1;
          issue_t.br_offset = issue_i.decode_imm;
          issue_t.check_rs1 = 1;
          issue_t.check_rs2 = 1;
        end
      endcase
    end
    
    `FU_SEL_RS :
    begin
      case(issue_i.decode_op_sel)
        `OP_SEL_IMM :
        begin
          issue_t.check_rs1 = 1;
          issue_t.rs2_imm_value = issue_i.decode_imm;
          issue_t.rs2_imm_rdy = 1;
        end
        `OP_SEL_R :
        begin
          issue_t.check_rs1 = 1;
          issue_t.check_rs2 = 1;
        end
      endcase
    end
    
    `FU_SEL_LOAD : 
    begin
      case(issue_i.decode_op_sel)
        `OP_SEL_LOAD :
        begin
          issue_t.check_rs1 = 1;
          issue_t.rs2_imm_value = issue_i.decode_imm;
          issue_t.rs2_imm_rdy = 1;
        end
        
        `OP_SEL_STORE :
        begin
          issue_t.check_rs1 = 1;
          issue_t.check_rs2 = 2;
          issue_t.st_offset = issue_i.decode_imm;
        end
      endcase
    end
    
    `FU_SEL_NONE : 
    begin
      case(issue_i.decode_op_sel)
        `OP_SEL_LUI : 
        begin
          issue_t.bypass_rs = 1;
          issue_t.rd_bypass = issue_i.decode_imm;
        end
        
        `OP_SEL_AUIPC : 
        begin
          issue_t.bypass_rs = 1;
          issue_t.rd_bypass = issue_t.imm_pc;
        end
      endcase    
    end
  endcase
end

//find rs1/rs2
//addr == 0, value = 0
//check regfile, valid = 1 found
//  else check prod table, valid = 1 found
//    else check cdb, tag == addr found
//else, pass rob tag
always_comb
begin
    
  issue_t.rs1_snooped = 0;
  issue_t.rs2_snooped = 0;
  issue_t.rs1_snoop_value = '0;
  issue_t.rs2_snoop_value = '0;
  issue_t.rs1_snoop_rdy = 0;
  issue_t.rs2_snoop_rdy = 0;
  
  issue_t.rs1_q = '0;
  issue_t.rs2_q = '0;

  if(issue_t.check_rs1)
  begin
    if(issue_i.decode_rs1 == 0) //x0 always zero
    begin
      issue_t.rs1_snooped = 1;
      issue_t.rs1_snoop_value = '0;
      issue_t.rs1_snoop_rdy = 1;
    end
    else if(issue_i.prod_rs1_valid == 1) //rs in reg file
    begin
      issue_t.rs1_snoop_value = issue_i.reg_rs1_value;
      issue_t.rs1_snoop_rdy = 1;
      issue_t.rs1_snooped = 1;
    end
    else if(issue_i.prod_rs1_valid == 0) //rs not in reg file
    begin
      if(issue_i.rob_rs1_valid == 1) //rs in ROB
      begin
        issue_t.rs1_snoop_value = issue_i.rob_rs1_value;
        issue_t.rs1_snoop_rdy = 1;
        issue_t.rs1_snooped = 1;
      end
      else //rs not in ROB
      begin
        if(issue_i.cdb_tag == issue_i.prod_rs1_tag) //rs on CDB
        begin
          issue_t.rs1_snoop_value = issue_i.cdb_value;
          issue_t.rs1_snoop_rdy = 1;
          issue_t.rs1_snooped = 1;
        end
        else
        begin
          issue_t.rs1_q = issue_i.prod_rs1_tag;
        end 
      end
    end
  end
  
  if(issue_t.check_rs2)
  begin
    if(issue_i.decode_rs2 == 0) //x0 always zero
    begin
      issue_t.rs2_snoop_value = '0;
      issue_t.rs2_snoop_rdy = 1;
      issue_t.rs2_snooped = 1;
    end
    else if(issue_i.prod_rs2_valid == 1) //rs in reg file
    begin
      issue_t.rs2_snoop_value = issue_i.reg_rs2_value;
      issue_t.rs2_snoop_rdy = 1;
      issue_t.rs2_snooped = 1;
    end
    else if(issue_i.prod_rs2_valid == 0) //rs not in reg file
    begin
      if(issue_i.rob_rs2_valid == 1) //rs in ROB
      begin
        issue_t.rs2_snoop_value = issue_i.rob_rs2_value;
        issue_t.rs2_snoop_rdy = 1;
        issue_t.rs2_snooped = 1;
      end
      else //rs not in ROB
      begin
        if(issue_i.cdb_tag == issue_i.prod_rs2_tag) //rs on CDB
        begin
          issue_t.rs2_snoop_value = issue_i.cdb_value;
          issue_t.rs2_snoop_rdy = 1;
          issue_t.rs2_snooped = 1;
        end
        else
        begin
          issue_t.rs2_q = issue_i.prod_rs2_tag;
        end    
      end
    end
  end  
end

always_ff @(posedge clk)
begin
  if(!rst)
  begin
    issue_o.thread_id <= '0;
    issue_o.rs1_value <= '0;
    issue_o.rs2_value <= '0;
    issue_o.rs1_rdy <= '0;
    issue_o.rs2_rdy <= '0;
    issue_o.rs1_q <= '0;
    issue_o.rs2_q <= '0;
    issue_o.alu_op <= '0;
    issue_o.rob_en <= '0;
    issue_o.rob_value <= '0;
    issue_o.rob_valid <= '0;
    issue_o.rob_dest <= '0;
    issue_o.br_en <= '0;
    issue_o.br_comp <= '0;
    issue_o.br_offset <= '0;
    issue_o.br_pc <= '0;
    issue_o.rs_en <= '0;
    issue_o.rs_tag <= '0;
    issue_o.ld_en <= '0;
    issue_o.ld_offset <= '0;
    issue_o.prod_en <= '0;
    issue_o.prod_rd_addr <= '0;
    issue_o.prod_tag <= '0;
  end
  else
  begin  
    issue_o.rob_en <= 0;
    issue_o.br_en <= 0;
    issue_o.prod_en <= 1;
    issue_o.rs_en <= 0;
    issue_o.ld_en <= 0;
    
    issue_o.prod_rd_addr <= issue_i.decode_rd;
    issue_o.prod_tag <= issue_i.rob_tag;
    issue_o.alu_op <= issue_i.decode_alu_op;
    issue_o.rs_tag <= issue_i.rob_tag;
  
    if(!stall_i)
    begin
      case(issue_i.decode_fu_sel)
      `FU_SEL_BRANCH :
      begin
        if(issue_t.bypass_rs)
        begin
          issue_o.rob_value <= issue_t.rd_bypass;
          issue_o.rob_dest <= issue_i.decode_rd;
          issue_o.rob_valid <= 1;
          issue_o.rob_en <= 1;
        end
        
          issue_o.br_en <= issue_i.decode_fu_sel[1];
          issue_o.br_comp <= issue_t.br_comp;
          issue_o.prod_en <= !issue_t.br_comp;
          issue_o.rs1_value <= issue_t.rs1_value;
          issue_o.rs2_value <= issue_t.rs2_value;
          issue_o.rs1_rdy <= issue_t.rs1_rdy;
          issue_o.rs2_rdy <= issue_t.rs2_rdy;
          issue_o.rs1_q <= issue_t.rs1_q;
          issue_o.rs2_q <= issue_t.rs2_q;
          issue_o.br_pc <= issue_i.decode_pc;
          issue_o.br_offset <= issue_t.br_offset;
      end
      `FU_SEL_RS :
      begin
        issue_o.rob_en <= 1;
        issue_o.rs_en <= issue_i.decode_fu_sel[0];
        issue_o.rs1_value <= issue_t.rs1_value;
        issue_o.rs2_value <= issue_t.rs2_value;
        issue_o.rs1_rdy <= issue_t.rs1_rdy;
        issue_o.rs2_rdy <= issue_t.rs2_rdy;
        issue_o.rs1_q <= issue_t.rs1_q;
        issue_o.rs2_q <= issue_t.rs2_q;
      end
      `FU_SEL_LOAD :
      begin
        if(issue_t.bypass_rs)
        begin
          issue_o.rob_value <= issue_t.rd_bypass;
          issue_o.rob_dest <= issue_i.decode_rd;
          issue_o.rob_valid <= 1;
          issue_o.rob_en <= 1;
        end
        
        issue_o.ld_en <= issue_i.decode_fu_sel[2];
        issue_o.rs1_value <= issue_t.rs1_value;
        issue_o.rs2_value <= issue_t.rs2_value;
        issue_o.rs1_rdy <= issue_t.rs1_rdy;
        issue_o.rs2_rdy <= issue_t.rs2_rdy;
        issue_o.rs1_q <= issue_t.rs1_q;
        issue_o.rs2_q <= issue_t.rs2_q;
        issue_o.ld_offset <= issue_t.st_offset;
      end
      `FU_SEL_NONE :
      begin
        issue_o.rob_en <= 1;
        issue_o.rob_value <= issue_t.rd_bypass;
        issue_o.rob_dest <= issue_i.decode_rd;
        issue_o.rob_valid <= 1;
      end  
      endcase
    end
  end
end

assign pc_four = issue_i.decode_pc + 4;
assign imm_pc = issue_i.decode_imm + issue_i.decode_pc;

assign issue_t.rs1_value = issue_t.rs1_snooped ? issue_t.rs1_snoop_value : issue_t.rs1_imm_value;
assign issue_t.rs2_value = issue_t.rs2_snooped ? issue_t.rs2_snoop_value : issue_t.rs2_imm_value;
assign issue_t.rs1_rdy = issue_t.rs1_snooped ? issue_t.rs1_snoop_rdy : issue_t.rs1_imm_rdy;
assign issue_t.rs2_rdy = issue_t.rs2_snooped ? issue_t.rs2_snoop_rdy : issue_t.rs2_imm_rdy;

assign issue_o.rs1_addr = rst ? issue_i.decode_rs1 : '0;
assign issue_o.rs2_addr = rst ? issue_i.decode_rs2 : '0;

assign issue_o.rs1_tag = rst ? issue_i.prod_rs1_tag : '0;
assign issue_o.rs2_tag = rst ? issue_i.prod_rs2_tag : '0;

endmodule
