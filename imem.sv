//
`include "constants.vh"
module imem(

input [`XLEN-1:0]	pc,

output [`INSTR_WIDTH-1:0]		instr
);

reg [`XLEN-1:0]	imemory [0:1023];
wire [`XLEN-1:0]	iaddr = pc[31:0];

initial 
begin

	$readmemb("./test.prog", imemory);
end

assign instr = imemory[iaddr];

endmodule