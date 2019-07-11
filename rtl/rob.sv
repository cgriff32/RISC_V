`include "constants.vh"
`include "struct.v"
//


//=============================================
// Function  : Synchronous (single clock) FIFO
// Coder     : Deepak Kumar Tala
// Date      : 31-October-2005
//=============================================

//Edited for asynchronous read


module FIFO #(parameter DATA_WIDTH = (1+`REG_ADDR_WIDTH+`XLEN),
                  parameter ADDR_WIDTH = 3,
                  parameter RAM_DEPTH = (1 << ADDR_WIDTH))(
input   wire                  clk      , // Clock input
input   wire                  rst      , // Active high reset

input rob_in rob_i,
output rob_out rob_o,

input   wire                  tail_en    , // Tail Enable
input   wire [DATA_WIDTH-1:0] data_in_0  , // Issue init

input wire rd_en,
input wire [ADDR_WIDTH-1:0] addr_out_0,
output  logic  [DATA_WIDTH-1:0] data_out_0 , // Issue snoop

input wire wr_en, //Write_en
input wire [ADDR_WIDTH-1:0] addr_in_1,
output  logic  [DATA_WIDTH-1:0] data_in_1 , 

input   wire                  head_en    , // Head Enable
output  logic  [DATA_WIDTH-1:0] data_out_1 ,

output [`ROB_SIZE-1:0] tag,
output  wire                  empty    , // FIFO empty
output  wire                  full       // FIFO full
);    
//-----------Internal variables-------------------
reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH :0] status_cnt;
wire [DATA_WIDTH-1:0] data_ram_0 ;
wire [DATA_WIDTH-1:0] data_ram_1 ;


//-----------Variable assignments---------------
assign full = (status_cnt == (RAM_DEPTH-1));
assign empty = (status_cnt == 0);
assign tag = wr_pointer;

//-----------Code Start---------------------------
always_ff @ (posedge clk iff rst == 0 , posedge rst)
begin : TAIL_ENABLE
  if (rst) begin
    wr_pointer <= 0;
  end else if (tail_en) begin
    wr_pointer <= wr_pointer + 1;
  end
end

always_ff @ (posedge clk iff rst == 0 , posedge rst)
begin : READ_POINTER
  if (rst) begin
    rd_pointer <= 0;
  end else if (head_en ) begin
    rd_pointer <= rd_pointer + 1;
  end
end

always_comb
begin : READ_DATA
  if (rst) begin
    data_out_0 = 0;
  end 
  else begin
    data_out_0 = data_ram_0;
  end
end

always_comb
begin
  if (rst) begin
    data_out_1 = 0;
  end 
  else begin
    data_out_1 = data_ram_1;
  end
end

always_ff @ (posedge clk iff rst == 0 , posedge rst)
begin : STATUS_COUNTER
  if (rst) begin
    status_cnt <= 0;
  // Read but no write.
  end else if ((rd_en) && !(tail_en) 
                && (status_cnt != 0)) begin
    status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if ((tail_en) && !(rd_en) 
               && (status_cnt != RAM_DEPTH)) begin
    status_cnt <= status_cnt + 1;
  end
end 

dp_async_ram #(DATA_WIDTH, ADDR_WIDTH) rob_ram(
     .clk(clk),
     .reset(rst),
     
     .wr_en_0(tail_en), //from issue
     .addr_in_0(wr_pointer),
     .data_in_0(data_in_0),
     
     .o_en_0(rd_en), //to issue
     .addr_out_0(addr_out_0),
     .data_out_0(data_ram_0),
     
     .wr_en_1(wr_en), //cdb_valid
     .addr_in_1(addr_in_1),
     .data_in_1(data_in_0),
     
     .o_en_1(head_en), //to reg
     .addr_out_1(rd_pointer),
     .data_out_1(data_ram_1)
); 

typedef struct packed
{ 
  logic full;
  logic empty;
  logic tag;
  
  logic reg_en;
  logic reg_dest;
  logic reg_value;
} rob_out;


endmodule