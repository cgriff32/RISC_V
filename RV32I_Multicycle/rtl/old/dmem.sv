//TODO: 
`include "constants.vh"





//module dmem(
//	
//	input clk,
//	
//	input [`XLEN-1:0] mem_addr,
//	input [`XLEN-1:0] mem_write_data,
//	
//	output [`XLEN-1:0] mem_read_data,
//	
//	input write_en,
//	input mem_en
//);
//
//reg [8-1:0] datamem [0:1023];
//
//always_ff @(posedge clk)
//begin
//	if(write_en && mem_en)
//	begin
//		datamem[mem_addr] <= mem_write_data[7:0];
//		datamem[mem_addr+1] <= mem_write_data[15:8];
//		datamem[mem_addr+2] <= mem_write_data[23:16];
//		datamem[mem_addr+3] <= mem_write_data[31:24];
//	end
//end
//
//assign mem_read_data[7:0] = (!write_en && mem_en) ? datamem[mem_addr] : 8'b0;
//assign mem_read_data[15:8] = (!write_en && mem_en) ? datamem[mem_addr+1] : 8'b0;
//assign mem_read_data[23:16] = (!write_en && mem_en) ? datamem[mem_addr+2] : 8'b0;
//assign mem_read_data[31:24] = (!write_en && mem_en) ? datamem[mem_addr+3] : 8'b0;
//
//endmodule
