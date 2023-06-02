`timescale 1ns/1ps

module tb();
parameter DW = 32;
parameter AW = 32;

reg PCLK, PRESETn, PSELx, PENABLE, PWRITE;
reg [AW-1:0] PADDR;
reg [DW-1:0] PWDATA;
wire PREADY, PSLVERR;
wire [DW-1:0] PRDATA;


APB_SLAVE aa(PCLK, PRESETn, PADDR, PSELx, PENABLE, PWRITE, PWDATA, PREADY, PSLVERR, PRDATA);

always #5 PCLK = ~PCLK;

initial begin
	PCLK = 0; PRESETn = 1; PADDR = 0; PSELx = 0; PENABLE = 0; PWRITE = 1; PWDATA = 0;
	#1 PRESETn = 0;
	#1 PRESETn = 1;
	#20 PENABLE = 1;
	#20 PENABLE = 0;
	
	//write
	#24 PSELx = 1; PWDATA = 32'd10;
	#20 PENABLE = 1;
	#10 PSELx = 0; PENABLE = 0;
	
	#30;
	//read
	#20 PSELx =1; PWRITE = 0; PADDR = 32'd8;
	#10 PENABLE = 1;
	#30 PSELx = 0; PENABLE = 0;
	
	#40 PSELx =1; PWRITE = 0; PADDR = 32'd0;
	#20 PENABLE = 1;
	#30 PSELx = 0; PENABLE = 0;
	
	#40 $stop;
end

endmodule