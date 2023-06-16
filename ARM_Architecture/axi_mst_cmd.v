module axi_mst_cmd
(
	input					rstn, clk, 
	input		[15:0]		addr,
	input					wr,
	input		[31:0]		wdata,
	output	reg	[31:0]		rdata,
	
	output	reg	[31:0]		addr_out,
	output	reg	[31:0]		data_out,
	output  reg             wr_cmd,
	output  reg             rd_cmd,
	
	input                   done_in,
	input      [1:0]        status_in,
	input		[31:0]		data_in
);

// arress_reg   : 0x0000    // write write or read address
// wdata_reg    : 0x0004    // write write data
// cmd_reg      : 0x0008    //write 0/1  , bit[0] ? wrire : read, 

// read_reg     : 0x0008    //[0]->done, [5:4]->status
// read_reg     : 0x000C    //rd_data
                
localparam      ADDR_REG    = 16'h0000;
localparam      WDATA_REG   = 16'h0004;
localparam      CMD_STS_REG = 16'h0008; 
localparam      RDATA_REG   = 16'h000C;

wire        addr_reg_en;
wire        wdata_reg_en;
wire        cmd_sts_reg_en;
wire        rdata_reg_en;

assign addr_reg_en = (addr==ADDR_REG);
assign wdata_reg_en = (addr==WDATA_REG);
assign cmd_sts_reg_en = (addr==CMD_STS_REG);
assign rdata_reg_en = (addr==RDATA_REG);
	
always @(posedge clk, negedge rstn)
	if (!rstn)
        addr_out <= 32'h0;
	else if (addr_reg_en & wr)
		addr_out <= wdata;

always @(posedge clk, negedge rstn)
	if (!rstn)
        data_out <= 32'h0;
	else if (wdata_reg_en & wr)
		data_out <= wdata;
 
always @(posedge clk, negedge rstn)
	if (!rstn) begin
	   wr_cmd <= 1'b0;
	   rd_cmd <= 1'b0;
    end
	else if (cmd_sts_reg_en & wr) begin
	   wr_cmd <= wdata[0];
	   rd_cmd <= ~wdata[0];
    end
    else begin
	   wr_cmd <= 1'b0;
	   rd_cmd <= 1'b0;
    end
 
//
always @(addr, addr_out, data_out, status_in, done_in, data_in)
    case (addr)
        ADDR_REG        : rdata = addr_out;
        WDATA_REG       : rdata = data_out;
        CMD_STS_REG     : rdata = {26'b0, status_in, 3'b0, done_in};
        RDATA_REG       : rdata = data_in;
        default         : rdata = 32'h12345678;
    endcase
    
endmodule