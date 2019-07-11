//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates
//snoop for values (reg file, rob, cdb)


//TODO: update prodtable


`include "constants.vh"
`include "struct.v"

module finegrained_mt(
	
	input clk,
	output vga_stuff
);

logic stall;
pc_in pc_i;
pc_out pc_o;
instr_out instr_o;
decode_out decode_o;
issue_out issue_o;
branch_out br_o;
rs_out rs_o;
alu_out alu_o;
logic [2:0] cdb_o_fu_sel;
cdb_struct_t cdb_bus;
logic [`XLEN-1:0] reg_rs1_value;
logic [`XLEN-1:0] reg_rs2_value;
logic prod_r1_valid;
logic [`ROB_SIZE-1:0] prod_r1_tag;
logic prod_r2_valid;
logic [`ROB_SIZE-1:0] prod_r2_tag;

pc pc(
	.clk(clk),
	.rst(rst),
	.stall_i(stall),
	
	.pc_i(pc_i),
	.pc_o(pc_o)
);
  //PC IN
	assign pc_i.br_pc = br_o.pc_n;
  assign pc_i.branch_fifo_empty = (br_o.fifo_empty);
  assign pc_i.br_thread_id = (br_o.thread_id);
  
instr instr(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .pc_pc(pc_o.pc),
  .pc_thread_id(pc_o.thread_id),
  
  //out
  .thread_id(instr_o.thread_id),
  .pc(instr_o.pc),
  .instr(instr_o.instr)
);

decode decode(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .instr_pc(instr_o.pc),
  .instr_thread_id(instr_o.thread_id),
  .instr_instr(instr_o.instr),
  
  //out
  .op_sel(decode_o.op_sel),
  .alu_op(decode_o.alu_op),
  .rs1(decode_o.rs1),
  .rs2(decode_o.rs2),
  .rd(decode_o.rd),
  .imm(decode_o.imm),
  .pc(decode_o.pc),
  .thread_id(decode_o.thread_id),
  .fu_sel(decode_o.fu_sel)
);
  
issue issue(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .decode_op_sel(decode_o.op_sel),
  .decode_fu_sel(decode_o.fu_sel),
  .decode_alu_op(decode_o.alu_op),
  .decode_pc(decode_o.pc),
  .decode_imm(decode_o.imm),
  .decode_rs1(decode_o.rs1),
  .decode_rs2(decode_o.rs2),
  .decode_rd(decode_o.rd),
  .decode_thread_id(decode_o.thread_id),
  
  .prod_rs1_valid(prod_r1_valid),
  .prod_rs2_valid(prod_r2_valid),
  .prod_rs1_tag(prod_r1_tag),
  .prod_rs2_tag(prod_r2_tag),
  
  .reg_rs1_value(reg_rs1_value),
  .reg_rs2_value(reg_rs2_value),
  
  .rob_rs1_valid(rob_o.rs1_valid),
  .rob_rs2_valid(rob_o.rs2_valid),
  .rob_rs1_value(rob_o.rs1_value),
  .rob_rs2_value(rob_o.rs2_value),
  .rob_tag(rob_o.tag),
  
  .cdb_tag(cdb_bus.tag),
  .cdb_value(cdb_bus.value),
  
  //out
  .thread_id(issue_o.thread_id),
  .rs1_value(issue_o.rs1_value),
  .rs2_value(issue_o.rs2_value),
  .rs1_rdy(issue_o.rs1_rdy),
  .rs2_rdy(issue_o.rs2_rdy),
  .rs1_q(issue_o.rs1_q),
  .rs2_q(issue_o.rs2_q),
  .alu_op(issue_o.alu_op),
  .tag(issue_o.rs_tag),
  .rob_en(issue_o.rob_en),
  .rob_value(issue_o.rob_value),
  .rob_valid(issue_o.rob_valid),
  .rob_dest(issue_o.rob_dest),
  .br_en(issue_o.br_en),
  .br_comp(issue_o.br_comp),
  .br_offset(issue_o.br_offset),
  .br_pc(issue_o.br_pc),
  .rs_en(issue_o.rs_en),
  .ld_en(issue_o.ld_en),
  .ld_offset(issue_o.ld_offset),
  .prod_en(issue_o.prod_en),
  .prod_rd_addr(issue_o.prod_rd_addr),
  .prod_tag(issue_o.prod_tag)
);

br_control branch(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .issue_en(issue_o.br_en),
  .issue_v1(issue_o.rs1_value),
  .issue_v2(issue_o.rs2_value),
  .issue_v1_rdy(issue_o.rs1_rdy),
  .issue_v2_rdy(issue_o.rs2_rdy),
  .issue_v1_q(issue_o.rs1_q),
  .issue_v2_q(issue_o.rs2_q),
  .issue_thread_id(issue_o.thread_id),
  .issue_comp(issue_o.br_comp),
  .issue_op(issue_o.alu_op),
  .issue_offset(issue_o.br_offset),
  .issue_pc(issue_o.br_pc),
  .cdb_valid(cdb_bus.valid),
  .cdb_tag(cdb_bus.tag),
  .cdb_value(cdb_bus.value),
  .pc_ack(pc_o.br_ack),
  
  //out
  .pc_n(br_o.pc_n),
  .thread_id(br_o.thread_id),
  .fifo_empty(br_o.fifo_empty)
);

reservation_station res_station0(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .issue_en(issue_o.rs_en),
  .issue_op(issue_o.alu_op),
  .issue_tag(issue_o.rs_tag),
  .issue_v1(issue_o.rs1_value),
  .issue_v1_rdy(issue_o.rs1_rdy),
  .issue_q1(issue_o.rs1_q),
  .issue_v2(issue_o.rs2_value),
  .issue_v2_rdy(issue_o.rs2_rdy),
  .issue_q2(issue_o.rs2_q),
  .cdb_valid(cdb_bus.valid),
  .cdb_tag(cdb_bus.tag),
  .cdb_value(cdb_bus.value),
  .alu_en(!alu_o.fifo_full),
  
  //out
  .op(rs_o.op),
  .v1(rs_o.v1),
  .v2(rs_o.v2),
  .tag(rs_o.tag),
  .valid(rs_o.valid)
);

rs_alu rs_alu(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .rs_v1(rs_o.v1),
  .rs_v2(rs_o.v2),
  .rs_op(rs_o.op),
  .rs_tag(rs_o.tag),
  .fifo_en(rs_o.valid),
  .cdb_en(cdb_o.fu_sel[0]),
  
  //out
  .tag(alu_o.tag),
  .value(alu_o.value),
  .fifo_empty(alu_o.fifo_empty),
  .fifo_full(alu_o.fifo_full)
);

//second rs here

//ldstore here

cdb_arbiter cdb_arbiter(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .cdb_req({ld_o.valid, !alu_o.fifo_empty}),
  
  //out
  .fu_sel(cdb_o_fu_sel)
);

rob rob(
  .clk(clk),
  .rst(rst),
  .stall_i(stall)
);

regfile regfile(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
	.write_en(rob_o.reg_en),
  .rd_addr(rob_o.reg_dest),
	.rd_data(rob_o.reg_value),
	.r1_addr(issue_o.rs1_addr),
	.r2_addr(issue_o.rs2_addr),
	
	//out
	.r1_data(reg_rs1_value),
	.r2_data(reg_rs2_value)
);

prod_table prod_table0(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .issue_en(issue_o.prod_en && (issue_o.thread_id && 3'b000)),
	.rob_en(rob_o.reg_en && (rob_o.thread_id && 3'b000)),
  .rd_addr(issue_o.prod_rd_addr),
	.rd_tag(issue_o.prod_tag),
	.r1_addr(issue_o.rs1_addr), 
	.r2_addr(issue_o.rs2_addr),
	
	//out
	.r1_valid(prod_r1_valid),
	.r1_tag(prod_r1_tag),
	.r2_valid(prod_r2_valid), 
	.r2_tag(prod_r2_tag)
);

prod_table prod_table1(
  .clk(clk),
  .rst(rst),
  .stall_i(stall),
  
  //in
  .issue_en(issue_o.prod_en && (issue_o.thread_id && 3'b001)),
	.rob_en(rob_o.reg_en && (rob_o.thread_id && 3'b001)),
  .rd_addr(issue_o.prod_rd_addr),
	.rd_tag(issue_o.prod_tag),
	.r1_addr(issue_o.rs1_addr), 
	.r2_addr(issue_o.rs2_addr),
	
	//out
	.r1_valid(prod_r1_valid),
	.r1_tag(prod_r1_tag),
	.r2_valid(prod_r2_valid), 
	.r2_tag(prod_r2_tag)
);

endmodule
