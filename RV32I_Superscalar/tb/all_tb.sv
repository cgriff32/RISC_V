`timescale 1ns/1ns
`include "constants.vh"
`include "struct.v"

module all_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	
	
	pc_in pc_i;
	pc_out pc_o;
	logic pc_stall_i;
	
	instr_in instr_i;
	instr_out instr_o;
	logic instr_stall_i;
	
	decode_in decode_i;
	decode_out decode_o;
	logic decode_stall_i;
	
	issue_in issue_i;
  issue_out issue_o;
  logic issue_stall_i;
  
  branch_in br_i;
  branch_out br_o;
  logic branch_stall_i;
  
 	rs_in rs_i;
  rs_out rs_o;
	logic rs_stall_i;
	
  alu_in alu_i;
  alu_out alu_o;
  logic alu_stall_i;
  
  logic [2:0] cdb_req;
  logic [2:0] fu_sel;
  logic cdb_stall_i;
  
 	rob_in  rob_i;
	rob_out rob_o;
	logic rob_stall_i;
	
	regfile_in regfile_i;
	regfile_out regfile_o;
	logic reg_stall_i;
	
	prod_in prod_i;
	prod_out prod_o;
	logic prod_stall_i;
	
//assign pc_stall_i = (instr_o.full);
assign pc_i.branch_fifo_empty = br_o.empty;
assign pc_i.br_valid = br_o.valid;
assign pc_i.br_true = br_o.br_true;
assign pc_i.br_thread_id = br_o.thread_id;
assign pc_i.br_pc = br_o.pc_n;

pc pc_DUT(
	.clk(clk),
	.stall_i(pc_stall_i),
	.rst(rst),
	
	.pc_i(pc_i),
	.pc_o(pc_o)
);

assign instr_stall_i = pc_o.instr_stall;
assign instr_i.pc_pc = pc_o.pc;
assign instr_i.pc_thread_id = pc_o.thread_id;
assign instr_i.decode_ack = decode_o.issue_ack;

instr instr_DUT(
	.clk(clk),
	.stall_i(instr_stall_i),
	.rst(rst),
	
	.instr_i(instr_i),
	.instr_o(instr_o)
);

assign decode_stall_i = issue_o.decode_stall || instr_o.fifo_empty;
assign decode_i.instr_pc = instr_o.pc;
assign decode_i.instr_thread_id = instr_o.thread_id;
assign decode_i.instr_instr = instr_o.instr;

decode decode_DUT(
	.clk(clk),
	.stall_i(decode_stall_i),
	.rst(rst),
	
	.decode_i(decode_i),
	.decode_o(decode_o)
);
	
assign issue_stall_i = decode_o.issue_stall;
assign issue_i.decode_op_sel = decode_o.op_sel;
assign issue_i.decode_fu_sel = decode_o.fu_sel;
assign issue_i.decode_alu_op = decode_o.alu_op;
assign issue_i.decode_pc = decode_o.pc;
assign issue_i.decode_imm = decode_o.imm;
assign issue_i.decode_rs1 = decode_o.rs1;
assign issue_i.decode_rs2 = decode_o.rs2;
assign issue_i.decode_rd = decode_o.rd;
assign issue_i.decode_thread_id = decode_o.thread_id;
assign issue_i.br_busy = br_o.busy;
assign issue_i.cdb_valid = cdb_bus.valid;
assign issue_i.cdb_tag = cdb_bus.tag;
assign issue_i.cdb_value = cdb_bus.value;
assign issue_i.rob_rs1_valid = rob_o.issue_rs1_valid;
assign issue_i.rob_rs2_valid = rob_o.issue_rs2_valid;
assign issue_i.rob_rs1_value = rob_o.issue_rs1_value;
assign issue_i.rob_rs2_value = rob_o.issue_rs2_value;
assign issue_i.rob_tag = rob_o.tail_tag;
assign issue_i.reg_rs1_value = regfile_o.r1_data;
assign issue_i.reg_rs2_value = regfile_o.r2_data;
assign issue_i.prod_rs1_valid = prod_o.r1_valid;
assign issue_i. prod_rs2_valid = prod_o.r2_valid;
assign issue_i.prod_rs1_tag = prod_o.r1_tag;
assign issue_i.prod_rs2_tag = prod_o.r2_tag;
	
issue issue_DUT(
	.clk(clk),
	.stall_i(issue_stall_i),
	.rst(rst),
	
	.issue_i(issue_i),
	.issue_o(issue_o)
); 				

assign br_i.pc_ack = pc_o.br_ack;
assign br_i.issue_en = issue_o.br_en;
assign br_i.issue_v1 = issue_o.rs1_value;
assign br_i.issue_v2 = issue_o.rs2_value;
assign br_i.issue_v1_rdy = issue_o.rs1_rdy;
assign br_i.issue_v2_rdy = issue_o.rs2_rdy;
assign br_i.issue_v1_q = issue_o.rs1_q;
assign br_i.issue_v2_q = issue_o.rs2_q;
assign br_i.issue_thread_id = issue_o.thread_id;
assign br_i.issue_comp = issue_o.br_comp;
assign br_i.issue_op = issue_o.alu_op;
assign br_i.issue_offset = issue_o.br_offset;
assign br_i.issue_pc = issue_o.br_pc;
assign br_i.cdb_valid = cdb_bus.valid;
assign br_i.cdb_tag = cdb_bus.tag;
assign br_i.cdb_value = cdb_bus.value;
	
br_control br_DUT(
	.clk(clk),
	.stall_i(branch_stall_i),
	.rst(rst),
	
	.br_i(br_i),
	.br_o(br_o)
);

assign rs_i.issue_en = issue_o.rs_en;
assign rs_i.issue_op = issue_o.alu_op;
assign rs_i.issue_tag = issue_o.rs_tag;
assign rs_i.issue_v1 = issue_o.rs1_value;
assign rs_i.issue_v1_rdy = issue_o.rs1_rdy;
assign rs_i.issue_q1 = issue_o.rs1_q;
assign rs_i.issue_v2 = issue_o.rs2_value;
assign rs_i.issue_v2_rdy = issue_o.rs2_rdy;
assign rs_i.issue_q2 = issue_o.rs2_q;
assign rs_i.issue_thread_id = issue_o.thread_id;
assign rs_i.alu_en = !alu_o.fifo_full;
assign rs_i.cdb_valid = cdb_bus.valid;
assign rs_i.cdb_value = cdb_bus.value;
assign rs_i.cdb_tag = cdb_bus.tag;
  
reservation_station rs_DUT(
	.clk(clk),
	.stall_i(rs_stall_i),
	.rst(rst),
	
	.rs_i(rs_i),
	.rs_o(rs_o)
);
	
assign alu_i.rs_v1 = rs_o.v1;
assign alu_i.rs_v2 = rs_o.v2;
assign alu_i.rs_op = rs_o.op;
assign alu_i.rs_tag = rs_o.tag;
assign alu_i.rs_thread_id = rs_o.thread_id; 	
assign alu_i.fifo_en = (!alu_o.fifo_full && rs_o.valid);
assign alu_i.cdb_en = fu_sel[1];
	
rs_alu alu_DUT(
	.clk(clk),
	.stall_i(alu_stall_i),
	.rst(rst),
	
	.alu_i(alu_i),
	.alu_o(alu_o)
);

assign cdb_req[2] = 0;
assign cdb_req[1] = !alu_o.fifo_empty;
assign cdb_req[0] = 0;
cdb_struct_t cdb_bus;


always_comb
begin
  case(fu_sel)
    3'b100 :
    begin
    end
    3'b010 :
    begin
      cdb_bus.tag = alu_o.tag;
      cdb_bus.value = alu_o.value;
      cdb_bus.valid = alu_o.valid;
    end
    3'b001 :
    begin
    end
    default :
    begin
      cdb_bus = '0;
    end
  endcase
end
	
cdb_arbiter cdb_DUT(
	.clk(clk),
	.stall_i(cdb_stall_i),
	.rst(rst),
	
	.cdb_req(cdb_req),
	.fu_sel(fu_sel)
);

assign rob_i.issue_rs1_tag = issue_o.rs1_tag;
assign rob_i.issue_rs2_tag = issue_o.rs2_tag;
assign rob_i.issue_en = issue_o.rob_en;
assign rob_i.issue_valid = issue_o.rob_valid;
assign rob_i.issue_value = issue_o.rob_value;
assign rob_i.issue_dest = issue_o.rob_dest;
assign rob_i.cdb_valid = cdb_bus.valid;
assign rob_i.cdb_value = cdb_bus.value;
assign rob_i.cdb_tag = cdb_bus.tag;
	
rob rob_DUT(
	.clk(clk),
	.stall_i(rob_stall_i),
	.rst(rst),
	
	.rob_i(rob_i),
	.rob_o(rob_o)
);

assign regfile_i.write_en = rob_o.reg_en;
assign regfile_i.rd_addr = rob_o.reg_dest;
assign regfile_i.rd_data = rob_o.reg_value;
assign regfile_i.r1_addr = issue_o.rs1_addr;
assign regfile_i.r2_addr = issue_o.rs2_addr;

regfile reg_DUT(
	.clk(clk),
	.stall_i(reg_stall_i),
	.rst(rst),
	
	.regfile_i(regfile_i),
	.regfile_o(regfile_o)
);

assign prod_i.issue_en = issue_o.prod_en;
assign prod_i.rd_addr = issue_o.prod_rd_addr;
assign prod_i.rd_tag = issue_o.prod_tag;
assign prod_i.r1_addr = issue_o.rs1_addr;
assign prod_i.r2_addr = issue_o.rs2_addr;
assign prod_i.rob_en = rob_o.reg_en;
assign prod_i.rob_dest = rob_o.reg_dest;
assign prod_i.rob_tag = rob_o.head_tag;

prod_table prod_DUT(
	.clk(clk),
	.stall_i(prod_stall_i),
	.rst(rst),
	
	.prod_i(prod_i),
	.prod_o(prod_o)
);
 			
	
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/all_tb.txt");
  
  rst <= 0;
  pc_stall_i <= 0;
  branch_stall_i <= 0;
  rs_stall_i  <= 0;
  alu_stall_i <= 0;
  cdb_stall_i <= 0;
  rob_stall_i <= 0;
  reg_stall_i <= 0;
  prod_stall_i <= 0;
  //change this
  #5;
  
  #10;
  rst <= '1;
  
  //Start TB here
  #100;
  #10000;
$fdisplay(write_data, "%b\n",  pc_o);
$fdisplay(write_data, "%b\n",  instr_o);
$fclose(write_data);  // close the file   
$stop;
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

