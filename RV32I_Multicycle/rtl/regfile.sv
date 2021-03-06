`include "constants.vh"

module regfile(
	
	input clk,
	input rst,
	
	input [`REG_ADDR_WIDTH-1:0] rd_addr,
	input [`XLEN-1:0] rd_data,
	
	input [`REG_ADDR_WIDTH-1:0] r1_addr, 
	input [`REG_ADDR_WIDTH-1:0] r2_addr,
	output [`XLEN-1:0] r1_data, 
	output [`XLEN-1:0] r2_data,
	
	input write_en
);

reg [`XLEN-1:0] reg_file [0:`REG_FILE_SIZE-1];
wire enable_local;

//Don't overwrite r0 zero register
assign enable_local = write_en && |rd_addr;

always_ff @(posedge clk, negedge rst)
begin
	if(!rst)
	begin
		//Initial values, SP and GP
		reg_file[2] <= 32'h200;
		reg_file[3] <= 32'h100;
		reg_file[0] <= '0;
		reg_file[1] <= '0;
		reg_file[9] <= '1;
//		for(int i=4; i<32; i++)
//		begin
//		   reg_file[i] <= '0;
//		end
		   
	end
	else
	begin
		if(write_en) //Write to regfile
		begin
			reg_file[rd_addr][31:0] <= rd_data[31:0];
		end
	end
end

//Read from regfile (return 0 for zero register)
//assign r1_data = |r1_addr ? reg_file[r1_addr] : 0;
//assign r2_data = |r2_addr ? reg_file[r2_addr] : 0;
assign r1_data = reg_file[r1_addr];
assign r2_data = reg_file[r2_addr];
endmodule
