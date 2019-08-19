//
`include "constants.vh"

module imem2(
	
	input [`XLEN-1:0] pc,
	output [`INSTR_WIDTH-1:0] instr
);
parameter MEM_FILE = "E:/Thesis/RISCV/RISC_V/RV32I_Multicycle/rtl/imem/binary/bin_1.mem";

reg [`INSTR_WIDTH-1:0] imemory [0:1023];
wire [`XLEN-1:0] iaddr = {2'b0, pc[31:2]};

initial 
begin
  $readmemb("../../RISCV/RISC_V/RV32I_Multicycle/rtl/imem/binary/bin1.mem", imemory);
  //$readmemb($sformatf("E:/Thesis/RISCV/RISC_V/rtl/test_bin%0d.txt",mod_num), imemory);

end

assign instr = imemory[iaddr];

endmodule
