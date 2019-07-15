//
`include "constants.vh"
`include "struct.v"

module rs_alu(
	
	input clk,
	input rst,
	input stall_i,
	
	input alu_in alu_i,
	output alu_out alu_o
);

//assign alu_rdy_o = !cdb_busy_i;

logic [`XLEN-1:0] a = alu_i.rs_v1;
logic [`XLEN-1:0] b = alu_i.rs_v2;	
logic [`ALU_OP_WIDTH-1:0] alu_op = alu_i.rs_op;
logic [`XLEN-1:0] out;
logic [`ROB_SIZE-1:0] data_ram_tag;
logic [`XLEN-1:0] data_ram_value; 


alu alu(
  .a(alu_i.rs_v1),
  .b(alu_i.rs_v2),
  .alu_op(alu_i.rs_op),
  .out(out)
);

FIFOv2 #((`ROB_SIZE+`XLEN),3) alu_fifo(
  .DATAOUT({data_ram_tag, data_ram_value}), 
  .full(alu_o.fifo_full), 
  .empty(alu_o.fifo_empty), 
  .clock(clk), 
  .reset(rst), 
  .wn(alu_i.fifo_en && !stall_i), 
  .rn(alu_i.cdb_en && !stall_i), 
  .DATAIN({alu_i.rs_tag, out})
  );
  
assign alu_o.tag = alu_i.cdb_en ? data_ram_tag : 'z;
assign alu_o.value = alu_i.cdb_en ? data_ram_value : 'z;
assign alu_o.valid = alu_i.cdb_en ? !alu_o.fifo_empty : 'z;
endmodule