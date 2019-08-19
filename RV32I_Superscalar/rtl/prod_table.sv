`include "constants.vh"
`include "struct.v"

module prod_table(
	
	input clk,
	input rst,
	input stall_i,
	
  input prod_in prod_i,
  output prod_out prod_o
  );

reg [`ROB_SIZE:0] prodtable [`REG_FILE_SIZE-1:0];
wire enable_local;

//Zero initial regfile
integer i;
initial
begin
	for(i=0;i<32;i=i+1)
	begin
    prodtable[i][`ROB_SIZE-1:0] <= '0;
    prodtable[i][`ROB_SIZE] <= 1'b1;
  end
end

always_ff @(posedge clk)
begin
  if(!rst)
  begin
 	  for(i=0;i<`REG_FILE_SIZE;i=i+1)
 	  begin
      prodtable[i][`ROB_SIZE-1:0] <= '0;
      prodtable[i][`ROB_SIZE] <= 1'b1;
    end
  end
  else
    if(!stall_i)
   	  if(prod_i.issue_en) //don't overwrite r0
 	    begin
 	      if(|prod_i.rd_addr)
 	      begin
		      prodtable[prod_i.rd_addr] <= {1'b0, prod_i.rd_tag};
        end
      end
      else if(prod_i.rob_en)
      begin
        if(prodtable[prod_i.rob_dest][`ROB_SIZE-1:0] == prod_i.rob_tag )
        begin
          prodtable[prod_i.rob_dest][`ROB_SIZE] <= 1;
        end
      end  
end

//Read from regfile (return 0 for zero register)
assign prod_o.r1_valid = |prod_i.r1_addr ? prodtable[prod_i.r1_addr][`ROB_SIZE] : 1;
assign prod_o.r1_tag = |prod_i.r2_addr ? prodtable[prod_i.r1_addr][`ROB_SIZE-1:0] : 0;
assign prod_o.r2_valid = |prod_i.r1_addr ? prodtable[prod_i.r2_addr][`ROB_SIZE] : 1;
assign prod_o.r2_tag = |prod_i.r2_addr ? prodtable[prod_i.r2_addr][`ROB_SIZE-1:0] : 0;

endmodule
