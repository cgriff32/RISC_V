// This is linear queue / FIFO
// The queue length 8
// The data width is also 8 bits
module FIFOv2 #(parameter DATA_WIDTH = 8,
                  parameter ADDR_WIDTH = 3,
                  parameter RAM_DEPTH = (1 << ADDR_WIDTH))
                  (
                  DATAOUT, full, empty, clock, reset, wn, rn, DATAIN);
                  
                  
  output [DATA_WIDTH-1:0] DATAOUT;
  output full, empty;
  input logic [DATA_WIDTH-1:0] DATAIN;
  input clock, reset, wn, rn; // Need to understand what is wn and rn are for
  
  int i;
  reg [ADDR_WIDTH-1:0] count;
  reg [ADDR_WIDTH-1:0] wptr, rptr; // pointers tracking the stack
  reg [DATA_WIDTH-1:0] memory [RAM_DEPTH-1:0]; // the stack is 8 bit wide and 8 locations in size
  
  assign full = &(count);
  assign empty = &(!count);
  
  always @(posedge clock)
  begin
    if (!reset)
      begin
        for(i=0;i < RAM_DEPTH;i++)
        begin
        memory[i] <= '0;
        end
        //DATAOUT <= '0; 
        count <= '0;
        wptr <= '0; 
        rptr <= '0;
      end
    else 
    begin
      if (wn)
      begin
        memory[wptr] <= DATAIN;
        wptr = wptr + wn;
      end
      if (rn && !empty)
      begin
        rptr <= rptr + rn;
      end
      count = count + wn - rn;
    end
  end
  
assign DATAOUT = memory[rptr];
endmodule