module comperator_axi_ip_v1_0_sof_detector(
    aclk,
    aresetn,

    // First input frame
    s_axis_tdata,
    s_axis_tlast,
    s_axis_tuser,
    s_axis_tvalid,
    
    go,
    sof
);
    localparam DATA_WIDTH = 24;

    input aclk;
    input aresetn;

    input [DATA_WIDTH-1:0] s_axis_tdata;
    input s_axis_tlast;
    input s_axis_tuser;
    input s_axis_tvalid;
    
    input go;
    output sof;
    
    reg sof;
    
    localparam STATE_RESET = 2'b00;
    localparam STATE_WAITING = 2'b01;
    localparam STATE_SOF = 2'b10;
    
    reg [1:0] state;
    
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
                if (go == 1'b1)
                    state = STATE_WAITING;
            end
            else if (state == STATE_WAITING)
            begin
                if (s_axis_tvalid == 1'b1)
                begin
                    if (s_axis_tuser == 1'b1)
                        state = STATE_SOF;
                    else
                        state = STATE_WAITING;
                end
            end
            else if (state == STATE_SOF)
            begin
                if (go == 1'b1)
                    state = STATE_WAITING;
            end
            else
            begin
                state = STATE_RESET;
            end
            
            sof = (state == STATE_SOF);
        end
    end
endmodule