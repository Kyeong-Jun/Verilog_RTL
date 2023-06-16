`timescale 1ns/1ps

module AXI_LITE_Master #(parameter AW = 32, parameter DW = 32)
(
input CLK, RESETn, 

input			WRITE, READ, 
input 			[AW-1:0] ADDR, 
input 			[DW-1:0] W_DATA, 
output 			[DW-1:0] R_DATA, 
output 			DONE, 
output 	reg [1:0] 	RW_STATUS, 

//READ ADDRESS
input 			ARREADY,
output reg		ARVALID, 
output reg [AW-1:0] ARADDR, 


//READ
input RVALID, 
input [DW-1:0]  RDATA, 
input [1:0]     RRESP,
output reg      RREADY, 

//WRITE ADDRESS
input           AWREADY, 
output reg      AWVALID, 
output reg [AW-1:0] AWADDR,
 
 
//WRITE
input           WREADY,
output reg      WVALID, 
output reg [DW-1:0] WDATA, 

//RESPONSE
input           BVALID,
input [1:0]     BRESP,
output reg      BREADY
);



localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;



always @(posedge CLK) begin
    if(WRITE) AWADDR = ADDR;
    else if(READ) ARADDR = ADDR;
end 


always @(posedge CLK, negedge RESETn) begin
    if(~RESETn) RW_STATUS = 2'b00;
    else begin
        if(WRITE) RW_STATUS = BRESP;
        else if(READ) RW_STATUS = RRESP;
    end
end


always @(posedge CLK) begin
    if(WRITE) WDATA = W_DATA;
end 

assign  R_DATA = RDATA;



//READ ADDRESS
reg  [1:0] AR_ps, AR_ns;
always @(posedge CLK, negedge RESETn) begin
	if(~RESETn) AR_ps <= S0;
	else AR_ps <= AR_ns;
end

always @(AR_ps, ARREADY, READ) begin
	case(AR_ps)
		S0: begin
			ARVALID = 1'b0;
            if(READ) begin
                if(ARREADY) AR_ns = S2; //case: READY arrive late
                else AR_ns  = S1; //case: READY arrive early
            end
			else AR_ns = S0;
		end
		
		S1: begin  
			ARVALID = 1'b1;
            if(ARREADY) AR_ns = S0; 
			else AR_ns = S1;
		end

		default: begin
		  ARVALID = 1'b1;
		  AR_ns = S0;
		end
	endcase
end


//READ
reg R_ps, R_ns, DR;
always @(posedge CLK, negedge RESETn) begin
	if(~RESETn) R_ps <= S0;
	else R_ps <= R_ns;
end

always @(R_ps, RVALID, READ) begin
	case(R_ps)
		S0: begin
			RREADY = 1'b0;
			DR = 1'b1;
			if(READ) R_ns = S1;
			else R_ns = S0;
        end
		S1: begin
			RREADY = 1'b1;
			DR = 1'b0;
			if(RVALID) R_ns = S0;
			else R_ns = S1;
			end

		default: begin
		  RREADY = 1'b0;
		  DR = 1'b1;
		  R_ns = S0;
		end
	endcase
end


//WRITE ADDRESS
reg [1:0] AW_ps, AW_ns;
always @(posedge CLK, negedge RESETn) begin
	if(~RESETn) AW_ps <= S0;
	else AW_ps <= AW_ns;
end

always @(AW_ps, WRITE, AWREADY) begin
	case(AW_ps)
		S0: begin
			AWVALID = 1'b0;
			if(WRITE) begin
                if(AWREADY) AW_ns = S2; //case: READY arrive late
                else AW_ns  = S1; //case: READY arrive early;
			end
			else AW_ns = S0;
		end
		
		S1: begin
			AWVALID = 1'b1;
			if(AWREADY) AW_ns = S0;
			else AW_ns = S1;
		end
		
		default: begin
		  AWVALID = 1'b1;
		  AW_ns = S0;
		end
	endcase
end


//WRITE
reg [1:0] W_ps, W_ns;
always @(posedge CLK, negedge RESETn) begin
	if(~RESETn) W_ps <= S0;
	else W_ps <= W_ns;
end

always @(W_ps, WRITE, WREADY) begin
	case(W_ps)
		S0: begin
			WVALID	= 1'b0;
			if(WRITE) begin
			     if(WREADY) W_ns = S2; //case: READY arrive late
                else W_ns  = S1; //case: READY arrive early;
			end
			else W_ns = S0;
		end
		
		S1: begin
			WVALID = 1'b1;
			if(WREADY) W_ns = S0;
			else W_ns = S1;
		end
		
	   default: begin
		  WVALID = 1'b1;
		  W_ns = S0;
		end	
	endcase
end


//WRTE RESPONSE
reg B_ps, B_ns, DB;
always @(posedge CLK, negedge RESETn) begin
	if(~RESETn) B_ps <= S0;
	else B_ps <= B_ns;
end

always @(B_ps, WRITE, BVALID) begin
	case(B_ps)
		S0: begin
		    BREADY = 1'b0;
		    DB = 1'b1;
			if(WRITE) B_ns = S1;
			else B_ns = S0;
		end
		
		S1: begin
			BREADY = 1'b1;
			DB = 1'b0;
			if(BVALID) B_ns = S0;
			else B_ns = S1;
		end
		
	   default: begin
		    BREADY = 1'b0;
		    DB = 1'b1;
		    B_ns = S0;
		end	
	endcase
end

assign DONE = ~(DR^DB);

endmodule
