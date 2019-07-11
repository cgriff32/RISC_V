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
logic [64-1:0] temp;
logic [66:0] wtf;

instr_fifo_t instr_fifo_t; 

imem imem(
  .pc(instr_i.pc_pc),
  .thread_id(instr_i.pc_thread_id),
  .instr(wtf[31:0])
  );
  
always_comb
begin
  instr_fifo_t.data_in[31:0] = wtf[31:0];
end

assign instr_fifo_t.wr_en = !instr_fifo_t.full;
assign instr_fifo_t.wr_cs = instr_fifo_t.wr_en;
assign instr_fifo_t.data_in[((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1):(`INSTR_WIDTH)] = {instr_i.pc_thread_id, instr_i.pc_pc};
assign instr_fifo_t.rd_en = instr_i.decode_ack;
assign instr_fifo_t.rd_cs = instr_fifo_t.rd_en;

assign instr_o.fifo_empty = instr_fifo_t.empty;

assign instr_o.thread_id = instr_fifo_t.data_out[((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1):(`XLEN+`INSTR_WIDTH)];
assign instr_o.pc = instr_fifo_t.data_out[(`XLEN+`INSTR_WIDTH)-1:(`INSTR_WIDTH)];
assign instr_o.instr = instr_fifo_t.data_out[(`INSTR_WIDTH)-1:0];


FIFO #(67,FIFO_ADDR_WIDTH) instr_fifo(
  .clk(clk), // Clock input
  .rst(rst), // Active high reset
  .wr_cs(instr_fifo_t.wr_cs), // Write chip select
  .rd_cs(instr_fifo_t.rd_cs), // Read chipe select
  .data_in(instr_fifo_t.data_in), // Data input
  .rd_en(instr_fifo_t.rd_en), // Read enable
  .wr_en(instr_fifo_t.wr_en), // Write Enable
  .data_out(instr_fifo_t.data_out), // Data Output
  .empty(instr_fifo_t.empty), // FIFO empty
  .full(instr_fifo_t.full) // FIFO full
);
  
endmodule

