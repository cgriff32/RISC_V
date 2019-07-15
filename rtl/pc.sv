//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"
  
module pc(
	
	input clk,
	input rst,
	input stall_i,
	
	input pc_in pc_i,
	output pc_out pc_o
);

reg [`XLEN-1:0] pc_n [0:7];
pc_internal pc_t;

always_comb
begin
  pc_t.instr_stall = 0;
  pc_t.pc = pc_n[pc_t.thread_id];
  pc_t.pc_n = pc_n[pc_t.thread_id] + 4;
  pc_t.thread_id_n = pc_t.thread_id + 1;
      
  if(!pc_i.branch_fifo_empty)
  begin 
    if(pc_t.thread_id == pc_i.br_thread_id)
    begin
      if(pc_i.br_valid)
      begin
        if(pc_i.br_true)
        begin
          pc_t.pc = pc_i.br_pc;
          pc_t.pc_n = pc_i.br_pc + 4;
          pc_t.thread_id_n = pc_t.thread_id + 1;
        end
      end
      else
      begin
        pc_t.instr_stall = 1;
        pc_t.pc = pc_n[pc_t.thread_id_n];
        pc_t.thread_id_n = pc_t.thread_id;
        pc_t.pc_n = pc_n[pc_t.thread_id];
      end
    end
  end
end

always_ff @(posedge clk)
begin
  if(!rst)
  begin
    pc_o.pc <= '0;
    pc_o.thread_id <= '0;
    pc_n[0] <= '0;
    pc_n[1] <= '0;
    pc_n[2] <= '0;
    pc_n[3] <= '0;
    pc_n[4] <= '0;
    pc_n[5] <= '0;
    pc_n[6] <= '0;
    pc_n[7] <= '0;
    pc_t.thread_id <= '0;
    pc_o.instr_stall = '1;
  end
  else
  begin  
    if(!stall_i)
    begin
      pc_n[pc_t.thread_id] <= pc_t.pc_n;
      pc_o.pc <= pc_t.pc;
      pc_o.thread_id <= pc_t.thread_id;
      pc_t.thread_id <= pc_t.thread_id_n;
      pc_o.instr_stall = pc_t.instr_stall;
    end
  end
end

assign pc_o.br_ack = pc_i.branch_fifo_empty ? '0 : ((pc_t.thread_id == pc_i.br_thread_id) && pc_i.br_valid && pc_i.br_true && !pc_i.branch_fifo_empty);
//assign 
endmodule

