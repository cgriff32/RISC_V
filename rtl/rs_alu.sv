//
`include "constants.vh"
`include "struct.v"

module rs_alu(
	
	input clk,
	
	input rs_alu_struct_o alu_i,
	output alu_cdb_struct_o alu_o,
	
	output alu_rdy_o,
	input cdb_busy_i
);

assign alu_rdy_o = !cdb_busy_i;

logic [`XLEN-1:0] a = alu_i.rs_v1;
logic [`XLEN-1:0] b = alu_i.rs_v2;	
logic [`ALU_OP_WIDTH-1:0] alu_op = alu_i.rs_op;
logic [`XLEN-1:0] out;


alu alu(
  .a(a),
  .b(b),
  .op(op),
  .out(out)
);

always_ff @(posedge clk)
begin
  
  if(!cdb_busy_i)
  begin
    alu_o.value <= out;
    alu_o.tag <= alu_i.rs_tag;
    alu_o.tag <= alu_i.rs_valid;
  end
  
end

endmodule