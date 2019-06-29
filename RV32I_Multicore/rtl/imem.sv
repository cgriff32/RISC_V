//
`include "constants.vh"

module imem(
	
	input [`XLEN-1:0] pc,
	output [`INSTR_WIDTH-1:0] instr
);
parameter mod_num = 1;

reg [`INSTR_WIDTH-1:0] imemory [0:1023];
wire [`XLEN-1:0] iaddr = {2'b0, pc[31:2]};

initial 
begin
  $readmemb("E:/Thesis/RISCV/RV32I_Multicore/rtl/test_bin1.txt", imemory);
  //$readmemb($sformatf("E:/Thesis/RISCV/RISC_V/rtl/test_bin%0d.txt",mod_num), imemory);

end

assign instr = imemory[iaddr];

endmodule
