//////////////////////////////////////////////////////
// Module: dp_async_ram.v
// Dual Port Asynchronous RAM with Asynchronous Reset
// Read and Write Clock Frequencies are Different
//////////////////////////////////////////////////////
//Edited for ROB

`include "constants.vh"
`include "struct.v"
//

module rob_ram #(
  parameter WIDTH = 8, 
  ADDR = 4, 
  DEPTH = 1<< ADDR)(
     clk,
     reset,
     data_in_0,
     data_in_1,
     data_out_0,
     data_out_1,
     data_out_2,
     addr_in_0,
     addr_in_1,
     addr_out_0,
     addr_out_1,
     addr_out_2,
     wr_en_0,
     wr_en_1,
     o_en_0,
     o_en_1,
     o_en_2);
 
 //Bidirectional Ports
 input [WIDTH-1:0] data_in_0, data_in_1;
 output [WIDTH-1:0] data_out_0, data_out_1, data_out_2;
 
 //Input Ports
 input clk;
 input reset;
 input [ADDR-1:0] addr_in_0, addr_in_1;
 input [ADDR-1:0] addr_out_0, addr_out_1, addr_out_2;
 input wr_en_0, wr_en_1;
 input o_en_0, o_en_1, o_en_2;
 
 reg [WIDTH-1:0] data_0_reg, data_1_reg, data_2_reg;
 integer i;
 
 //Define Memory
 reg [WIDTH-1:0] mem[DEPTH-1:0];
 
 //Write Logic
 always_ff @(posedge clk, negedge reset)
 begin
  if(!reset)
  begin
   for(i = 0; i < DEPTH; i = i + 1)
    mem[i] <= 0;
  end
  else 
  begin 
  if(wr_en_0)
    mem[addr_in_0] <= data_in_0;
  if(wr_en_1)
    mem[addr_in_1] <= data_in_1;
  end
 end
 
 //Read Logic
 //Here data width is of 8-bits
 assign data_out_0 = (o_en_0)?mem[addr_out_0]:'z;
 assign data_out_1 = (o_en_1)?mem[addr_out_1]:'z;
 assign data_out_2 = (o_en_2)?mem[addr_out_2]:'z;
 
 always@(posedge clk)
 begin
  if(o_en_0)
   data_0_reg <= mem[addr_out_0];
  if(o_en_1)
   data_1_reg <= mem[addr_out_1];
  if(o_en_2)
   data_2_reg <= mem[addr_out_2];
 end
 
endmodule