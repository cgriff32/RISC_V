//
`include "constants.vh"
module imem(

input [`REG_DATA_WIDTH-1:0]	pc,

output [`INSTR_WIDTH-1:0]		instr
	
);

reg [`REG_DATA_WIDTH-1:0] 	imemory [0:1023];
wire [`REG_DATA_WIDTH-1:0] iaddr = pc[31:0];

initial 
begin

	$readmemb("./test.prog", imemory);
end

assign instr = imemory[iaddr];

endmodule
