`timescale 1ns/1ns
`include "constants.vh"

module rs_tb;
  integer write_data;
  
	logic clk;
	logic rst;
	logic stall_i;
	
	logic full;
	
//Reservation station
typedef struct packed
{
  logic issue_en;
  logic [`ALU_OP_WIDTH-1:0] issue_op;
  logic [`ROB_SIZE-1:0] issue_tag;
  logic [`XLEN-1:0] issue_v1;
  logic issue_v1_rdy;
  logic [`ROB_SIZE-1:0] issue_q1;
  logic [`XLEN-1:0] issue_v2;
  logic issue_v2_rdy;
  logic [`ROB_SIZE-1:0] issue_q2;
  
  logic cdb_valid;
  logic [`ROB_SIZE-1:0] cdb_tag;
  logic [`XLEN-1:0] cdb_value;
  
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
  
  logic [`ALU_OP_WIDTH-1:0] op ;
  
  logic [`XLEN-1:0] v1;
  logic v1_rdy ;
  logic [`ROB_SIZE-1:0] q1;
  
  logic [`XLEN-1:0] v2;
  logic v2_rdy ;
  logic [`ROB_SIZE-1:0] q2;
  
  logic [`ROB_SIZE-1:0] tag;
} reservation_station_unkilled_t;

typedef struct packed
{ 
  reg [`ALU_OP_WIDTH-1:0] op;
  
  reg [`XLEN-1:0] v1;
  reg [`XLEN-1:0] v2;
  
  reg [`ROB_SIZE-1:0] tag;
  reg valid;
} rs_out;

rs_in rs_i;
rs_out rs_o;
	
reservation_station DUT(
	.clk(clk),
	.stall_i(stall_i),
	.rst(rst),
	
	.rs_i(rs_i),
	.rs_o(rs_o),
	
	.full_o(full)
);
 				
		
initial
begin
  write_data = $fopen("E:/Thesis/RISCV/RISC_V/tb/output/rs_tb.txt");
  
  #5
  rst <= 0;
  stall_i <= 0;
  rs_i <= 0;
  #10;
  rst <= '1;
  
  #10;
  rs_i.issue_en <= 1;
  rs_i.issue_op <= `ALU_OP_ADD;
  rs_i.issue_tag <= 10;
  rs_i.issue_v1 <= 256;
  rs_i.issue_v1_rdy <= 1;
  rs_i.issue_v2_rdy <= 1;
  rs_i.issue_q2 <= 12;
  rs_i.cdb_valid <= 1;
  rs_i.cdb_tag <= 12;
  rs_i.cdb_value <= 16;
  rs_i.alu_en <= 1;
  
  #40;
  #140;
  #20;
  #20;
  
  #100;
$fdisplay(write_data, "%b",  rs_o);
$fclose(write_data);  // close the file   
$stop;
end
		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule

