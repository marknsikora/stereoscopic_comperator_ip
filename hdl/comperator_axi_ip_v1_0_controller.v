module comperator_axi_ip_v1_0_controller
#(
    BLOCK_SIZE = 8
)
(
    aclk,
    aresetn,
	go,
    go1,
    go2,
    done1,
    done2,
    eol1,
    eol2,
    sof1,
    sof2,
    cmp_go,
    video_go,
    video_done,
    count
);
    input aclk;
    input aresetn;
    
	input go;
    output go1;
    output go2;
    input done1;
    input done2;
    input eol1;
    input eol2;
    input sof1;
    input sof2;
    output cmp_go;
    output video_go;
    input video_done;
    
    output reg [15:0] count;
    
    reg go1;
    reg go2;
    reg cmp_go;
    reg video_go;

    localparam STATE_RESET = 4'b0000;
    localparam STATE_START_LINE = 4'b0001;
    localparam STATE_WAIT_LINE = 4'b0010;
    localparam STATE_COMPARE = 4'b0011;
    localparam STATE_START_SYNC = 4'b0100;
    localparam STATE_START_BLOCK = 4'b0110;
    localparam STATE_WAIT_BLOCK = 4'b0111;
    localparam STATE_EOL = 4'b1000;
    localparam STATE_START_VIDEO = 4'b1001;
    localparam STATE_WAIT_VIDEO = 4'b1010;
    
    reg [3:0] state;
    
    initial
    begin
        state = STATE_RESET;
    end
    
    always @(posedge aclk)
    begin
        if (aresetn == 1'b0)
        begin
            state = STATE_RESET;
            count = 16'b0;
        end
        else
        begin
            if (state == STATE_RESET)
            begin
				if (go == 1'b1)
					state = STATE_START_LINE;
            end
            else if (state == STATE_START_LINE)
            begin
                state = STATE_WAIT_LINE;
            end
            else if (state == STATE_WAIT_LINE)
            begin
                if (done1 == 1'b1 && done2 == 1'b1)
                begin
                    state = STATE_COMPARE;
                    if (sof2 ==1'b1 && sof1 == 1'b0)
                        state = STATE_START_SYNC;
                    else
                        state = STATE_COMPARE;
                end
            end
            else if (state == STATE_COMPARE)
            begin
                // Assume single cycle compare
                state = STATE_START_BLOCK;
            end
            else if (state == STATE_START_SYNC)
            begin
                state = STATE_WAIT_LINE;
            end
            else if (state == STATE_START_BLOCK)
            begin
                state = STATE_WAIT_BLOCK;
            end
            else if (state == STATE_WAIT_BLOCK)
            begin
                if (done2 == 1'b1 && eol2 == 1'b1)
                    state = STATE_EOL;
                else if (done2 == 1'b1)
                    state = STATE_COMPARE;
            end
            else if (state == STATE_EOL)
            begin
                state = STATE_START_LINE;
                if (count == BLOCK_SIZE-1)
                    state = STATE_START_VIDEO;
                else
                    state = STATE_START_LINE;
            end
            else if (state == STATE_START_VIDEO)
            begin
                state = STATE_WAIT_VIDEO;
            end
            else if (state == STATE_WAIT_VIDEO)
            begin
                if (video_done == 1'b1)
                    state = STATE_RESET;
            end
            else
            begin
                state = STATE_RESET;
            end
            
            go1 = (state == STATE_START_LINE || state == STATE_START_SYNC);
            go2 = (state == STATE_START_LINE || state == STATE_START_BLOCK);
            cmp_go = (state == STATE_COMPARE);
            video_go = (state == STATE_START_VIDEO);
            
            if (state == STATE_RESET)
                count = 16'b0;
            else if (state == STATE_EOL)
                count = count + 16'b1;
        end
    end
endmodule