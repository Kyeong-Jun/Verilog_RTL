`timescale 1ns/1ps

module Reg_File(PCLK, W_ENABLE, PRESETn, ADDR, WDATA, RDATA, led0_rgb, led1_rgb);
parameter DW = 32;
parameter AW = 16;
parameter NUM = 4;
localparam REG_BASE_ADDR=16'h0100;

input PCLK, W_ENABLE, PRESETn;
input [AW-1:0] ADDR;
input [DW-1:0] WDATA;
output [DW-1:0] RDATA;
output [2:0] led0_rgb, led1_rgb;


reg [DW-1:0] mem [0:NUM-1];

integer i;


wire	b_addr_en;

assign b_addr_en = (ADDR[15:4]==REG_BASE_ADDR[15:4]) ? 1'b1 : 1'b0;

//Write
always @(posedge PCLK, negedge PRESETn) begin
	   if(~PRESETn) begin
			for(i = 0; i < NUM;  i = i + 1) begin
				mem[i] = {DW{1'b0}};
			end
	   end
	   else if(W_ENABLE) begin 
			mem[ADDR[3:2]] <= WDATA;
		end
end


//Read
/*
always @(ADDR, WDATA) begin
	case(ADDR[3:2])
		2'b00: RDATA = mem[0];
		2'b01: RDATA = mem[1];
		2'b10: RDATA = mem[2];
		2'b11: RDATA = mem[3];
	endcase
end
*/
assign RDATA = b_addr_en ? mem[ADDR[3:2]] : 32'h12345678;

wire [31:0] t0, t1;

assign t0 = mem[0];
assign t1 = mem[1];

assign led0_rgb = t0[2:0];
assign led1_rgb = t1[2:0];



endmodule