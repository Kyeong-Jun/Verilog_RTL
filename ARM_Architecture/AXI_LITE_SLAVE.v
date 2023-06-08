`timescale 1ns/1ps

module AXI_LITE_SLAVE(ACLK, ARESETn, AWVALID, AWADDR, AWREADY, WVALID, WDATA, WREADY, BREADY, BVALID, BRESP, 
ARVALID, ARADDR, ARREADY, RREADY, RVALID, RDATA, reg_RDATA, RRESP, r_ADDR, reg_WDATA, reg_w_en);
parameter DW = 32;
parameter AW = 32;
parameter DELAY = 2;

input ACLK, ARESETn;

/////READ ADDRESS
input ARVALID;
input [AW-1:0] ARADDR;
output reg ARREADY;

////READ
input RREADY;
output reg RVALID;
output reg [DW-1:0] RDATA;
output [1:0] RRESP;
assign RRESP = 2'b00;

////WRITE ADDRESS
input AWVALID;
input [AW-1:0] AWADDR;
output reg AWREADY;

////WRITE
input WVALID; 
input [DW-1:0] WDATA;
output reg  WREADY;

////WRITE RESPONSE
input BREADY;
output reg BVALID;
output [1:0] BRESP;
assign BRESP = 2'b00;

////reg
input  [DW-1:0] reg_RDATA;
output [DW-1:0] reg_WDATA;
output [15:0] r_ADDR;
output reg reg_w_en;
//assign reg_w_en = BVALID;
assign reg_WDATA = WDATA;
assign r_ADDR = reg_w_en ? AWADDR[15:0] : ARADDR[15:0];


localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

//Read Address
reg AR_ps, AR_ns;
reg AR_done;

always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) AR_ps <= S0;
	else AR_ps <= AR_ns;
end

always @(AR_ps, ARVALID) begin
	case(AR_ps)
		S0: begin
			ARREADY = 1'b0;
            if(~ARVALID) AR_ns = S0; 
			else AR_ns = S1;
		end
		
		S1: begin
			ARREADY = 1'b1;
            AR_ns = S0; 
		end
	endcase
end

//READ
reg [1:0] R_ps, R_ns;
always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) AR_done = 1'b0;
	else if(AR_ps&~R_ps) AR_done = 1'b1;
	else if(~AR_ps&R_ps) AR_done = 1'b0;
end

always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) R_ps <= S0;
	else R_ps <= R_ns;
end

always @(R_ps, AR_done, RREADY) begin
	case(R_ps)
		S0: begin
			RVALID = 1'b0;
			if(AR_done) begin 
			     if(RREADY) R_ns = S2;
			     else R_ns = S1;
			end
			else R_ns = S0;
        end
		
		S1: begin
			RVALID = 1'b1;
			if(RREADY) R_ns = S2;
			else R_ns = S1;
		end
		
		S2: begin
			RVALID = 1'b1;
			RDATA = reg_RDATA;
			R_ns = S0;
		end
	endcase
end

//WRITE ADDRESS
reg AW_ps, AW_ns;
always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) AW_ps <= S0;
	else AW_ps <= AW_ns;
end

always @(AW_ps, AWVALID) begin
	case(AW_ps)
		S0: begin
			AWREADY = 1'b0;
			if(AWVALID) AW_ns = S1;
			else AW_ns = S0;
		end
		
		S1: begin
			AWREADY = 1'b1;
			AW_ns = S0;
		end
	endcase
end


//WRITE
reg W_ps, W_ns;
reg W_done;
always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) W_ps <= S0;
	else W_ps <= W_ns;
end

always @(W_ps, WVALID) begin
	case(W_ps)
		S0: begin
			WREADY = 1'b0;
			if(WVALID) W_ns = S1;
			else W_ns = S0;
		end
		
		S1: begin
			WREADY = 1'b1;
			W_ns = S0;
		end
	endcase
end


//WRTE RESPONSE
reg [1:0] B_ps, B_ns;
always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) W_done = 1'b0;
	else if(W_ps&~B_ps) W_done = 1'b1;
	else if(~W_ps&B_ps) W_done = 1'b0;
end
always @(posedge ACLK, negedge ARESETn) begin
	if(~ARESETn) B_ps <= S0;
	else B_ps <= B_ns;
end

always @(B_ps, W_done, BREADY) begin
	case(B_ps)
		S0: begin
		    BVALID = 1'b0;
			reg_w_en = 1'b0;
			if(W_done) begin
				if(BREADY) B_ns = S2;
				else B_ns = S1;
			end 
			else B_ns = S0;
		end
		
		S1: begin
			BVALID = 1'b1;
			reg_w_en = 1'b0;
			if(BREADY) B_ns = S2;
			else B_ns = S1;
		end
		
		S2: begin
			BVALID = 1'b1;
			reg_w_en = 1'b1;
			B_ns = S0;
		end
	endcase
end



endmodule