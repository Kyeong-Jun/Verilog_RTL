`timescale 1ns/1ps


module Delay_Gen(clk, rst, en, cnt);
parameter DW = 8;
localparam reg_bit = log2(DW);
input clk, rst, en;
output reg [reg_bit-1:0] cnt;

reg tco;

always@(posedge clk, posedge rst) begin
	if(rst) begin cnt <= {reg_bit{1'b0}};end
	else if (en) begin
        if(cnt == DW-1) begin cnt <= {reg_bit{1'b0}};  end
		else begin cnt <= cnt +1'b1;  end
	end
end 

function integer log2;
input integer M;
begin
    log2 = 0;
    while(M > 0) begin
        M = M/2;
        log2  = log2 + 1;
    end
end
endfunction

endmodule
