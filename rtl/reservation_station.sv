//
`include "constants.vh"
`include "struct.v"

module reservation_station(
	
	input clk,
	input en_i,
	
	input issue_rs_struct_o alu_i,
	output rs_alu_struct_o rs_o,
	
	input alu_cdb_struct_o cdb_i,
	input alu_rdy_i,
	
	output full_o
);

reg busy ;

logic [3:0] v1_cdb;
logic [3:0] v2_cdb;

logic [3:0] rs_copy;
logic [3:0] rs_clear;
logic [3:0] rs_dispatch;
logic [1:0] rs_dispatch_num;

logic loop_kill;

reservation_station_t [3:0] rs;
reservation_station_unkilled_t [3:0] rs_unkilled;

//New input from Issue
//Shift RS down to facilitate oldest instruction first
always_comb
begin
  rs_copy = '0;
  rs_clear = '0;
  rs_unkilled = rs;
  
  if(en_i)
  begin
    rs_copy[0] = 1;
    rs_unkilled[0].busy <= 1;
    rs_unkilled[0].op <= alu_i.issue_op;
    rs_unkilled[0].tag <= alu_i.issue_tag;
    
    if(alu_i.issue_v1_rdy)
    begin
      rs_unkilled[0].v1 <= alu_i.issue_v1;
      rs_unkilled[0].v1_rdy <= alu_i.issue_v1_rdy;
    end
    else
    begin
      rs_unkilled[0].q1 <= alu_i.issue_q1;
    end
  
    if(alu_i.issue_v2_rdy)
    begin
      rs_unkilled[0].v2 <= alu_i.issue_v2;
      rs_unkilled[0].v2_rdy <= alu_i.issue_v2_rdy;
    end
    else
    begin
      rs_unkilled[0].q2 <= alu_i.issue_q2;
    end
  end
  
  
  if((!rs[3].busy) || (rs_dispatch[3]))
  begin
    rs_copy[3] = 1;
    rs_unkilled[3] = rs[3-1];
  end
    
  for(logic [3:0] i=1; i<3; i++)    
  begin
    if(
      ((rs[3-(i+1)].busy) && (rs[3-i].busy) && !(rs_dispatch[3-(i+1)]) && (rs_dispatch[3-i])) ||
      ((rs[3-(i+1)].busy)  && !(rs[3-i].busy) && !(rs_dispatch[3-(i+1)]) && !(rs_dispatch[3-i])) ||
      (!(rs[3-(i+1)].busy)  && (rs[3-i].busy) && !(rs_dispatch[3-(i+1)]) && (rs_dispatch[3-i])) ||
      (!(rs[3-(i+1)].busy)  && !(rs[3-i].busy) && !(rs_dispatch[3-(i+1)]) && !(rs_dispatch[3-i])))
      begin
        rs_copy[3-i] = 1;
        rs_unkilled[3-i] = rs[3-(i+1)];
      end
    if((rs[3-(i+1)].busy) && (!rs[3-i].busy) && (rs_dispatch[3-(i+1)]) && (!rs_dispatch[3-i]))
      rs_clear[3-i] = 1;
  end
end

//Snoop CDB
always_comb
begin
  v1_cdb = '0;
  v2_cdb = '0;
  
  for(logic [3:0] i=0; i<3; i++)    
  begin
    if(rs[3-i].busy)
      if(!rs[3-i].v1_rdy)
        if(cdb_i.tag == rs[3-i].q1)
          v1_cdb[3-i] = 1;
      if(!rs[3-i].v2_rdy)
        if(cdb_i.tag == rs[3-i].q2)
          v2_cdb[3-i] = 1;
  end
end


//Check for dispatch
//Start at bottom of RS stack (oldest instruction)
//Kill loop (one dispatch per RS)
always_comb
begin
  rs_dispatch = '0;
  rs_dispatch_num = '0;
  loop_kill = '0;
  if(alu_rdy_i)
    for(logic [3:0] i=1; i<3; i++)    
    begin
      if(rs[3-i].busy && !loop_kill)
        if((rs[3-i].v1_rdy || v1_cdb[3-i]) && (rs[3-i].v2_rdy || v2_cdb[3-i]))
        begin
          rs_dispatch[3-i] = 1;
          rs_dispatch_num = i;
          loop_kill = 1;
        end
    end
end

//Dispatch values to ALU buffer
always_ff @(posedge clk)
begin
  if(!alu_rdy_i)
    rs_o.rs_valid <= 0;
  if(rs_dispatch)
    begin
      rs_o.rs_op <= rs[rs_dispatch_num].op;
      rs_o.rs_tag <= rs[rs_dispatch_num].tag;
      if(rs[rs_dispatch_num].v1_rdy)
        rs_o.rs_v1 <= rs[rs_dispatch_num].v1;
      else
        rs_o.rs_v1 <= cdb_i.value;
      if(rs[rs_dispatch_num].v2_rdy)
        rs_o.rs_v2 <= rs[rs_dispatch_num].v2;
      else
        rs_o.rs_v2 <= cdb_i.value;  
      
      rs_o.rs_valid <= 1;
    end
end

//Copy and Shift RS values using previous logic
always_ff @(posedge clk)
begin
  for(logic [3:0] i=0; i<4; i++)    
  begin
    if(rs_clear[i])
      rs[i] <= '0;
    else if(rs_copy[i])
    begin
      rs[i] <= rs_unkilled[i];
      if(v1_cdb[i-1] && (i > 0))
        rs[i].v1 <= cdb_i.value;
      if(v2_cdb[i-1] && (i > 0))
        rs[i].v2 <= cdb_i.value;
    end
    else
    begin
      if(v1_cdb[i])
        rs[i].v1 <= cdb_i.value;
      if(v2_cdb[i])
        rs[i].v2 <= cdb_i.value;
    end
  end
end

assign full_o = ((busy & (4'b1111)) && !rs_dispatch);
endmodule

