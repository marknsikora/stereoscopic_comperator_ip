`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2015 06:10:14 PM
// Design Name: 
// Module Name: comperator_axi_ip_v1_0_block_reader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module comperator_axi_ip_v1_0_block_reader
#(
    BLOCK_SIZE = 8
)
(
    aclk,
    aresetn,
    
    // First input frame
    s_axis_tdata,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tuser,
    s_axis_tvalid,
    
    go,
    done,
    block,
    count
);
    localparam DATA_WIDTH = 24;
    localparam BLOCK_WIDTH = BLOCK_SIZE*DATA_WIDTH;
    
    input wire aclk;
    input wire aresetn;
    
    input wire [DATA_WIDTH-1:0] s_axis_tdata;
    input wire s_axis_tlast;
    output reg s_axis_tready;
    input wire s_axis_tuser;
    input wire s_axis_tvalid;
    
    input wire go;
    output reg done;
    output reg [BLOCK_WIDTH-1:0] block;
    output reg [15:0] count;

    localparam STATE_RESET = 3'b000;
    localparam STATE_READY = 3'b001;
    localparam STATE_VALID = 3'b010;
    localparam STATE_INVALID = 3'b011;
    localparam STATE_EOL = 3'b100;
    localparam STATE_DONE = 3'b101;
    
    reg [2:0] state;
	reg [2:0] Nstate;
    
    initial
    begin
        state = STATE_RESET;
        Nstate = STATE_RESET;
    end

    always @(*)
    begin
		if (state == STATE_RESET)
		begin
			if (go == 1'b1)
				Nstate = STATE_READY;
            else
                Nstate = STATE_RESET;
		end
		else if (state == STATE_READY || state == STATE_VALID || state == STATE_INVALID)
		begin
			if (s_axis_tvalid == 1'b1 && (s_axis_tlast == 1'b1 || count == BLOCK_SIZE-1))
				Nstate = STATE_EOL;
			else if (s_axis_tvalid == 1'b1)
				Nstate = STATE_VALID;
			else
				Nstate = STATE_INVALID;
		end
		else if (state == STATE_EOL)
		begin
			Nstate = STATE_DONE;
		end
		else if (state == STATE_DONE)
		begin
			if (go == 1'b1)
				Nstate = STATE_READY;
            else
                Nstate = STATE_DONE;
		end
		else
		begin
			Nstate = STATE_RESET;
		end
    end
	
	always @(posedge aclk) begin
		if (aresetn == 1'b0) begin
            state <= STATE_RESET;
            count <= 16'b0;
            block <= {BLOCK_WIDTH{1'b0}};
        end
		else begin
			state <= Nstate;
					
            if (Nstate == STATE_VALID || Nstate == STATE_EOL)
                block <= {block[BLOCK_WIDTH-DATA_WIDTH-1:0], s_axis_tdata};
                
            if (Nstate == STATE_READY)
                count <= 16'b0;
            else if (Nstate == STATE_VALID)
                count <= count + 16'b1;
                
	        done <= (Nstate == STATE_DONE);
            s_axis_tready <= (Nstate == STATE_READY || Nstate == STATE_VALID || Nstate == STATE_INVALID);
        end
	end
	

endmodule
