`timescale 1ns/1ns
`include "constants.vh"

module wb_tb;

	logic clk;

//Data pipeline
//From MEM/WB
logic [`XLEN-1:0]				alu_wb;
logic [`XLEN-1:0] 			mem_wb;

logic [`XLEN-1:0]			reg_wb;

//Control signals
logic [`WB_SEL_WIDTH-1:0] 	wb_sel;


wb DUT(				.clk(clk),
            //Data pipeline
            //From MEM/WB
  						.alu_wb(alu_wb),
						.mem_wb(mem_wb),
						.reg_wb(reg_wb),
						//Control signals
						.wb_sel(wb_sel)
						);

initial
begin
  #5;
  alu_wb <= '0;
  mem_wb <= '1;
  wb_sel <= '0;
  
  #10;
  wb_sel <= '1;
  #10;
  wb_sel <= '0;
  
  
  
end

		
  always 
  begin
    
    clk <= 1; #5;
    clk <= 0; #5;
  end

		
		
endmodule



