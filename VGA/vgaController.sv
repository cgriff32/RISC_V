`include "../RV32I_Multicycle/rtl/constants.vh"

module vgaController(

input clk,
input rst,

input cpu_rdy,
input [31:0] data_in0,
input [31:0] data_in1,
input [31:0] data_in2,
input [31:0] data_in3,

output [7:0] mem_out,
output reg [7:0] mem_wr_x_addr,
output reg [6:0] mem_wr_y_addr,

output reg mem_wr_en,
output [`DMEM_WIDTH-1:0] mem_addr,

output mem_rd_en,
output [3:0] byte_en

);

logic [7:0] mem_out_wire[3:0];
logic [31:0] mem_in_wire[3:0];
assign mem_in_wire[0] = data_in0;
assign mem_in_wire[1] = data_in1;
assign mem_in_wire[2] = data_in2;
assign mem_in_wire[3] = data_in3;

reg [7:0] xCounter;
reg [6:0] yCounter;
reg [1:0] sub_pixel, chip_select;
reg [3:0] byte_en_reg;
	
wire xCounter_clear;
assign xCounter_clear = (xCounter*4'd4 + sub_pixel == (7'd79));

always @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
		sub_pixel <= 2'd0;
		byte_en_reg <= 4'b1111;
	end
	else 
	begin
		sub_pixel <= sub_pixel + 1'b1;
		byte_en_reg <= byte_en_reg << 1;		
	end
end

always @(posedge clk or negedge rst)
begin
	if (!rst)
		xCounter <= 8'd0;
	else if (xCounter_clear)
		xCounter <= 8'd0; 
	else if (sub_pixel == 3)
		xCounter <= xCounter + 1'b1;
end

wire yCounter_clear;
assign yCounter_clear = (yCounter == (6'd60-1'b1)); 

always @(posedge clk or negedge rst)
begin
	if (!rst)
		yCounter <= 7'd0;
	else if (xCounter_clear && yCounter_clear)
		yCounter <= 7'd0;
	else if (xCounter_clear)		//Increment when x counter resets
		yCounter <= yCounter + 1'b1;
end

always @(posedge clk or negedge rst)
begin
	if (!rst)
		chip_select <= 2'd0;
	else if (xCounter_clear && yCounter_clear)
		chip_select <= chip_select + 1'b1;
end


//assign 	mem_out = mem_in0[15:8]; //mem_in_wire[0][sub_pixel*8 +: 8]; //mem_in_wire[chip_select][sub_pixel*8 +: 8];
assign 	mem_addr = (cpu_rdy*`DMEM_WIDTH'd1200) + (yCounter*7'd20) + (xCounter)  ;
assign mem_out = mem_out_wire[chip_select];
assign byte_en = '1;
assign mem_rd_en = 1;

always_comb
begin
mem_out_wire[0] = '0;
mem_out_wire[1] = '0;
mem_out_wire[2] = '0;
mem_out_wire[3] = '0;

	case(sub_pixel)
	2'b00 : mem_out_wire[chip_select] = mem_in_wire[chip_select][24+:8];
	2'b01 : mem_out_wire[chip_select] = mem_in_wire[chip_select][0+:8];
	2'b10 : mem_out_wire[chip_select] = mem_in_wire[chip_select][8+:8];
	2'b11 : mem_out_wire[chip_select] = mem_in_wire[chip_select][16+:8];
	default : mem_out_wire[chip_select] = mem_in_wire[chip_select][7:0];
	endcase
end

always_ff @(posedge clk)
begin

	if(!rst)
	begin
		mem_wr_en <= '0; 		
		mem_wr_x_addr <= '0;
		mem_wr_x_addr <= '0;
	end 
	else
	begin
//		if(cpu_rdy)
//		begin
			mem_wr_x_addr <= xCounter*4'd4 + sub_pixel + (chip_select[0]*7'd80);
			mem_wr_y_addr <= yCounter + (chip_select[1]*6'd60);
			mem_wr_en <= 1'b1; //mem_wr_en_wire;
		//end
	end
end
			
endmodule
