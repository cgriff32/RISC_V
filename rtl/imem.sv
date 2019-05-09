//
`include "constants.vh"

module imem(

input [`XLEN-1:0]				pc,

output [`INSTR_WIDTH-1:0]	instr
);

reg [`INSTR_WIDTH-1:0]	imemory [0:1023];
wire [`XLEN-1:0]	iaddr = {2'b0, pc[31:2]};

initial 
begin

	$readmemb("E:/Thesis/RISCV/RISC_V/rtl/test_bin.txt", imemory);
end

assign instr = imemory[iaddr];

endmodule