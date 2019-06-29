`include "constants.vh"
`include "struct.v"

module rob(
	input clk,
	
  input tail_enable,
  input write_enable,
  
  input issue_rob_struct_o issue_data_i,
	input cdb_struct_t cdb_data_i,
	output rob_regfile_struct_o data_o,
	output head_enable,
	
	output tag_o,
	output empty_o,
	output full_o
	
);

rob_struct_t ROB_regs [15:0];

reg [`ROB_SIZE-1:0] tail_pointer;
reg [`ROB_SIZE-1:0] head_pointer;

assign empty_o = (tail_pointer == head_pointer) ? 1'b1 : 1'b0;
assign full_o = (head_pointer == tail_pointer + 1) ? 1'b1 : 1'b0;
assign head_enable = ROB_regs[head_pointer].value && !empty_o;
assign tag_o = tail_pointer;
assign data_o.dest = ROB_regs[head_pointer];
assign data_o.value = ROB_regs[head_pointer];


always_ff @(posedge clk)
begin
  if(tail_enable)
  begin
    ROB_regs[tail_pointer].dest <= issue_data_i.dest;
    ROB_regs[tail_pointer].br_taken <= '0;
    ROB_regs[tail_pointer].valid <= issue_data_i.valid;
    tail_pointer <= tail_pointer + 1;
  end
  
  if(write_enable)//cdb_valid == 1
  begin
    ROB_regs[cdb_data_i.tag].valid <= '1;
    ROB_regs[cdb_data_i.tag].value <= cdb_data_i.value;     
    ROB_regs[cdb_data_i.tag].br_taken <= cdb_data_i.br_taken;
  end
  
  if(head_enable)
    head_pointer <= head_pointer + 1;

end    


endmodule