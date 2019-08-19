`timescale 1ns/1ns
`include "constants.vh"

module RISCV_tb;
	logic clk;
	logic rst;
	logic [`IMEM_WIDTH-1:0] pc_imem;
	logic [`XLEN-1:0] imem_data_out;
	logic rden_imem;
	

	//To Mem
	logic [`DMEM_WIDTH-1:0] dmem_addr;
	logic [`XLEN-1:0] dmem_data_in;
	logic [`XLEN-1:0] dmem_data_out;
	
	logic  wren_dmem;
	logic  rden_dmem;
	logic [3:0] mem_byte_mem;
	
	logic [31:0] dmem_data_out_b;
	
	logic led;
	
	logic cpu_rdy;

  logic [7:0] vga_out;
  logic [7:0] vga_wr_x_addr;
  logic [6:0] vga_wr_y_addr;

  logic wren_vga;
  logic [`DMEM_WIDTH-1:0] dmem_addr_vga;

  logic rden_dmem_vga;
  logic [3:0] byte_en;
  
  RISCV_Multicycle DUT(
  .clk(clk),
  .rst(rst),
  .pc_imem(pc_imem),
  .imem_data_out(imem_data_out),
  .rden_imem(rden_imem),
  .dmem_addr(dmem_addr),
  .dmem_data_in(dmem_data_in),
  .dmem_data_out(dmem_data_out),
  .wren_dmem(wren_dmem),
  .rden_dmem(rden_dmem),
  .mem_byte_mem(mem_byte_mem),
  .led(led)
  );
  
imem imem(
  .address(pc_imem),
	.clock(clk),
	.q(imem_data_out),
	.rden(rden_imem)
	);
	
	DMEM_4_block #(.BACKGROUND_IMAGE_BLOCK1("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_1_image.mif"),
              .BACKGROUND_IMAGE_BLOCK2("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_2_image.mif"),
              .BACKGROUND_IMAGE_BLOCK3("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_3_image.mif"),
              .BACKGROUND_IMAGE_BLOCK4("../../RISCV/RISC_V/RV32I_Multicycle/rtl/dmem/binary/2_4_image.mif")) 
              dmem(
  .clk(clk),
  .address_a(dmem_addr),
  .data_a(dmem_data_in),
  .rden_a(rden_dmem),
  .wren_a(wren_dmem),
  .byteena_a(mem_byte_mem),
  .address_b(dmem_addr_vga),
  .data_b('0),
  .rden_b(rden_dmem_vga),
  .wren_b('0),
  .byteena_b(byte_en),
  .q_a(dmem_data_out),
  .q_b(dmem_data_out_b)
);

vgaController vgaController(
  .clk(clk),
  .rst(rst),
  .cpu_rdy(cpu_rdy),
  .data_in0(dmem_data_out_b),
  .data_in1(32'h11111111),
  .data_in2(32'h22222222),
  .data_in3(32'h33333333),
  .mem_out(vga_out),
  .mem_wr_x_addr(vga_wr_x_addr),
  .mem_wr_y_addr(vga_wr_y_addr),
  .mem_wr_en(wren_vga),
  .mem_addr(dmem_addr_vga),
  .mem_rd_en(rden_dmem_vga),
  .byte_en(byte_en)
);

initial
begin
  rst <= 0;
  cpu_rdy <= '0;
  #10
  rst <= 1;
  #10000
  cpu_rdy <= 1;

end

		
  always 
  begin
    
    clk <= 0; #2;
    clk <= 1; #2;
  end

		
		
endmodule





