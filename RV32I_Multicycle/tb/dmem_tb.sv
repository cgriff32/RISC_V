`timescale 1ns/1ns
`include "constants.vh"

module dmem_tb;
	logic clk;
	

	//To Mem
	logic [`DMEM_WIDTH-1:0] dmem_addr_a;
	logic [`DMEM_WIDTH-1:0] dmem_addr_b;
	logic [`XLEN-1:0] dmem_data_in_a;
	logic [`XLEN-1:0] dmem_data_in_b;
	logic [`XLEN-1:0] dmem_data_out_a;
	logic [`XLEN-1:0] dmem_data_out_b;
	

	logic  mem_wr_mem;
	logic  mem_wr_b;
	logic  mem_en_mem;
	logic  mem_en_b;
	logic [3:0] mem_byte_mem;
	logic [3:0] mem_byte_b;
	

	
DMEM_4_block #(.BACKGROUND_IMAGE_BLOCK1("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_1_image.mif"),
              .BACKGROUND_IMAGE_BLOCK2("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_2_image.mif"),
              .BACKGROUND_IMAGE_BLOCK3("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_3_image.mif"),
              .BACKGROUND_IMAGE_BLOCK4("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_4_image.mif")) 
              DMEM_4_block(
  .clk(clk),
  .address_a(dmem_addr_a),
  .data_a(dmem_data_in_a),
  .rden_a(mem_en_mem),
  .wren_a(mem_wr_mem),
  .byteena_a(mem_byte_mem),
  .address_b(dmem_addr_b),
  .data_b(dmem_data_in_b),
  .rden_b(mem_en_b),
  .wren_b(mem_wr_b),
  .byteena_b(mem_byte_b),
  .q_a(dmem_data_out_a),
  .q_b(dmem_data_out_b)
);


initial
begin
  #15;
  dmem_addr_a <= '0;
  dmem_data_in_a <= '0;
  mem_en_mem <= 1;
  mem_wr_mem <= 0;
  mem_byte_mem <= '1;
  dmem_addr_b <= '0;
  dmem_data_in_b <= '0;
  mem_en_b <= '1;
  mem_wr_b <= '0;
  mem_byte_b <= 4'b1010;
  
end
		
  always 
  begin
    
    clk <= 0; #5;
    clk <= 1; #5;
  end

		
		
endmodule




