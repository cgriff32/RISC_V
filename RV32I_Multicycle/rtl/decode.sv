//TODO: Check forawrding for branch comp
`include "constants.vh"

module decode(
	
	input clk,
	input rst,
	
	//Data pipeline
	//From IF/ID
	input[`XLEN-1:0] pc_decode, 
	input[`XLEN-1:0] instr_decode,
	
	//From MEM/WB
	input [`XLEN-1:0] mem_wb,
	input [`XLEN-1:0] instr_wb, 
	
	//ID/EXE registers
	output reg [`REG_DATA_WIDTH-1:0] pc_exe, 
	output reg [`REG_DATA_WIDTH-1:0] instr_exe,
	output reg [`REG_DATA_WIDTH-1:0] rs1_data_exe,
	output reg [`REG_DATA_WIDTH-1:0] rs2_data_exe,
	output reg [`REG_DATA_WIDTH-1:0] imm_exe,
	
	output reg [`REG_ADDR_WIDTH-1:0] rs1_addr_exe,
	output reg [`REG_ADDR_WIDTH-1:0] rs2_addr_exe,
	output reg [`REG_ADDR_WIDTH-1:0] rd_addr_exe,
	
	//Control signals
	//Input
	input [`IMM_SEL_WIDTH-1:0] imm_sel,
	input reg_write_en,
	input [`BRANCH_OP_WIDTH-1:0] br_op,
	
	input [`FORWARD_SEL_WIDTH-1:0] branch_a_sel,
	input [`FORWARD_SEL_WIDTH-1:0] branch_b_sel,
	input [`XLEN-1:0] forward_mem,
	input [`XLEN-1:0] forward_wb,
	
	//Branch control
	output [`XLEN-1:0] br_decode,
	output [`XLEN-1:0] jal_decode,
	output [`XLEN-1:0] jalr_decode,
	output br_true,
	input flush_id
	
);

wire [`REG_ADDR_WIDTH-1:0] rs1_addr = instr_decode[19:15];
wire [`REG_ADDR_WIDTH-1:0] rs2_addr = instr_decode[24:20]; 
wire [`REG_ADDR_WIDTH-1:0] rd_addr = instr_wb[11:7]; 

wire [`XLEN-1:0] rs1_data;
wire [`XLEN-1:0] rs2_data;
wire [`XLEN-1:0] rs1_temp;
wire [`XLEN-1:0] rs2_temp;
wire [`XLEN-1:0] rd_data = mem_wb; 
logic [`XLEN-1:0] imm_wire;

logic [`XLEN-1:0] br_a;
logic [`XLEN-1:0] br_b;

wire [`XLEN-1:0] imm_jal = {{12{instr_decode[31]}}, instr_decode[19:12], instr_decode[20], instr_decode[30:21], 1'b0 };
wire [`XLEN-1:0] imm_jalr= {{21{instr_decode[31]}}, instr_decode[30:21], 1'b0 };
wire [`XLEN-1:0] imm_br = {{20{instr_decode[31]}}, instr_decode[7], instr_decode[30:25], instr_decode[11:8], 1'b0 };

regfile regfile(
	clk,  
	rst,
	rd_addr, 
	rd_data, 
	rs1_addr, 
	rs2_addr, 
	rs1_data, 
	rs2_data,
	reg_write_en
);

branch_comp branch_comp(
	br_a,
	br_b,
	br_op,
	br_true
);

always_comb
begin
	
	case(branch_a_sel)
		`FORWARD_SEL_EXE : br_a = rs1_data;
		`FORWARD_SEL_MEM : br_a = forward_mem;
		`FORWARD_SEL_WB : br_a = forward_wb;
		default : br_a = rs1_data;
	endcase
	
	case(branch_b_sel)
		`FORWARD_SEL_EXE : br_b = rs2_data;
		`FORWARD_SEL_MEM : br_b = forward_mem;
		`FORWARD_SEL_WB : br_b = forward_wb;
		default : br_b = rs2_data;
	endcase
	
	case(imm_sel)
		`IMM_SEL_I : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:20] };
		`IMM_SEL_S : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:25], instr_decode[11:7] };
		`IMM_SEL_B : imm_wire = {{20{instr_decode[31]}}, instr_decode[7], instr_decode[30:25], instr_decode[11:8], 1'b0};
		`IMM_SEL_J : imm_wire = {{12{instr_decode[31]}}, instr_decode[19:12], instr_decode[20], instr_decode[30:21], 1'b0};
		`IMM_SEL_U : imm_wire = {instr_decode[31:12], 12'b0 };
		default : imm_wire = {{21{instr_decode[31]}}, instr_decode[30:20] };
	endcase
	
end

assign jalr_decode= rs1_data + imm_jalr;
assign jal_decode= pc_decode + imm_jal;
assign br_decode= pc_decode + imm_br;

always_ff @(posedge clk, negedge rst)
begin
	if(!rst)
	begin
		pc_exe <= '0;
		instr_exe <= '0;
		rs1_data_exe <= '0;
		rs2_data_exe <= '0;
		imm_exe <= '0;
		rs1_addr_exe <= '0;
		rs2_addr_exe <= '0;
		rd_addr_exe <= '0;
	end
	else
	begin
		if (flush_id)
		 begin
			
			pc_exe <= '0;
			instr_exe <= '0;
			imm_exe <= '0;
			
			rs1_data_exe <= '0;
			rs2_data_exe <= '0;
			
			rs1_addr_exe <= '0;
			rs2_addr_exe <= '0;
			rd_addr_exe <= '0;
			
		end
		else
		begin
			
			pc_exe <= pc_decode;
			instr_exe <= instr_decode;
			imm_exe <= imm_wire;
			
			rs1_data_exe <= (|(rs1_addr)) ? rs1_temp : '0;
			rs2_data_exe <= (|(rs2_addr)) ? rs2_temp : '0;
			
			rs1_addr_exe <= rs1_addr;
			rs2_addr_exe <= rs2_addr;
			rd_addr_exe <= instr_decode[11:7];
		end
	end
end
assign rs1_temp = ((rd_addr == rs1_addr) && reg_write_en) ? rd_data : rs1_data;
assign rs2_temp = ((rd_addr == rs2_addr) && reg_write_en) ? rd_data : rs2_data;

endmodule
