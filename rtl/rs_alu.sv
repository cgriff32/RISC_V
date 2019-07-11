//
`include "constants.vh"
`include "struct.v"

module rs_alu(
	
	input clk,
	
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
  .a(a),
  .b(b),
  .op(op),
  .out(out)
);

//FIFO #((`ROB_SIZE+`XLEN),2) alu_fifo(
//  .clk(clk), // Clock input
//  .rst(rst), // Active high reset
//  .wr_cs(!alu_i.fifo_en), // Write chip select
//  .rd_cs(alu_i.cdb_en), // Read chipe select
//  .data_in({alu_i.rs_tag, out}), // Data input
//  .rd_en(alu_i.cdb_en), // Read enable (from cdb arbiter)
//  .wr_en(!alu_i.fifo_en), // Write Enable (from reservation station)
//  .data_out({data_ram_tag, data_ram_value}), // Data Output
//  .empty(alu_o.fifo_empty), // FIFO empty (not empty is cdb request)
//  .full(alu_o.fifo_full) // FIFO full
//  );
endmodule