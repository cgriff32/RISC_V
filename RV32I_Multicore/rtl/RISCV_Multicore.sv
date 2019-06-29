module RISCV_Multicore(
	
	input clk,
	output logic [31:0] debug1,
	//output logic [31:0] debug2,
	//output logic [31:0] debug3,
	//output logic [31:0] debug4,
	
	input led_enable,
	input sw1_input,
	input sw2_input,
	output o_led
);
logic [31:0] debug2, debug3, debug4;

RISCV_Multicycle #(1) RISCV_Core1(
  .clk(clk),
  .debug(debug1)
  );


RISCV_Multicycle #(2) RISCV_Core2(
  .clk(clk),
  .debug(debug2)
  );
  
RISCV_Multicycle #(3) RISCV_Core3(
  .clk(clk),
  .debug(debug3)
  );
  
RISCV_Multicycle #(4) RISCV_Core4(
  .clk(clk),
  .debug(debug4)
  );
  
tutorial_led_blink blinky(
	.i_clock(TD_CLK27),
	.i_enable(led_enable),
	.i_switch_1(sw1_input),
	.i_switch_2(sw2_input),
	.o_led_drive(o_led)
);

endmodule
