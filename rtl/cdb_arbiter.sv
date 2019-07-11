//
`include "constants.vh"
`include "struct.v"

module cdb_arbiter(
	
	input clk,
	
	input [2:0] cdb_req,
	input cdb_struct_t cdb_bus,
	output reg [2:0] fu_sel
	
);

reg [3:0] alu_sel;
logic [2:0] fu_sel_wire;
reg [1:0] last_grant;
logic [1:0] last_grant_wire;

always_comb
begin
fu_sel_wire = '0;
last_grant_wire = last_grant;

  //Pri: ld/st, alu(rr)
  casez(cdb_req)
    3'b1?? : begin
      //give ld/st pro
      fu_sel_wire <= 3'b100;
    end
    3'b01?,
    3'b0?1 : begin
      if(last_grant == 2'b01)
      begin
        if(cdb_req[1] == 1)
        begin 
          fu_sel_wire <= 3'b010;
          last_grant_wire <= 2'b10;
        end
        else if (cdb_req[1:0] == 2'b01)
        begin 
          fu_sel_wire <= 3'b010;
          last_grant_wire <= 2'b01;
        end
      end
      else if(last_grant == 2'b10)
      begin
        if(cdb_req[0] == 1)
        begin 
          fu_sel_wire <= 3'b001;
          last_grant_wire <= 2'b01;
        end
        else if (cdb_req[1:0] == 2'b10)
        begin 
          fu_sel_wire <= 3'b010;
          last_grant_wire <= 2'b10;
        end
      end
    end
  endcase
end

always_ff @(posedge clk)
begin
  last_grant <= last_grant_wire;
  fu_sel <= fu_sel_wire;
end

endmodule