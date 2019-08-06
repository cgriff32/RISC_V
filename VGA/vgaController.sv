module vgaController(

input clk,
input rst,

input [31:0] mem_in0,
input [31:0] mem_in1,
input [31:0] mem_in2,
input [31:0] mem_in3,
output reg [9:0] mem_addr,
output mem_rd_en,
input cpu_rdy,
output reg [2:0] mem_out,
output reg [7:0] mem_wr_x_addr,
output reg [6:0] mem_wr_y_addr,
output reg mem_wr_en

);

reg [359:0] cpu_in0;
reg [359:0] cpu_in1;
//reg [31:0] mem_addr [3:0];
reg vga_buffer_write = 0;
int pixel;
int row;

int reg_low = 0;
int reg_high = 180;
int count = 0; 

assign mem_rd_en = !cpu_rdy;
 
always_ff @(posedge clk)
begin

	if(!cpu_rdy)
	begin
		if(count < 5)
		begin
			cpu_in0[reg_low +: 32] <= mem_in0; //0-159 bits
			cpu_in0[reg_high +: 32] <= mem_in1; //180-339 bits
			cpu_in1[reg_low +: 32] <= mem_in2; //0-159 bits
			cpu_in1[reg_high +: 32] <= mem_in3; //180-339 bits
			
			count <= count + 1;
			mem_addr <= mem_addr + 4;
			reg_low <= reg_low + 32;
			reg_high <= reg_high + 32;
		end
		else if (count == 5)
		begin
			cpu_in0[160 +: 20] <= {mem_in0[19:0]}; //160-179 bits
			cpu_in1[160 +: 20] <= {mem_in0[19:0]}; //160-179 bits
			cpu_in0[340 +: 20] <= mem_in1[19:0]; //340 - 359 bits
			cpu_in1[340 +: 20] <= mem_in3[19:0]; //340 - 359 bits
			
			count <= count + 1;
			mem_addr <= mem_addr + 4;
			reg_low <= 0;
			reg_high <= 180;
			
			pixel <= 0;
			mem_wr_x_addr <= '0;
			vga_buffer_write <= 1;
		end
		else if(vga_buffer_write)
		begin
		
			mem_wr_en <= 1;
			for(pixel = 0; pixel < 160; pixel++)
			begin
				mem_out <= cpu_in0[2:0];//[reg_low +: 2];
				reg_low <= reg_low + 3;
				mem_wr_x_addr <= mem_wr_x_addr + 3;
			end
			mem_wr_x_addr <= 0;
			reg_low <= 0;
			mem_wr_y_addr <= mem_wr_y_addr + 60;
			for(pixel = 0; pixel < 160; pixel++)
			begin
				mem_out <= cpu_in1[2:0];//[reg_low +: 2];
				reg_low <= reg_low + 3;
				mem_wr_x_addr <= mem_wr_x_addr + 3;
			end
			mem_wr_y_addr <= mem_wr_y_addr - 60;
			vga_buffer_write <= 0;
			if(row < 60)
			begin
				count <= 0;
				reg_low <= 0;
				row <= row + 1;
				mem_wr_y_addr <= mem_wr_y_addr + 1'b1;
				mem_wr_x_addr <= '0;
				mem_wr_en <= 0;
			end

		end
	end
end
			
endmodule
