module DisplayExample2(
	input resetn,
	input clk, 
	output [8:0] color,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg writeEn,
	input key0);

	//--- Delay Counter
	parameter DELAY_TICKS = 22'd88607;
	
	reg [21:0] delayCounter;
	reg delayCounterEnable, delayCounterReset;

	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			delayCounter <= 10'd0;
		else if (delayCounterReset)
			delayCounter <= 10'd0;
		else if (delayCounterEnable)
			delayCounter <= delayCounter + 1'd1;
	end
	
	
	//--- Pixel counters
	reg [7:0] xBoundLeft, xBoundRight;
	reg [6:0] yBoundTop, yBoundBottom;
	reg direction; // 1: Down or Right, 0: Up or Left
	
	reg xEnable, yEnable, xShrink, yShrink;
	
	// X Direction Counter
	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			x <= 8'd0;
		else if (xEnable)
		begin
			if (direction)
				x <= x + 1'd1;
			else
				x <= x - 1'd1;
		end
	end

	// Y Direction Counter
	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			y <= 7'd0;
		else if (yEnable)
		begin
			if (direction)
				y <= y + 1'd1;
			else
				y <= y - 1'd1;
		end
	end
	
	// X bounds
	always @(posedge clk)
	begin
		if (sCurrent == S_INIT)
		begin
			xBoundLeft <= 8'd0;
			xBoundRight <= 8'd159;
		end
		else if (xShrink)
		begin
			if (direction)
			begin
				xBoundLeft <= xBoundLeft + 1'd1;
				xBoundRight <= xBoundRight;
			end
			else
			begin
				xBoundLeft <= xBoundLeft;
				xBoundRight <= xBoundRight - 1'd1;
			end
		end
	end

	// Y bounds
	always @(posedge clk)
	begin
		if (sCurrent == S_INIT)
		begin
			yBoundTop <= 7'd0;
			yBoundBottom <= 7'd119;
		end
		else if (yShrink)
		begin
			if (direction)
			begin
				yBoundTop <= yBoundTop;
				yBoundBottom <= yBoundBottom - 1'd1;
			end
			else
			begin
				yBoundTop <= yBoundTop + 1'd1;
				yBoundBottom <= yBoundBottom;
			end
		end
	end
	
	//--- Finite State Machine
	
	//- State Transition Labels
	
	parameter S_IDLE = 4'd0, S_INIT = 4'd1, S_DOWN0 = 4'd2, S_DOWN1 = 4'd3,
			S_RIGHT0 = 4'd4, S_RIGHT1 = 4'd5, S_UP0 = 4'd6, S_UP1 = 4'd7,
			S_LEFT0 = 4'd8, S_LEFT1 = 4'd9, S_CHECKDONE = 4'd10;
	
	
	reg [3:0] sCurrent, sNext;
	
	//- Transition between states in the FSM 
	always @(posedge clk or negedge resetn)
	begin
		if (!resetn)
			sCurrent <= S_IDLE;
		else
			sCurrent <= sNext;
	end
	
	//- Next Transition Table
	always @(*)
	begin
		// default wire values
		xEnable = 1'd0;
		yEnable = 1'd0;
		delayCounterEnable = 1'd0;
		delayCounterReset = 1'd0;
		xShrink = 1'd0;
		yShrink = 1'd0;
		writeEn = 1'd0;
		direction = 1'd0;
		
		// states
		case (sCurrent)
			S_IDLE: begin
						// key0 is active high, so it stays 1 until its pressed
						if (key0)
							sNext = S_IDLE;
						else
							sNext = S_INIT;
					end
			S_INIT: begin
						sNext = S_DOWN0;
					end
			S_DOWN0: begin // check + draw
						direction = 1'd1;
						yEnable = 1'd1;
						delayCounterReset = 1'd1;
						writeEn = 1'd1;
						if (y == (yBoundBottom-1))
						begin
							sNext = S_RIGHT0;
							xShrink = 1'd1;
						end
						else
							sNext = S_DOWN1;
					 end
			S_DOWN1: begin // wait
						delayCounterEnable = 1'd1;
						if (delayCounter == DELAY_TICKS)
							sNext = S_DOWN0;
						else
							sNext = S_DOWN1;
					 end
			S_RIGHT0: begin // check + draw
						direction = 1'd1;
						xEnable = 1'd1;
						delayCounterReset = 1'd1;
						writeEn = 1'd1;
						if (x == (xBoundRight-1))
						begin
							sNext = S_UP0;
							yShrink = 1'd1;
						end
						else
							sNext = S_RIGHT1;
					 end
			S_RIGHT1: begin // wait
						delayCounterEnable = 1'd1;
						if (delayCounter == DELAY_TICKS)
							sNext = S_RIGHT0;
						else
							sNext = S_RIGHT1;
					  end
			S_UP0:	begin // check + draw
						direction = 1'd0;
						yEnable = 1'd1;
						delayCounterReset = 1'd1;
						writeEn = 1'd1;
						if (y == (yBoundTop+1))
						begin
							sNext = S_LEFT0;
							xShrink = 1'd1;
						end
						else
							sNext = S_UP1;
					end
			S_UP1:	begin // wait
						delayCounterEnable = 1'd1;
						if (delayCounter == DELAY_TICKS)
							sNext = S_UP0;
						else
							sNext = S_UP1;
					end
			S_LEFT0: begin // check + draw
						direction = 1'd0;
						xEnable = 1'd1;
						delayCounterReset = 1'd1;
						writeEn = 1'd1;
						if (x == (xBoundLeft+1))
						begin
							sNext = S_CHECKDONE;
							yShrink = 1'd1;
						end
						else
							sNext = S_LEFT1;
					 end
			S_LEFT1: begin // wait
						delayCounterEnable = 1'd1;
						if (delayCounter == DELAY_TICKS)
							sNext = S_LEFT0;
						else
							sNext = S_LEFT1;
					 end
			S_CHECKDONE:	begin
								if (xBoundLeft == xBoundRight || yBoundBottom == yBoundTop)
									sNext = S_IDLE;
								else
									sNext = S_DOWN0;
							end
			default: sNext = S_IDLE;
		endcase
	
	end


	//--- Color Output
	/* The output color is an XOR pattern.
	 * The animation is a result of when each pixel is drawn.
	 */

	assign color[2:0] = x[2:0] ^ y[2:0];
	assign color[5:3] = x[3:1] ^ y[3:1];
	assign color[8:6] = x[4:2] ^ y[4:2];
	// assign color[8:0] = 9'b111111111;

endmodule