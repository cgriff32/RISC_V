`include "constants.vh"
`include "struct.v"

module regfile(
	
	input clk,
	input rst,
	input stall_i,
	
	input regfile_in regfile_i,
	output regfile_out regfile_o
);

reg [`XLEN-1:0] reg_file [`REG_FILE_SIZE-1:0];
wire enable_local;


//Don't overwrite r0 zero register
assign enable_local = regfile_i.write_en && |regfile_i.rd_addr;


//Zero initial regfile
integer i;
initial
begin
	for(i=0;i<32;i=i+1)
	reg_file[i] <= '0;
	
	//Initial values, SP and GP
	reg_file[2] <= 32'h200;
	reg_file[3] <= 32'h100;
end

always_ff @(posedge clk, negedge rst)
begin
  if (!rst)
  begin
	 for(i=0;i<32;i=i+1)
	 reg_file[i] <= '0;
	
	 //Initial values, SP and GP
	 reg_file[2] <= 32'h200;
	 reg_file[3] <= 32'h100;
  end
	else if(enable_local && !stall_i) //Write to regfile
	begin
		reg_file[regfile_i.rd_addr] <= regfile_i.rd_data;
	end
end

//Read from regfile (return 0 for zero register)
assign regfile_o.r1_data = |regfile_i.r1_addr ? reg_file[regfile_i.r1_addr] : 0;
assign regfile_o.r2_data = |regfile_i.r2_addr ? reg_file[regfile_i.r2_addr] : 0;

endmodule
