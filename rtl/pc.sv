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


always_ff @(posedge clk)
begin
  pc_o.br_ack <= 0;
  if(rst)
  begin
    pc_o <= 0;
    pc_t <= 0;
    pc_n[0] <= '0;
    pc_n[1] <= '0;
    pc_n[2] <= '0;
    pc_n[3] <= '0;
    pc_n[4] <= '0;
    pc_n[5] <= '0;
    pc_n[6] <= '0;
    pc_n[7] <= '0;
  end
  else
  begin
    if(!stall_i)
    begin
      pc_o.thread_id <= pc_t.thread_id;
      pc_t.thread_id <= pc_t.thread_id + 1;
      if((pc_t.thread_id == pc_i.br_thread_id) && !pc_i.branch_fifo_empty)
      begin 
        pc_o.pc <= pc_i.br_pc;
        pc_n[pc_t.thread_id] <= pc_i.br_pc + 4;
        pc_o.br_ack <= 1;
      end
      else
      begin
        pc_o.pc <= pc_n[pc_t.thread_id];
        pc_n[pc_t.thread_id] <= pc_n[pc_t.thread_id] + 4;
      end
    end
  end
end
  
endmodule

