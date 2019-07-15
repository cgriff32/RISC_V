//Issue/Decode logic
//Handle branches
//Determine which reservation station to send instr to
//Gen immediates

//TODO: 4-way issue


`include "constants.vh"
`include "struct.v"

module instr #(
  parameter FIFO_DATA_WIDTH = (`THREAD_WIDTH+`XLEN+`INSTR_WIDTH),
  parameter FIFO_ADDR_WIDTH = 2,
  parameter FIFO_RAM_DEPTH = 1 << FIFO_ADDR_WIDTH)     
  (
	
	input clk,
	input rst,
	input stall_i,
	
	input instr_in instr_i,
	output instr_out instr_o
);

logic [`INSTR_WIDTH-1:0] instr_temp;

instr_fifo_t instr_fifo_t; 

imem imem(
  .pc(instr_i.pc_pc),
  .thread_id(instr_i.pc_thread_id),
  .instr(instr_temp)
  );
  

assign instr_fifo_t.wr_en = (!instr_fifo_t.full && !stall_i);
assign instr_fifo_t.data_in = {instr_i.pc_thread_id, instr_i.pc_pc, instr_temp};
assign instr_fifo_t.rd_en = (instr_i.decode_ack);

assign instr_o.fifo_empty = instr_fifo_t.empty;
assign instr_o.fifo_full = instr_fifo_t.full;

assign instr_o.thread_id = instr_fifo_t.data_out[((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1):(`XLEN+`INSTR_WIDTH)];
assign instr_o.pc = instr_fifo_t.data_out[(`XLEN+`INSTR_WIDTH)-1:(`INSTR_WIDTH)];
assign instr_o.instr = instr_fifo_t.data_out[(`INSTR_WIDTH)-1:0];

FIFOv2 #((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH),3) instr_fifo(
  .DATAOUT(instr_fifo_t.data_out), 
  .full(instr_fifo_t.full), 
  .empty(instr_fifo_t.empty), 
  .clock(clk), 
  .reset(rst), 
  .wn(instr_fifo_t.wr_en && !instr_fifo_t.full), 
  .rn(instr_fifo_t.rd_en && !instr_fifo_t.empty), 
  .DATAIN(instr_fifo_t.data_in)
  );
  
  
endmodule

