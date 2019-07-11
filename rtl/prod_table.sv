`include "constants.vh"

module prod_table(
	
	input clk,
	
	input issue_en,
	input [`REG_ADDR_WIDTH-1:0] rd_addr,
	input [`ROB_SIZE-1:0] rd_tag,
	
	input [`REG_ADDR_WIDTH-1:0] r1_addr, 
	input [`REG_ADDR_WIDTH-1:0] r2_addr,
	output r1_valid,
	output [`ROB_SIZE-1:0] r1_tag,
	output r2_valid, 
	output [`ROB_SIZE-1:0] r2_tag,
	
	
	input rob_en,
	input rob_dest,
	input rob_tag
);

reg [`ROB_SIZE:0] prodtable [`REG_FILE_SIZE-1:0];
wire enable_local;

//Zero initial regfile
integer i;
initial
begin
	for(i=0;i<32;i=i+1)
    prodtable[i] <= '0;
    
	prodtable[0][0] <= 1; //r0 is always valid;
end

always_ff @(posedge clk)
begin
	if(issue_en && |rd_addr) //don't overwrite r0
	begin
		prodtable[rd_addr] <= {1'b0, rd_tag};
	end
  if(rob_en)
  begin
    if(prodtable[rob_dest][`ROB_SIZE:1] == rob_tag)
      prodtable[rob_dest][0] <= 1;
  end
end

//Read from regfile (return 0 for zero register)
assign r1_valid = |r1_addr ? prodtable[r1_addr][0] : 1;
assign r1_tag = |r2_addr ? prodtable[r1_addr][`ROB_SIZE:1] : 0;
assign r2_valid = |r1_addr ? prodtable[r2_addr][0] : 1;
assign r2_tag = |r2_addr ? prodtable[r2_addr][`ROB_SIZE:1] : 0;

endmodule
