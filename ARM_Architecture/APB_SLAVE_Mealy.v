`timescale 1ns/1ps

module APB_SLAVE_Mealy(PCLK, PRESETn, PADDR, PSELx, PENABLE, RDATA, PWRITE, PRDATA, PWDATA, PREADY, PSLVERR, ADDR, W_ENABLE, WDATA);
parameter DW = 32;
parameter AW = 32;
parameter DELAY = 2;

input PCLK, PRESETn, PSELx, PENABLE, PWRITE;
input [AW-1:0] PADDR;
input [DW-1:0] PWDATA, RDATA;

output reg PREADY;
output PSLVERR;
output [AW/2-1:0] ADDR;
output reg W_ENABLE;
output [DW-1:0] WDATA;
output reg [DW-1:0] PRDATA;

assign ADDR = PADDR[AW/2-1:0];
assign PSLVERR = 1'b0;
assign WDATA = PWDATA;
//assign PRDATA = RDATA;

reg [2:0] ps, ns;
parameter IDLE = 3'b000, WRITE_yet = 3'b001, WRITE = 3'b010, READ_yet = 3'b011, READ = 3'b100;



always @(posedge PCLK, negedge PRESETn) begin
	if(~PRESETn) ps <= IDLE;
	else ps <= ns;
end



wire signal;
assign signal = PSELx&PENABLE&~PWRITE;

wire [1:0] cnt;
Delay_Gen #(.DW(DELAY)) delay(PCLK, ~signal, signal, cnt); 


always @(ps, PADDR, PSELx, PENABLE, PWRITE, PWDATA, cnt) begin
	case(ps)
		IDLE: begin 
			if(PSELx&~PENABLE) begin
				W_ENABLE = 1'b0;
				PREADY = 1'b0;
				if(PWRITE) ns = WRITE_yet;
				else ns = READ_yet;
			end
			else begin
				W_ENABLE = 1'b0;
				PREADY = 1'b0;
				ns = IDLE;
			end
		end
		
		WRITE_yet: begin
			if(PSELx&PENABLE&PWRITE) begin
				PREADY = 1'b1;
				W_ENABLE = 1'b1;
				ns = WRITE;
			end
			else begin
				PREADY = 1'b0;
				W_ENABLE = 1'b0;
				ns = WRITE_yet;
			end
		end
		
		WRITE: begin
	        PREADY = 1'b0;
	        W_ENABLE = 1'b0;
			ns = IDLE;
			end
		
		READ_yet: begin       
		  if(PSELx&PENABLE&~PWRITE) begin
		      if(cnt == DELAY-1) begin
					PREADY = 1'b0;
					W_ENABLE = 1'b0;
				    ns = READ;
			  end
			end
			else begin
				ns = READ_yet;
				PREADY = 1'b0;
				W_ENABLE = 1'b0;
			end
		end
		
		READ: begin
				PREADY = 1'b1;
				W_ENABLE = 1'b0;
				PRDATA = RDATA;
				ns = IDLE;
		end
	endcase
	
end

endmodule