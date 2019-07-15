//
`include "constants.vh"
`include "struct.v"

module cdb_arbiter(
	
	input clk,
	input rst,
	input stall_i,
	
	input [2:0] cdb_req,
	output [2:0] fu_sel
	
);

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
    default: fu_sel_wire <= '0;
  endcase
end

always_ff @(posedge clk)
begin
  if (!rst)
  begin
    last_grant <= 2'b10;
    //fu_sel <= '0;
  end
  else
  begin  
    if(!stall_i)
    begin
      last_grant <= last_grant_wire;
      //fu_sel <= fu_sel_wire;
    end
  end
end

assign fu_sel = fu_sel_wire;
assign cdb_bus = !fu_sel ? '0 : 'z;

endmodule