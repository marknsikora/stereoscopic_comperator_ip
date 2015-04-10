`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2015 06:10:14 PM
// Design Name: 
// Module Name: comperator_axi_ip_v1_0_simple_controller
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


module comperator_axi_ip_v1_0_simple_controller
(
    aclk,
    aresetn,
    go,
    go0,
    go1,
    done0,
    done1,
    running
);
    input wire aclk;
    input wire aresetn;
    input wire go;
    output reg go0;
    output reg go1;
    input wire done0;
    input wire done1;
    output reg running;
    
    localparam STATE_RESET = 2'd0;
    localparam STATE_INIT  = 2'd1;
    localparam STATE_GO    = 2'd2;
    localparam STATE_WAIT  = 2'd3;
    
    reg [1:0] state;
	reg [1:0] Nstate;
    
    initial
    begin
        state = STATE_RESET;
		Nstate = STATE_RESET;
    end
    
    always @(*)
    begin
		if (state == STATE_RESET)
		begin
			Nstate = STATE_INIT;
		end
        else if (state == STATE_INIT)
        begin
            if (go == 1'b1)
                Nstate = STATE_GO;
            else
                Nstate = STATE_INIT;
        end
		else if (state == STATE_GO)
		begin
			Nstate = STATE_WAIT;
		end
		else if (state == STATE_WAIT)
		begin
			if (done0 == 1'b1 && done1 == 1'b1)
				Nstate = STATE_GO;
            else
                Nstate = STATE_WAIT;
		end
		else
		begin
			Nstate = STATE_RESET;
		end 
    end
	
	always@(posedge aclk) begin
		if (aresetn == 1'b0)
            state <= STATE_RESET;
		else
			state <= Nstate;
			
	    go0 <= (Nstate == STATE_GO);
        go1 <= (Nstate == STATE_GO);
        running <= (Nstate == STATE_GO || Nstate == STATE_WAIT);
	end
	

endmodule
