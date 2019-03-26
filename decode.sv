
`include "constants.vh"

module decode(

input clk,

//Input signals
input	[`XLEN-1:0] 					pc_decode, 
input	[`XLEN-1:0]						instr_decode,
input [`XLEN-1:0] 					mem_wb,
input [`XLEN-1:0] 					instr_wb, 

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0]	pc_exe, 
output reg [`REG_DATA_WIDTH-1:0]	instr_exe,
output reg [`REG_DATA_WIDTH-1:0]	rs1_exe,
output reg [`REG_DATA_WIDTH-1:0]	rs2_exe,

//Control signals
input 									reg_write_en
);

wire [`REG_ADDR_WIDTH-1:0] rs1_addr;
wire [`REG_ADDR_WIDTH-1:0]	rs2_addr; 
wire [`REG_ADDR_WIDTH-1:0]	rd_addr = mem_wb; 

wire [`XLEN-1:0]				rs1_data = instr_decode[19:15];
wire [`XLEN-1:0]				rs2_data = instr_decode[24:20];
wire [`XLEN-1:0]				rd_data = instr_wb[11:7];

regfile regfile(	clk,  
						rd_addr, 
						rd_data, 
						rs1_addr, 
						rs2_addr, 
						rs1_data, 
						rs2_data,
						reg_write_en);	
						
initial
begin
	pc_exe <= `XLEN'b0;
	instr_exe <= `XLEN'b0;
	rs1_exe <= `XLEN'b0;
	rs2_exe <= `XLEN'b0;
end


always_ff @(posedge clk)
begin

	pc_exe <= pc_decode;
	instr_exe <= instr_decode;
	
	rs1_exe <= rs1_data;
	rs2_exe <= rs2_data;
	
end

endmodule
