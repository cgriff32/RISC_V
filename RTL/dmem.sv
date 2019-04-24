//TODO: Add mem_wr and mem_en control signals
`include "constants.vh"
module dmem(

input clk,

input [`XLEN-1:0] 	mem_addr,
input [`XLEN-1:0] 	mem_write_data,

output [`XLEN-1:0]	mem_read_data,

input write_en,
input mem_en
);

reg [`XLEN-1:0] datamem [0:2047];

always_ff @(posedge clk)
begin
	if(write_en)
		datamem[mem_addr] <= mem_write_data;
end

assign mem_read_data = (write_en == 1'b0) ? datamem[mem_addr]: 32'b0;

endmodule
