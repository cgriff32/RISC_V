//
`include "constants.vh"
`include "struct.v"

module br_control #(parameter DATA_WIDTH = (2+(`THREAD_WIDTH+`XLEN)),
                  parameter ADDR_WIDTH = 3,
                  parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
	
	input clk,
	input rst,
	input stall_i,
	
	input branch_in br_i,
	output branch_out br_o
);

branch_unkilled_t br_unkilled;
branch_internal br_reg;
branch_fifo_t br_fifo_t;

logic [`XLEN-1:0] pc_n;
logic [`XLEN-1:0] br_a, br_b;
logic [`ALU_OP_WIDTH-1:0] br_op;
logic br_true;

reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH-1:0] status_cnt;
logic [`REG_ADDR_WIDTH-1:0] temp1, temp2;
wire [DATA_WIDTH-1:0] data_in_0 ;
wire [DATA_WIDTH-1:0] data_in_1 ;
wire [DATA_WIDTH-1:0] data_out_0 ;
wire [DATA_WIDTH-1:0] data_out_1 ;
wire [DATA_WIDTH-1:0] data_out_2 ;


//-----------Variable assignments---------------
assign br_o.full = (status_cnt == (RAM_DEPTH-1));
assign br_o.empty = (wr_pointer == rd_pointer);


branch_comp branch_comp(
	br_a,
	br_b,
	br_op,
	br_true
);

assign is_branch = br_i.issue_comp;
assign thread_id = br_i.issue_thread_id;

//New input from Issue
always_comb
begin
  br_unkilled = br_reg;
  
  if(br_i.issue_en)
  begin
    br_unkilled.busy = 1;
    br_unkilled.br_op = br_i.issue_op;
    br_unkilled.pc = br_i.issue_pc;
    br_unkilled.offset = br_i.issue_offset;
    br_unkilled.thread_id = br_i.issue_thread_id;
    
    if(br_i.issue_v1_rdy)
    begin
      br_unkilled.v1 <= br_i.issue_v1;
      br_unkilled.v1_rdy <= br_i.issue_v1_rdy;
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
    br_op = br_reg.br_op;
    
    if(is_branch)
      if(br_true)
        pc_n = br_reg.pc + br_reg.offset;
      else
        pc_n = br_i.issue_pc + 4;
    else
      pc_n = br_reg.v1 + br_reg.v2;
  end
end

always_ff @(posedge clk)
begin
  if(!rst)
    br_reg <= '0;
  else
    if(!stall_i)
      if(br_fifo_t.wr_en && !br_i.issue_en)
        br_reg.busy <= 0;
      else
        br_reg <= br_unkilled;
end

always_ff @ (posedge clk, negedge rst)
begin : TAIL_ENABLE
  if (!rst)
    wr_pointer <= 0;
  else 
  if(!stall_i)
    if (br_fifo_t.wr_en) 
      wr_pointer <= wr_pointer + 1;
end

always_ff @ (posedge clk, negedge rst)
begin : READ_POINTER
  if (!rst)
    rd_pointer <= 0; 
  else 
  if(!stall_i)
    if (br_fifo_t.rd_en) 
      rd_pointer <= rd_pointer + 1;
end

always_ff @ (posedge clk, negedge rst)
begin : STATUS_COUNTER
  if (!rst)
    status_cnt <= 0;
  else 
  if(!stall_i)
    if ((br_fifo_t.rd_en) && !(br_fifo_t.wr_en)
        && (status_cnt != 0)) // Read but no write.
      status_cnt <= status_cnt - 1;
    else if ((br_fifo_t.wr_en) && !(br_fifo_t.rd_en)
               && (status_cnt != RAM_DEPTH)) // Write but no read.
      status_cnt <= status_cnt + 1;
end 

assign br_fifo_t.wr_en = (br_i.issue_en && !br_o.full);
assign br_fifo_t.data_in = ({2'b00,br_i.issue_thread_id,`XLEN'b0}); 

assign br_fifo_t.up_en = (br_reg.busy && br_reg.v1_rdy && br_reg.v2_rdy && !br_o.full);
assign br_fifo_t.data_update = ({1'b1, br_true, br_o.thread_id, pc_n});

assign br_fifo_t.rd_en = (!br_o.empty) && (br_i.pc_ack);

  rob_ram #(DATA_WIDTH, ADDR_WIDTH) br_fifo(
     .clk(clk),
     .reset(rst),
     
     .wr_en_0(br_fifo_t.wr_en && !stall_i), //from issue (tail_en)
     .addr_in_0(wr_pointer),
     .data_in_0(br_fifo_t.data_in),
     
     .wr_en_1(br_fifo_t.up_en && !stall_i), //cdb_valid (update from cdb)
     .addr_in_1(rd_pointer),
     .data_in_1(br_fifo_t.data_update),
     
     .o_en_0(1'b1), //to reg (head_en)
     .addr_out_0(rd_pointer),
     .data_out_0(br_fifo_t.data_out),
     
     .o_en_1(1'b0), //to issue (rs1/rs2 snoop)
     .addr_out_1('0),
     .data_out_1(),
     
     .o_en_2(1'b0), //to issue (rs1/rs2 snoop)
     .addr_out_2('0),
     .data_out_2()
); 
  
assign br_o.valid = br_fifo_t.data_out[DATA_WIDTH-1];
assign br_o.br_true = br_fifo_t.data_out[DATA_WIDTH-2];
assign br_o.thread_id = br_fifo_t.data_out[(`THREAD_WIDTH+`XLEN-1):`XLEN];
assign br_o.pc_n = br_fifo_t.data_out[`XLEN-1:0];

assign br_o.busy = (!br_o.empty || br_reg.busy);

endmodule


