`timescale 1ns/1ps

module Reg_File(PCLK, W_ENABLE, PRESETn, PADDR, PWDATA, PRDATA);
parameter DW = 32;
parameter AW = 16;
parameter NUM = 4;

input PCLK, W_ENABLE, PRESETn;
input [AW-1:0] PADDR;
input [DW-1:0] PWDATA;
output [DW-1:0] PRDATA;


reg [DW-1:0] mem [0:NUM-1];

integer i;


//Write
always @(posedge PCLK, negedge PRESETn) begin
	   if(~PRESETn) begin
			for(i = 0; i < NUM;  i = i + 1) begin
				mem[i] = {DW{1'b0}};
			end
	   end
	   else if(W_ENABLE) begin 
			mem[PADDR[3:2]] <= PWDATA;
		end
end


//Read
assign PRDATA = mem[PADDR[3:2]];
/*
always @(PADDR) begin
	case(PADDR[3:2])
		2'b00: PRDATA = mem[0];
		2'b01: PRDATA = mem[1];
		2'b10: PRDATA = mem[2];
		2'b11: PRDATA = mem[3];
	endcase


end
*/


endmodule