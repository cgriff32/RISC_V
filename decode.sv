
`include "constants.vh"

module decode(

input clk,

//Input from other stages
input	[`REG_DATA_WIDTH-1:0] 		pc_decode, 
input	[`REG_DATA_WIDTH-1:0]		instr_decode,
input [`REG_DATA_WIDTH-1:0] 		mem_wb,
input [`REG_DATA_WIDTH-1:0] 		instr_wb, 

//Output to next stage
output reg [`REG_DATA_WIDTH-1:0]	pc_exe, 
output reg [`REG_DATA_WIDTH-1:0]	instr_exe,
output reg [`REG_ADDR_WIDTH-1:0]	rs1_exe,
output reg [`REG_ADDR_WIDTH-1:0]	rs2_exe,

//Control signals
input [`IMM_SEL_WIDTH-1:0] 		imm_sel,
input 									reg_write_en

);

wire [`REG_ADDR_WIDTH-1:0] rs1;
wire [`REG_ADDR_WIDTH-1:0]	rs2; 
wire [`REG_ADDR_WIDTH-1:0]	rd; 

wire [`REG_ADDR_WIDTH-1:0] rs1_data = instr_decode[19:15];
wire [`REG_ADDR_WIDTH-1:0]	rs2_data = instr_decode[24:20];

regfile regfile(	clk, 
						reg_write_en, 
						instr_wb[11:7], 
						mem_wb, 
						rs1, 
						rs2, 
						rs1_data, 
						rs2_data);	

always @(posedge clk)
begin

	pc_exe <= pc_decode;
	instr_exe <= instr_decode;
	
	rs1_exe <= rs1_data;
	rs2_exe <= rs2_data;
	
end

endmodule
