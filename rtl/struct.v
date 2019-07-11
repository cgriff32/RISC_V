`include "constants.vh"

//PC
typedef struct packed
{
  logic [`XLEN-1:0] br_pc;
  logic branch_fifo_empty;
  logic [`THREAD_WIDTH-1:0] br_thread_id;
} pc_in;

typedef struct packed
{
  reg [`THREAD_WIDTH-1:0] thread_id;
} pc_internal;

typedef struct packed
{
  reg [`XLEN-1:0] pc;
  reg [`THREAD_WIDTH-1:0] thread_id;
  
  logic br_ack;
} pc_out;

//Instr
typedef struct packed
{
  logic [`XLEN-1:0] pc_pc;
  logic [`THREAD_WIDTH-1:0] pc_thread_id;
  
  logic decode_ack;
} instr_in;

typedef struct packed
{
  logic wr_cs;
  logic rd_cs;
  logic [66:0] data_in;
  logic rd_en;
  logic wr_en;
  logic [((`THREAD_WIDTH+`XLEN+`INSTR_WIDTH)-1):0] data_out;
  logic empty;
  logic full;
} instr_fifo_t;

typedef struct packed
{
  
  logic [`THREAD_WIDTH-1:0] thread_id;
  logic [`XLEN-1:0] pc;
  logic [`INSTR_WIDTH-1:0] instr;
  logic fifo_empty;
} instr_out;

//DECODE
typedef struct packed
{
  logic [`XLEN-1:0] instr_pc;
  logic [2:0] instr_thread_id;
  logic [`INSTR_WIDTH-1:0] instr_instr;
  
} decode_in;

typedef struct packed
{
  logic [`REG_ADDR_WIDTH-1:0] rs1_addr;
  logic [`REG_ADDR_WIDTH-1:0] rs2_addr; 
  logic [`REG_ADDR_WIDTH-1:0] rd_addr; 
  
  logic [`OP_CODE_WIDTH-1:0] opcode;
  logic [2:0] funct3;
  logic funct7;
  
  logic [`IMM_SEL_WIDTH-1:0] imm_wire;
  logic [`IMM_SEL_WIDTH-1:0] imm_sel;
  logic [`FU_SEL_WIDTH-1:0] fu_sel;
  logic [`ALU_OP_WIDTH-1:0] alu_op_wire;
  logic [`ALU_OP_WIDTH-1:0] alu_op;
  logic [`OP_SEL_WIDTH-1:0] op_sel;
  
  logic illegal_instr;
} decode_internal;

typedef struct packed
{
  reg [`OP_SEL_WIDTH-1:0] op_sel;
  reg [`ALU_OP_WIDTH-1:0] alu_op;
  reg [`REG_ADDR_WIDTH-1:0] rs1;
  reg [`REG_ADDR_WIDTH-1:0] rs2;
  reg [`REG_ADDR_WIDTH-1:0] rd;
  reg [`XLEN-1:0] imm;
  reg [`XLEN-1:0] pc;
  reg [2:0] thread_id;
  reg [`FU_SEL_WIDTH-1:0] fu_sel;
} decode_out;

//ISSUE
typedef struct packed
{
  logic [`ALU_OP_WIDTH-1:0] decode_op_sel;
  logic [`FU_SEL_WIDTH-1:0] decode_fu_sel;
  logic decode_alu_op;
  logic [`XLEN-1:0] decode_pc;
  logic [`XLEN-1:0] decode_imm;
  logic [`REG_ADDR_WIDTH-1:0] decode_rs1;
  logic [`REG_ADDR_WIDTH-1:0] decode_rs2;
  logic [`REG_ADDR_WIDTH-1:0] decode_rd;
  logic decode_thread_id;
  
  logic prod_rs1_valid;
  logic prod_rs2_valid;
  logic [`ROB_SIZE-1:0] prod_rs1_tag;
  logic [`ROB_SIZE-1:0] prod_rs2_tag;
  
  logic [`XLEN-1:0] reg_rs1_value;
  logic [`XLEN-1:0] reg_rs2_value;
  
  logic rob_rs1_valid;
  logic rob_rs2_valid;
  logic [`XLEN-1:0] rob_rs1_value;
  logic [`XLEN-1:0] rob_rs2_value;
  logic [`ROB_SIZE-1:0] rob_tag;
  
  logic [`ROB_SIZE-1:0] cdb_tag;
  logic [`XLEN-1:0] cdb_value;
  
} issue_in;

typedef struct packed
{
  logic check_rs1;
  logic check_rs2;
  
  logic [`XLEN-1:0] rs1_value;
  logic [`XLEN-1:0] rs2_value;
  logic rs1_rdy;
  logic rs2_rdy;
  logic [`ROB_SIZE-1:0] rs1_q;
  logic [`ROB_SIZE-1:0] rs2_q;
  
  logic [`XLEN-1:0] rs1_imm_value;
  logic [`XLEN-1:0] rs2_imm_value;
  logic rs1_imm_rdy;
  logic rs2_imm_rdy;
  
  logic rs1_snooped;
  logic rs2_snooped;
  logic [`XLEN-1:0] rs1_snoop_value;
  logic [`XLEN-1:0] rs2_snoop_value;
  logic rs1_snoop_rdy;
  logic rs2_snoop_rdy;
  
  logic bypass_rs;
  logic [`XLEN-1:0] rd_bypass;
  
  logic br_comp;
  logic [`XLEN-1:0] br_offset;
  logic [`XLEN-1:0] st_offset;
  
  logic [`XLEN-1:0] pc_four;
  logic [`XLEN-1:0] imm_pc;
} issue_internal;

typedef struct packed
{
  reg [`THREAD_WIDTH-1:0] thread_id;

  reg [`XLEN-1:0] rs1_value;
  reg [`XLEN-1:0] rs2_value;
  reg rs1_rdy;
  reg rs2_rdy;
  reg [`ROB_SIZE-1:0] rs1_q;
  reg [`ROB_SIZE-1:0] rs2_q;
  reg [`ALU_OP_WIDTH-1:0] alu_op;
  
  reg rob_en;
  reg [`XLEN-1:0] rob_value;
  reg rob_valid;
  reg [`ROB_SIZE-1:0] rob_dest;
  
  reg br_en;
  reg br_comp;
  reg [`XLEN-1:0] br_offset;
  reg [`XLEN-1:0] br_pc;
  
  reg rs_en;
  reg [`ROB_SIZE-1:0] rs_tag;
  
  reg ld_en;
  reg [`XLEN-1:0] ld_offset;
  
  reg prod_en;
  reg [`REG_ADDR_WIDTH-1:0] prod_rd_addr;
  reg [`ROB_SIZE-1:0] prod_tag;
  
  logic [`REG_ADDR_WIDTH-1:0] rs1_addr;
  logic [`REG_ADDR_WIDTH-1:0] rs2_addr;
  logic [`ROB_SIZE-1:0] rs1_tag;
  logic [`ROB_SIZE-1:0] rs2_tag;
  
} issue_out;

//Branch control
typedef struct packed
{  
  logic issue_en;
  
  logic [`XLEN-1:0] issue_v1;
  logic [`XLEN-1:0] issue_v2;
  logic issue_v1_rdy;
  logic issue_v2_rdy;
  logic [`ROB_SIZE-1:0] issue_v1_q;
  logic [`ROB_SIZE-1:0] issue_v2_q;
  
  logic issue_thread_id;
  logic issue_comp;
  logic [5:0] issue_op ;
  logic [`XLEN-1:0] issue_offset;
  logic [`XLEN-1:0] issue_pc;
  
  logic cdb_valid;
  logic cdb_tag;
  logic cdb_value;
  
  logic pc_ack;
} branch_in;

typedef struct packed
{
  logic busy ;
  
  logic [`XLEN-1:0] v1;
  logic v1_rdy ;
  logic [`ROB_SIZE-1:0] q1;
  
  logic [`XLEN-1:0] v2;
  logic v2_rdy ;
  logic [`ROB_SIZE-1:0] q2;
} branch_unkilled_t;

typedef struct packed
{
  logic wr_cs;
  logic rd_cs;
  logic [((`THREAD_WIDTH+`XLEN)-1):0] data_in;
  logic rd_en;
  logic wr_en;
  logic [((`THREAD_WIDTH+`XLEN)-1):0] data_out;
  logic empty;
  logic full;
} branch_fifo_t;

typedef struct packed
{
  reg busy ;
  
  reg [`XLEN-1:0] v1;
  reg v1_rdy ;
  reg [`ROB_SIZE-1:0] q1;
  
  reg [`XLEN-1:0] v2;
  reg v2_rdy ;
  reg [`ROB_SIZE-1:0] q2;
} branch_internal;

typedef struct packed
{
  logic [`XLEN-1:0] pc_n;
  logic [2:0] thread_id;
  logic fifo_empty;
} branch_out;

//Reservation station
typedef struct packed
{
  logic issue_en;
  logic issue_op;
  logic issue_tag;
  logic issue_v1;
  logic issue_v1_rdy;
  logic issue_q1;
  logic issue_v2;
  logic issue_v2_rdy;
  logic issue_q2;
  
  logic cdb_valid;
  logic cdb_tag;
  logic cdb_value;
  
  logic alu_en;
} rs_in;

typedef struct packed
{
  reg busy ;
  reg [5:0] op ;
  reg [`ROB_SIZE-1:0] tag;
  
  reg [`XLEN-1:0] v1;
  reg v1_rdy ;
  reg [`ROB_SIZE-1:0] q1;
  
  reg [`XLEN-1:0] v2;
  reg v2_rdy ;
  reg [`ROB_SIZE-1:0] q2;
} reservation_station_internal;

typedef struct packed
{
  logic busy ;
  
  logic [5:0] op ;
  
  logic [`XLEN-1:0] v1;
  logic v1_rdy ;
  logic [`ROB_SIZE-1:0] q1;
  
  logic [`XLEN-1:0] v2;
  logic v2_rdy ;
  logic [`ROB_SIZE-1:0] q2;
  
  logic tag;
} reservation_station_unkilled_t;

typedef struct packed
{ 
  reg op;
  
  reg [`XLEN-1:0] v1;
  reg [`XLEN-1:0] v2;
  
  reg [`ROB_SIZE-1:0] tag;
  reg valid;
} rs_out;

//ALU
typedef struct packed
{
  logic rs_v1;
  logic rs_v2;
  logic rs_op;
  logic rs_tag;
  
  logic fifo_en;
  logic cdb_en;
}alu_in;

typedef struct packed
{
  logic [`ROB_SIZE-1:0] tag;
  logic [`XLEN-1:0] value;
  logic fifo_empty;
  logic fifo_full;
} alu_out;

//ROB
typedef struct packed
{ 
  logic issue_en;
  logic issue_value;
  logic issue_valid;
  logic issue_dest;
  
  logic cdb_valid;
  logic cdb_value;
  logic cdb_tag;
} rob_in;

typedef struct packed
{
  reg [`XLEN-1:0] value;
  reg valid;
  reg [`REG_ADDR_WIDTH-1:0] dest;
} rob_struct_t;

typedef struct packed
{ 
  logic full;
  logic empty;
  logic tag;
  
  logic reg_en;
  logic reg_dest;
  logic reg_value;
} rob_out;

typedef struct packed
{
  reg [`ROB_SIZE-1:0] tag;
  reg [`XLEN-1:0] value;
  reg valid;
} cdb_struct_t;
