
`include "constants.vh"

module DMEM_4_block(
	input clk,
	
	input [`DMEM_WIDTH-1:0] address_a,
	input[`XLEN-1:0] data_a,
	input rden_a,
	input wren_a,
	input [3:0] byteena_a,
	
	input [`DMEM_WIDTH-1:0] address_b,
	input[`XLEN-1:0] data_b,
	input rden_b,
	input wren_b,
	input [3:0] byteena_b,
	
	output[`XLEN-1:0] q_a,
	output[`XLEN-1:0] q_b
	
);



logic [8-1:0] data_a1, data_a2, data_a3, data_a4;
logic [8-1:0] q_a1, q_a2, q_a3, q_a4;

logic [8-1:0] data_b1, data_b2, data_b3, data_b4;
logic [8-1:0] q_b1, q_b2, q_b3, q_b4;


assign data_a4[7:0] = byteena_a[3] ? {data_a[24 +:8]} : '0;
assign data_a3[7:0] = byteena_a[2] ? {data_a[16 +:8]} : '0;
assign data_a2[7:0] = byteena_a[1] ? {data_a[8 +:8]} : '0;
assign data_a1[7:0] = byteena_a[0] ? {data_a[0 +:8]} : '0;

assign data_b4[7:0] = byteena_b[3] ? {data_b[24 +:8]} : '0;
assign data_b3[7:0] = byteena_b[2] ? {data_b[16 +:8]} : '0;
assign data_b2[7:0] = byteena_b[1] ? {data_b[8 +:8]} : '0;
assign data_b1[7:0] = byteena_b[0] ? {data_b[0 +:8]} : '0;

assign q_a[24 +: 8] = byteena_a[3] ? q_a4[7:0] : '0;
assign q_a[16 +: 8] = byteena_a[2] ? q_a3[7:0] : '0;
assign q_a[8 +: 8] = byteena_a[1] ? q_a2[7:0] : '0;
assign q_a[0 +: 8] = byteena_a[0] ? q_a1[7:0] : '0;

assign q_b[24 +: 8] = byteena_b[3] ? q_b4[7:0] : '0;
assign q_b[16 +: 8] = byteena_b[2] ? q_b3[7:0] : '0;
assign q_b[8 +: 8] = byteena_b[1] ? q_b2[7:0] : '0;
assign q_b[0 +: 8] = byteena_b[0] ? q_b1[7:0] : '0;

	parameter BACKGROUND_IMAGE_BLOCK1;
dmem #(.BACKGROUND_IMAGE(BACKGROUND_IMAGE_BLOCK1))
  dmem_block1 (		
	.address_a(address_a),
	.address_b(address_b),
	.clock(clk),
	.data_a(data_a1),
	.data_b(data_b1),
	.rden_a(rden_a),
	.rden_b(rden_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a1),
	.q_b(q_b1)
);
	defparam
		dmem_block1.altsyncram_component.init_file = BACKGROUND_IMAGE_BLOCK1;

parameter BACKGROUND_IMAGE_BLOCK2;
dmem #(.BACKGROUND_IMAGE(BACKGROUND_IMAGE_BLOCK2))
  dmem_block2 (	
	.address_a(address_a),
	.address_b(address_b),
	.clock(clk),
	.data_a(data_a2),
	.data_b(data_b2),
	.rden_a(rden_a),
	.rden_b(rden_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a2),
	.q_b(q_b2)
);
	defparam
		dmem_block2.altsyncram_component.init_file = BACKGROUND_IMAGE_BLOCK2;

parameter BACKGROUND_IMAGE_BLOCK3;
dmem #(.BACKGROUND_IMAGE(BACKGROUND_IMAGE_BLOCK3))
  dmem_block3 (	
	.address_a(address_a),
	.address_b(address_b),
	.clock(clk),
	.data_a(data_a3),
	.data_b(data_b3),
	.rden_a(rden_a),
	.rden_b(rden_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a3),
	.q_b(q_b3)
);
	defparam
		dmem_block3.altsyncram_component.init_file = BACKGROUND_IMAGE_BLOCK3;

parameter BACKGROUND_IMAGE_BLOCK4;
dmem #(.BACKGROUND_IMAGE(BACKGROUND_IMAGE_BLOCK4))
  dmem_block4 (	
	.address_a(address_a),
	.address_b(address_b),
	.clock(clk),
	.data_a(data_a4),
	.data_b(data_b4),
	.rden_a(rden_a),
	.rden_b(rden_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(q_a4),
	.q_b(q_b4)
);


endmodule