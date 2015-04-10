module comperator_axi_ip_v1_0_distance
#(
	FRAME_WIDTH = 320,
	BLOCK_SIZE = 8,
	COMPARE_STEP = 8
)
(
	aclk,
    aresetn,
	sum,
    count,
	go,
	
	done,
	grayscaled_pixel
);
    localparam DATA_WIDTH = 24;
    localparam LINE_WIDTH = FRAME_WIDTH*DATA_WIDTH;
    localparam BLOCK_WIDTH = BLOCK_SIZE*DATA_WIDTH;
    localparam NUM_BLOCKS = FRAME_WIDTH/BLOCK_SIZE;
    localparam NUM_BLOCKS_WIDTH = $clog2(NUM_BLOCKS);
    localparam NUM_COMPARES = ((FRAME_WIDTH-BLOCK_SIZE)/COMPARE_STEP) + 1;
    localparam NUM_COMPARES_WIDTH = $clog2(NUM_COMPARES);
    localparam BLOCKS_SIZE_WIDTH = $clog2(BLOCK_SIZE);
    localparam BLOCKS_RGB_WIDTH = $clog2(BLOCK_SIZE*3);
    localparam NUM_FIRST_LEVEL_COMPARE = (NUM_COMPARES/2) + (NUM_COMPARES%2);
	localparam NUM_COLOUR = 16;
	
    input aclk;
    input aresetn;
    input [15:0] sum [NUM_BLOCKS_WIDTH-1:0][NUM_COMPARES_WIDTH-1:0];
    input [15:0] count;
    input go;
    
    output done;
    output reg [DATA_WIDTH-1:0] grayscaled_pixel;
	
    localparam STATE_RESET = 3'b000;
    localparam STATE_COMPARE = 3'b001;
	reg done_compare;
	localparam STATE_PIXELIZE = 3'b010;
    localparam STATE_DONE = 3'b011;
	
    reg [2:0] state;
    
    var i, j, n, c, check_odd;
    reg [15:0] sum_temp[NUM_COMPARES_WIDTH-1:0][0:0];
    reg [15:0] level_count;
	reg [3:0] colour;
    always @(posedge aclk) begin
      if(aresetn == 1'b0) begin
	        state = STATE_RESET;
	        level_count <= 0;
			done_compare <= 0;
      end
      else begin
	    if (state == STATE_RESET) begin
		    if (go)
			    state = STATE_COMPARE;
	    end
		
        else if (state == STATE_COMPARE) begin
			if (done_compare)
			    state = STATE_PIXELIZE;
	    end
		
		else if (state == STATE_PIXELIZE) begin
			    state = STATE_DONE;
	    end
		else if (state == STATE_DONE) begin
		    if (go)
			    state = STATE_COMPARE;
	    end
		
	    if (state == STATE_COMPARE) begin
            n = NUM_COMPARES;
            c = 0;
            while (n != 0) begin
                if (level_count == 0) begin
                    for (j = 0; j < NUM_BLOCKS ; j = j + 1) begin
                        if (j == count) begin
                            for (i = 0; i < NUM_COMPARES; i = i + 1) begin
                                if (j == count) begin
									sum_temp[i][0][15:0] = i; //set index
                                    sum_temp[i][1][15:0] = sum[j][i][15:0]; //set value
									
                                end
                            end
                        end
                    end
                end
                if (c == level_count) begin 
					check_odd = n % 2;
                    n = n/2;
                    for (i = 0; i <  n; i = i + 1) begin
                        if (sum_temp[i*2][1][15:0] <= sum_temp[(i*2) + 1][1][15:0]) begin
							sum_temp[i][0][15:0] <= sum_temp[i*2][0][15:0];
                            sum_temp[i][1][15:0] <= sum_temp[i*2][1][15:0];
                        end
                        else begin
                            sum_temp[i][0][15:0] <= sum_temp[(i*2) + 1][0][15:0];
                            sum_temp[i][1][15:0] <= sum_temp[(i*2) + 1][1][15:0];
                        end
                    end
					if (n == 1) begin //if only 2 values left to compare and finished, set n=0 to exit while loop
						n = 0;
						done_compare <= 1'b1;
					end
					//deal with leftover
					if (check_odd) begin
						sum_temp[n][0][15:0] <= sum_temp[n*2][0][15:0];
						sum_temp[n][1][15:0] <= sum_temp[n*2][1][15:0];
						n = n+1;
					end
                end
				else begin
					n = (n+1)/2;
				end
                c = c + 1;
            end
			level_count <= level_count + 1'b1;
	    end
		
		else if (state == STATE_PIXELIZE) begin
			done_compare <= 1'b0; //reset done_compare
			level_count <= 1'b0; //reset level count for compare state
			//transform results into grayscaled_pixel
			colour[3:0] = (((count[15:0] * BLOCK_SIZE) - ((sum_temp[0][0][15:0]) * COMPARE_STEP)) * NUM_COLOUR)/FRAME_WIDTH;
			
			grayscaled_pixel[3:0] <= colour[3:0];
			grayscaled_pixel[11:8] <= colour[3:0];
			grayscaled_pixel[19:16] <= colour[3:0];
			end
		end
      end //this is end for if (!reset)
	 //finished 
    
    assign done = (state == STATE_DONE);
endmodule
