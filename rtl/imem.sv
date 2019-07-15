//
`include "constants.vh"

module imem(
	
	input [`XLEN-1:0] pc,
	input [`THREAD_WIDTH-1:0] thread_id,
	output logic [`INSTR_WIDTH-1:0] instr
);

reg [`INSTR_WIDTH-1:0] imemory0 [0:256];
reg [`INSTR_WIDTH-1:0] imemory1 [0:256];
reg [`INSTR_WIDTH-1:0] imemory2 [0:256];
reg [`INSTR_WIDTH-1:0] imemory3 [0:256];
reg [`INSTR_WIDTH-1:0] imemory4 [0:256];
reg [`INSTR_WIDTH-1:0] imemory5 [0:256];
reg [`INSTR_WIDTH-1:0] imemory6 [0:256];
reg [`INSTR_WIDTH-1:0] imemory7 [0:256];
wire [`XLEN-1:0] iaddr = {2'b0, pc[31:2]};

initial 
begin
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin0.txt", imemory0);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin1.txt", imemory1);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin2.txt", imemory2);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin3.txt", imemory3);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin4.txt", imemory4);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin5.txt", imemory5);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin6.txt", imemory6);
  $readmemb("E:/Thesis/RISCV/RISC_V/rtl/binary/test_bin7.txt", imemory7);

end

always_comb
begin
  case(thread_id)
    3'b000: instr = imemory0[iaddr];
    3'b001: instr = imemory1[iaddr];
    3'b010: instr = imemory2[iaddr];
    3'b011: instr = imemory3[iaddr];
    3'b100: instr = imemory4[iaddr];
    3'b101: instr = imemory5[iaddr];
    3'b110: instr = imemory6[iaddr];
    3'b111: instr = imemory7[iaddr];
  endcase
end

endmodule
