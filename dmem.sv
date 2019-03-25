//
`include "constants.vh"
module dmem(

input clk,

input [`REG_DATA_WIDTH-1:0] 	mem_addr,
input [`REG_DATA_WIDTH-1:0] 	mem_write_data,

output [`REG_DATA_WIDTH-1:0]	mem_read_data,

input write_en

);

reg [`REG_DATA_WIDTH-1:0] datamem [2047:0];

always @(posedge clk)
begin
	if(write_en)
		datamem[mem_addr] <= mem_write_data;
end
assign mem_read_data = (write_en == 1'b0) ? datamem[mem_addr]: 32'b0;

endmodule
