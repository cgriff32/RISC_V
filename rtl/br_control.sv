//
`include "constants.vh"
`include "struct.v"

module reservation_station(
	
	input clk,
	input en_i,
	
	input branch_in br_i,
	output branch_out br_o,
	
	output full_o
);

branch_unkilled_t br_unkilled;
branch_internal br_reg;
branch_fifo_t br_fifo_t;

logic [`XLEN-1:0] pc_n;
logic [`XLEN-1:0] br_a, br_b;
logic [`BRANCH_OP_WIDTH-1:0] br_op;
logic br_true;


branch_comp branch_comp(
	br_a,
	br_b,
	br_op,
	br_true
);

FIFO br_fifo(
  .clk(clk), // Clock input
  .rst(rst), // Active high reset
  .wr_cs(br_fifo_t.wr_cs), // Write chip select
  .rd_cs(br_fifo_t.rd_cs), // Read chipe select
  .data_in(br_fifo_t.data_in), // Data input
  .rd_en(br_fifo_t.rd_en), // Read enable
  .wr_en(br_fifo_t.wr_en), // Write Enable
  .data_out(br_fifo_t.data_out), // Data Output
  .empty(br_fifo_t.empty), // FIFO empty
  .full(br_fifo_t.full) // FIFO full
  );
  
assign br_fifo_t.wr_cs = br_reg.v1_rdy && br_reg.v2_rdy;
assign br_fifo_t.wr_en = br_reg.busy && br_reg.v1_rdy && br_reg.v2_rdy && !br_fifo_t.full;
assign br_fifo_t.data_in = {br_i.issue_thread_id, pc_n};

assign br_o.fifo_empty = br_fifo_t.empty;
assign br_o.thread_id = br_fifo_t.data_out[34:32];
assign br_o.pc_n = br_fifo_t.data_out[31:0];

assign br_fifo_t.rd_en = br_i.pc_ack;
assign br_fifo_t.rd_cs = br_fifo_t.rd_en;

assign is_branch = br_i.issue_comp;
assign branch_op = br_i.issue_op;
assign thread_id = br_i.issue_thread_id;


//New input from Issue
always_comb
begin
  br_unkilled = br_reg;
  
  if(br_i.issue_en)
  begin
    br_unkilled.busy = 1;
    
    if(br_i.issue_v1_rdy)
    begin
      br_unkilled.v1 <= rs_i.issue_v1;
      br_unkilled.v1_rdy <= rs_i.issue_v1_rdy;
    end
    else if((br_i.cdb_valid) && (br_i.issue_v1_q == br_i.cdb_tag))
    begin
      br_unkilled.v1 <= br_i.cdb_value;
      br_unkilled.v1_rdy <= br_i.cdb_valid;
    end
    else
    begin
      br_unkilled.q1 <= br_i.issue_v1_q;
    end
  
    if(br_i.issue_v2_rdy)
    begin
      br_unkilled.v2 <= br_i.issue_v2;
      br_unkilled.v2_rdy <= br_i.issue_v2_rdy;
    end
    else if((br_i.cdb_valid) && (br_i.issue_v2_q == br_i.cdb_tag))
    begin
      br_unkilled.v2 <= br_i.cdb_value;
      br_unkilled.v2_rdy <= br_i.cdb_valid;
    end
    else
    begin
      br_unkilled.q2 <= br_i.issue_v2_q;
    end
  end

  if(br_reg.busy)
    if(!br_reg.v1_rdy)
      if(br_i.cdb_tag == br_reg.q1)
          br_unkilled.v1 = br_i.cdb_value;
      if(!br_reg.v2_rdy)
        if(br_i.cdb_tag == br_reg.q2)
          br_unkilled.v2 = br_i.cdb_value;
end


//BR compare
//output br_true
//pc_n compute JAL/R
//output to fifo
always_comb
begin

  if((br_reg.v1_rdy) && (br_reg.v2_rdy))
  begin   
    br_a = br_reg.v1;
    br_b = br_reg.v2;
    br_op = branch_op;
    
    if(is_branch)
      if(br_true)
        pc_n = br_i.issue_pc + br_i.issue_offset;
      else
        pc_n = br_i.issue_pc + 4;
    else
      pc_n = br_reg.v1 + br_reg.v2;
  end
end

always_ff @(posedge clk)
begin
  br_reg <= br_unkilled;
end



endmodule


