module DisplayExample1(
	input resetn,
	input clk, 
	output [8:0] color,
	output reg [7:0] x,
	output reg [6:0] y,
	output writeEn,
	input testing);
	
	reg [17:0] slowCount;
		
	wire  xCount;
	assign xCount = 1'b1;
	
	
	//--- pixel counters
	wire xClear, yClear;

	assign xClear = (x == 8'd159);

	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			x <= 8'd0;
		else if (xCount)
		begin
			if (xClear)	x <= 8'd0;
			else		x <= x + 1'b1;
		end
	end
	
	
	assign yClear = (y == 7'd119);

	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			y <= 7'd0;
		else if (xCount)
		begin
			if (xClear && yClear)	y <= 7'd0; //New frame
			else if (xClear)		y <= y + 1'b1;
		end
	end


	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			slowCount <= 18'd0;
		else if (xCount)
		begin
			if (xClear && yClear)	slowCount <= slowCount + 1'b1; //New frame
		end
	end


	//--- Color generator
/*
	assign color[2:0] = (x[2:0] ^ y[2:0]) ^ (slowCount[13:11]);
	assign color[5:3] = (x[3:1] ^ y[3:1]) ^ (slowCount[13:11]);
	assign color[8:6] = (x[4:2] ^ y[4:2]) ^ (slowCount[13:11]);
*/	

	//color[15:0] <= {6'b0,  ((x[9:0] == 10'd0) | ((x[9:0] > 10'd254) & (x[9:0] < 10'd258)) | ((x[9:0] > 10'd510) & (x[9:0] < 10'd514))) & (y[8:0] == 9'd100) ,9'b0};
	//color[15:0] <= {6'b0,  (x[9:0] == 10'd638), 9'b0};

	//color[15:0] <= {6'b0, ((y[8:0] == slowCount[9:1]) || (x[9:0] == slowCount[10:1])), 9'b0};

	//color[15:0] <= {6'b0,  ((x[9:0] == 10'd638) || (x[9:0] == 10'd0) || (y[8:0] == 9'd479) || (y[8:0] == 9'd0)), 9'b0};

	//color[15:0] <= {6'b0,  ((x[9:0] == 10'd639) || (x[9:0] == 10'd0) || (y[8:0] == 9'd0) || (y[8:0] == 9'd479)), 9'b0};

	
	assign color[2:0] = x[2:0] ^ y[2:0];
	assign color[5:3] = x[3:1] ^ y[3:1];
	assign color[8:6] = x[4:2] ^ y[4:2];
	
	
	//color[15:0] <= 16'b0000001111100000;
	//color[15:0] <= {x[9:0],y[5:0]};
	//color[15:0] <= {y[7:0],y[7:0]};
	//color[15:0] <= {6'b0,y[8:8],9'b0};
	//color[15:0] <= {6'b0,x[9:9],9'b0};
	
	//assign color = 9'd511;
	
	assign writeEn = testing;

	

	
endmodule