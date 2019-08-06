`include "constants.vh"
`include "struct.v"
//


//=============================================
// Function  : Synchronous (single clock) FIFO
// Coder     : Deepak Kumar Tala
// Date      : 31-October-2005
//=============================================

//Edited for asynchronous read


module rob #(parameter DATA_WIDTH = (1+`XLEN+`REG_ADDR_WIDTH),
                  parameter ADDR_WIDTH = 3,
                  parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
                  
  input clk,
  input rst,
  input stall_i,
  
  input rob_in rob_i,
  output rob_out rob_o
);    

//-----------Internal variables-------------------
reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH-1:0] status_cnt;
logic [`REG_ADDR_WIDTH-1:0] temp1, temp2;
wire [DATA_WIDTH-1:0] data_in_0 ;
wire [DATA_WIDTH-1:0] data_in_1 ;
wire [DATA_WIDTH-1:0] data_out_0 ;
wire [DATA_WIDTH-1:0] data_out_1 ;
wire [DATA_WIDTH-1:0] data_out_2 ;


//-----------Variable assignments---------------
assign rob_o.full = (status_cnt == (RAM_DEPTH-1));
assign rob_o.empty = (wr_pointer == rd_pointer);
assign rob_o.tail_tag = wr_pointer;
assign rob_o.head_tag = rd_pointer;

//-----------Code Start---------------------------
always_ff @ (posedge clk, negedge rst)
begin : TAIL_ENABLE
  if (!rst)
    wr_pointer <= 0;
  else 
  if(!stall_i)
    if (rob_i.issue_en && !rob_o.full) 
      wr_pointer <= wr_pointer + 1;
end

always_ff @ (posedge clk, negedge rst)
begin : READ_POINTER
  if (!rst)
    rd_pointer <= 0; 
  else 
  if(!stall_i)
    if ((!rob_o.empty) && (rob_o.reg_en)) 
      rd_pointer <= rd_pointer + 1;
end

always_ff @ (posedge clk, negedge rst)
begin : STATUS_COUNTER
  if (!rst)
    status_cnt <= 0;
  else 
  if(!stall_i)
    if ((!rob_o.empty && rob_o.reg_en) && !(rob_i.issue_en && !rob_o.full) 
        && (status_cnt != 0)) // Read but no write.
      status_cnt <= status_cnt - 1;
    else if ((rob_i.issue_en && !rob_o.full) && !(!rob_o.empty && rob_o.reg_en) 
               && (status_cnt != RAM_DEPTH)) // Write but no read.
      status_cnt <= status_cnt + 1;
end 

assign data_in_0 = {rob_i.issue_valid, rob_i.issue_value, rob_i.issue_dest};
assign data_in_1 = {rob_i.cdb_valid, rob_i.cdb_value, `REG_ADDR_WIDTH'b0};
assign rob_o.reg_en = (data_out_0[DATA_WIDTH-1] && !rob_o.empty);
assign rob_o.reg_value = data_out_0[DATA_WIDTH-2:`REG_ADDR_WIDTH];
assign rob_o.reg_dest = data_out_0[`REG_ADDR_WIDTH-1:0];

rob_ram #(DATA_WIDTH, ADDR_WIDTH) rob_ram(
     .clk(clk),
     .reset(rst),
     
     .wr_en_0(rob_i.issue_en && !rob_o.full && !stall_i), //from issue (tail_en)
     .addr_in_0(wr_pointer),
     .data_in_0(data_in_0),
     
     .wr_en_1(rob_i.cdb_valid && !stall_i), //cdb_valid (update from cdb)
     .addr_in_1(rob_i.cdb_tag),
     .data_in_1({rob_i.cdb_valid, rob_i.cdb_value, `REG_ADDR_WIDTH'b0}),
     
     .o_en_0(1'b1 && !stall_i), //to reg (head_en)
     .addr_out_0(rd_pointer),
     .data_out_0(data_out_0),
     
     .o_en_1(1'b1), //to issue (rs1/rs2 snoop)
     .addr_out_1(rob_i.issue_rs1_tag),
     .data_out_1({rob_o.issue_rs1_valid, rob_o.issue_rs1_value,temp1}),
     
     .o_en_2(1'b1), //to issue (rs1/rs2 snoop)
     .addr_out_2(rob_i.issue_rs2_tag),
     .data_out_2({rob_o.issue_rs2_valid, rob_o.issue_rs2_value,temp2})
); 


endmodule