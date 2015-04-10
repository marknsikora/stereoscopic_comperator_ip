module comperator_axi_ip_v1_0_eol_detector(
    aclk,
    aresetn,
    
    // First input frame
    s_axis_tdata,
    s_axis_tlast,
    s_axis_tuser,
    s_axis_tvalid,
    
    go,
    eol
);
    localparam DATA_WIDTH = 24;
    
    input aclk;
    input aresetn;
    
    input [DATA_WIDTH-1:0] s_axis_tdata;
    input s_axis_tlast;
    input s_axis_tuser;
    input s_axis_tvalid;
    
    input go;
    output eol;
    
    reg eol;
    
    localparam STATE_RESET = 1'b0;
    localparam STATE_EOL = 1'b1;
    
    reg state;
    
    initial
    begin
        state = STATE_RESET;
    end
    
    always @(posedge aclk)
    begin
        if (aresetn == 1'b0)
        begin
            state = STATE_RESET;
        end
        else
        begin
            if (state == STATE_RESET)
            begin
                if (s_axis_tvalid == 1'b1 && s_axis_tlast == 1'b1)
                    state = STATE_EOL;
            end
            else if (state == STATE_EOL)
            begin
                if (go == 1'b1)
                    state = STATE_RESET;
            end
            else
            begin
                state = STATE_RESET;
            end
            
            eol = (state == STATE_EOL);
        end
    end
endmodule