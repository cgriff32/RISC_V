`include "constants.vh"
`include "struct.v"

module FIFO(
	input clk,
	
	input en_i,
	input rd_i,
	input wr_i,
	input alu_cdb_struct_o data_i,
	output cdb_struct_t data_o,
	output empty_o,
	output full_o
	
);

reg [2:0] count;
cdb_struct_t FIFO_regs [15:0];
reg [2:0] read_cnt;
reg [2:0] write_cnt;

assign empty_o = (count == 0) ? 1'b1 : 1'b0;
assign full_o = (count == 8) ? 1'b1 : 1'b0;

always_ff @(posedge clk)
begin
  if(en_i)
  begin
    
    if(rd_i && !count)
    begin
      data_o <= FIFO_regs[read_cnt];
      read_cnt <= read_cnt + 1;
    end
    
    if(wr_i && count < 8)
    begin
      FIFO_regs[write_cnt] <= data_i;
      write_cnt <= write_cnt + 1;
    end
    
    if(read_cnt > write_cnt)
      count <= read_cnt - write_cnt;
    else
      count <= write_cnt - read_cnt;
  end
end

endmodule
