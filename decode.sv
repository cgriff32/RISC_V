
`include "constants.vh"

module decode(

input clk,

//Input signals
input	[`XLEN-1:0] 					pc_decode, 
input	[`XLEN-1:0]						instr_decode,
input [`XLEN-1:0] 					mem_wb,
input [`XLEN-1:0] 					instr_wb, 

//Output wires
output [`XLEN-1:0] 					br_decode,
output [`XLEN-1:0] 					jal_decode,
output [`XLEN-1:0] 					jalr_decode,

//Next stage registers
output reg [`REG_DATA_WIDTH-1:0]	pc_exe, 
output reg [`REG_DATA_WIDTH-1:0]	instr_exe,
output reg [`REG_DATA_WIDTH-1:0]	rs1_exe,
output reg [`REG_DATA_WIDTH-1:0]	rs2_exe,
output reg [`REG_DATA_WIDTH-1:0] imm_exe,

//Control signals
input [`IMM_SEL_WIDTH-1:0] 		imm_sel,
input 									reg_write_en,
input [`ALU_OP_WIDTH-2:0]			br_op,

output									br_true,
input										stall_decode
);

wire [`REG_ADDR_WIDTH-1:0] rs1_addr;
wire [`REG_ADDR_WIDTH-1:0]	rs2_addr; 
wire [`REG_ADDR_WIDTH-1:0]	rd_addr = instr_wb[11:7]; 

wire [`XLEN-1:0]				rs1_data = instr_decode[19:15];
wire [`XLEN-1:0]				rs2_data = instr_decode[24:20];
wire [`XLEN-1:0]				rd_data = mem_wb; 
wire [`XLEN-1:0]				imm_wire;

wire [`XLEN-1:0]				br_a;
wire [`XLEN-1:0]				br_b;

wire [`XLEN-1:0] 				imm_jal 	= {{12{instr_decode[31]}}, instr_decode[19:12], instr_decode[20], instr_decode[30:21], 1'b0 };
wire [`XLEN-1:0] 				imm_jalr	= {{21{instr_decode[31]}}, instr_decode[30:21], 1'b0 };
wire [`XLEN-1:0] 				imm_br 	= {{20{instr_decode[31]}}, instr_decode[7], instr_decode[30:25], instr_decode[11:8], 1'b0 };


wire [`XLEN-1:0] base, offset;

regfile regfile(	clk,  
						rd_addr, 
						rd_data, 
						rs1_addr, 
						rs2_addr, 
						rs1_data, 
						rs2_data,
						reg_write_en);	
						
branch_comp branch_comp(br_a,
								br_b,
								br_op,
								br_true);
						
initial
begin
	pc_exe 		<= `XLEN'b0;
	instr_exe	<= `XLEN'b0;
	rs1_exe 		<= `XLEN'b0;
	rs2_exe 		<= `XLEN'b0;
end

always_comb
begin
	
	br_a = rs1_data;
	br_b = rs2_data;
	
	case(imm_sel)
		`IMM_SEL_I : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:20] };
		`IMM_SEL_S : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:25], instr_decode[11:7] };
		`IMM_SEL_B : imm_wire = {{20{instr_decode[31]}}, instr_decode[7], instr_decode[30:25], instr_decode[11:8], 1'b0};
		`IMM_SEL_J : imm_wire = {{12{instr_decode[31]}}, instr_decode[19:12], instr_decode[20], instr_decode[30:21], 1'b0};
		`IMM_SEL_U : imm_wire = {instr_decode[31:12], 12'b0 };
		default    : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:20] };
	endcase
	
end

assign jalr_decode	= rs1_data + imm_jalr;
assign jal_decode		= pc_decode + imm_jal;
assign br_decode		= pc_decode + imm_br;

always_ff @(posedge clk)
begin

	if (!stall_decode)
	begin
		pc_exe <= pc_decode;
		instr_exe <= instr_decode;
		imm_exe <= imm_wire;
	
		rs1_exe <= rs1_data;
		rs2_exe <= rs2_data;
	end
	
end

endmodule
