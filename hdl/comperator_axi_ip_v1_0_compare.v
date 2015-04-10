module comperator_axi_ip_v1_0_compare
#(
    FRAME_WIDTH = 320,
    BLOCK_SIZE = 8,
	COMPARE_STEP = 8
)
(
    aclk,
    aresetn,
    block_count,
	line_count,
	line,
	block,
	go,
	
	done,
	sum
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
	
    input aclk;
    input aresetn;
    input [15:0] block_count;
    input [15:0] line_count;
    input [LINE_WIDTH-1:0] line;
    input [BLOCK_WIDTH-1:0] block;
    input go;
    
    output done;
    output reg [15:0] sum [NUM_BLOCKS_WIDTH-1:0][NUM_COMPARES_WIDTH-1:0];

    //reg [15:0] square_results [NUM_BLOCKS_WIDTH-1:0][BLOCKS_RGB_WIDTH-1:0];
    reg [15:0] square_results [NUM_COMPARES_WIDTH-1:0][BLOCKS_RGB_WIDTH-1:0];
    
    //reg [15:0] pixel_results [NUM_BLOCKS_WIDTH-1:0][BLOCKS_SIZE_WIDTH-1:0];
    reg [15:0] pixel_results [NUM_COMPARES_WIDTH-1:0][BLOCKS_SIZE_WIDTH-1:0];
	
    localparam STATE_RESET = 3'b000;
    localparam STATE_SQUARE = 3'b001;
    localparam STATE_ADD_PIXEL = 3'b010;
    localparam STATE_ADD_LINE = 3'b011;
    localparam STATE_DONE = 3'b100;
	
    reg [2:0] state;
    
    var i,j;
    var block_base, line_base;
    //for STATE_SQUARE
    reg [15:0] R_temp, G_temp, B_temp;
    //for STATE_ADD_LINE
    reg [15:0] sum_temp [NUM_COMPARES_WIDTH-1:0];
    //is var allowed? or use wire and assign instead? wire block_base, but we can't use register/wire as array index..? must confirm with Mark; 
    
    always @(posedge aclk) begin
      if(aresetn == 1'b0) begin
	state = STATE_RESET;
	
      end
      else begin
	    if (state == STATE_RESET) begin
		    if (go)
			    state = STATE_SQUARE;
	    end

	    else if (state == STATE_SQUARE) begin
		    state = STATE_ADD_PIXEL;
	    end

	    else if (state == STATE_ADD_PIXEL) begin
		    state = STATE_ADD_LINE;
	    end

	    else if (state == STATE_ADD_LINE) begin
		    state = STATE_DONE;
	    end

	    else if (state == STATE_DONE) begin
		    if (go)
			    state = STATE_SQUARE;
	    end

	    if (state == STATE_SQUARE) begin
		    for (i = 0; i < NUM_COMPARES; i = i + 1) begin
			    for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
				    block_base = j * DATA_WIDTH;
				    line_base = ((i * COMPARE_STEP) + j) * DATA_WIDTH;
				    R_temp[15:0] = (block[(block_base + 3):block_base] - line[(line_base + 3):line_base]) ;
				    G_temp[15:0] = (block[(block_base + 11):(block_base + 8)] - line[(line_base + 11):(line_base + 8)]);
				    B_temp[15:0] = (block[(block_base + 19):(block_base + 16)] - line[(line_base + 19):(line_base + 16)]);
				    square_results[i][j*3][15:0] 	<= R_temp[15:0] * R_temp[15:0];
				    square_results[i][(j*3)+1][15:0] 	<= G_temp[15:0] * G_temp[15:0]; 	
				    square_results[i][(j*3)+2][15:0] 	<= B_temp[15:0] * B_temp[15:0];
			    end
		    end
	    end
	    
	    else if (state == STATE_ADD_PIXEL) begin
		    for (i = 0; i < NUM_COMPARES; i = i + 1) begin
			    for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
				    pixel_results[i][j][15:0] <= square_results[i][j*3][15:0] + square_results[i][(j*3)+1][15:0] + square_results[i][(j*3)+2][15:0];
			    end
		    end
	    end
	    
	    else if (state == STATE_ADD_LINE) begin
		for (i = 0; i < NUM_COMPARES; i = i + 1) begin
		    for (j = 0; j< BLOCK_SIZE; j = j + 1) begin
			if (j == 0) begin
			  sum_temp[i][15:0] = pixel_results[i][j][15:0];
			end
			else begin
			  sum_temp[i][15:0] = sum_temp[i][15:0] + pixel_results[i][j][15:0];
			end
		    end
		end

		
		for (j = 0; j < NUM_BLOCKS ; j = j + 1) begin //use j in outer loop because i want to keep i as NUM_COMPARES for consistency
		    if (j == block_count) begin
		      for (i = 0; i < NUM_COMPARES; i = i+ 1) begin				  
			    if (line_count == 0) begin
			      sum_temp[j][i][15:0] <= sum_temp[i][15:0];
			    end
			    else begin
			      sum_temp[j][i][15:0] <= sum[j][i][15:0] + sum_temp[i][15:0];
			    end
		      end
		    end
		end
	     end
	    
	     
      end
	    done = (state == STATE_DONE); //finished
    end
endmodule
