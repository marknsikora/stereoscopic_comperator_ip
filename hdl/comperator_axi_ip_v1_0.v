
`timescale 1 ps / 1 ps

	module comperator_axi_ip_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4,

		// Parameters of Axi Slave Bus Interface S_FRAME0_AXIS
		parameter integer C_S_FRAME0_AXIS_TDATA_WIDTH	= 24,

		// Parameters of Axi Slave Bus Interface S_FRAME1_AXIS
		parameter integer C_S_FRAME1_AXIS_TDATA_WIDTH	= 24,

		// Parameters of Axi Master Bus Interface M_VIDEO_AXIS
		parameter integer C_M_VIDEO_AXIS_TDATA_WIDTH	= 24,
		parameter integer C_M_VIDEO_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line
		input wire aclk,
		input wire aresetn,


		// Ports of Axi Slave Bus Interface S_AXI
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready,

		// Ports of Axi Slave Bus Interface S_FRAME0_AXIS
		output wire  s_frame0_axis_tready,
		input wire [C_S_FRAME0_AXIS_TDATA_WIDTH-1 : 0] s_frame0_axis_tdata,
		input wire  s_frame0_axis_tlast,
		input wire  s_frame0_axis_tvalid,
		input wire  s_frame0_axis_tuser,

		// Ports of Axi Slave Bus Interface S_FRAME1_AXIS
		output wire  s_frame1_axis_tready,
		input wire [C_S_FRAME1_AXIS_TDATA_WIDTH-1 : 0] s_frame1_axis_tdata,
		input wire  s_frame1_axis_tlast,
		input wire  s_frame1_axis_tvalid,
		input wire  s_frame1_axis_tuser,

		// Ports of Axi Master Bus Interface M_VIDEO_AXIS
		output wire  m_video_axis_tvalid,
		output wire [C_M_VIDEO_AXIS_TDATA_WIDTH-1 : 0] m_video_axis_tdata,
		output wire  m_video_axis_tlast,
		input wire  m_video_axis_tready,
		output wire  m_video_axis_tuser
	);
	localparam BLOCK_SIZE = 8;
    localparam FRAME_WIDTH = 320;
    
    wire soft_reset;
    wire go;
    wire go_0, go_1;
    wire frame_0_done, frame_1_done;
    wire running;
    
    wire frame0_ready;
    wire frame1_ready;
    
    wire resetn;
	
// Instantiation of Axi Bus Interface S_AXI
	comperator_axi_ip_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) comperator_axi_ip_v1_0_S_AXI_inst (
		.S_AXI_ACLK(aclk),
		.S_AXI_ARESETN(aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready),
		.GO(go),
		.SOFT_RESET(soft_reset)
	);

// Instantiation of Axi Bus Interface S_FRAME0_AXIS
//	comperator_axi_ip_v1_0_S_FRAME0_AXIS # ( 
//		.C_S_AXIS_TDATA_WIDTH(C_S_FRAME0_AXIS_TDATA_WIDTH)
//	) comperator_axi_ip_v1_0_S_FRAME0_AXIS_inst (
//		.S_AXIS_ACLK(aclk),
//		.S_AXIS_ARESETN(resetn),
//		.S_AXIS_TREADY(s_frame0_axis_tready),
//		.S_AXIS_TDATA(s_frame0_axis_tdata),
//		.S_AXIS_TLAST(s_frame0_axis_tlast),
//		.S_AXIS_TVALID(s_frame0_axis_tvalid),
//		.S_AXIS_TUSER(s_frame0_axis_tuser)
//	);

// Instantiation of Axi Bus Interface S_FRAME1_AXIS
//	comperator_axi_ip_v1_0_S_FRAME1_AXIS # ( 
//		.C_S_AXIS_TDATA_WIDTH(C_S_FRAME1_AXIS_TDATA_WIDTH)
//	) comperator_axi_ip_v1_0_S_FRAME1_AXIS_inst (
//		.S_AXIS_ACLK(aclk),
//		.S_AXIS_ARESETN(resetn),
//		.S_AXIS_TREADY(s_frame1_axis_tready),
//		.S_AXIS_TDATA(s_frame1_axis_tdata),
//		.S_AXIS_TLAST(s_frame1_axis_tlast),
//		.S_AXIS_TVALID(s_frame1_axis_tvalid),
//		.S_AXIS_TUSER(s_frame1_axis_tuser)
//	);

// Instantiation of Axi Bus Interface M_VIDEO_AXIS
//	comperator_axi_ip_v1_0_M_VIDEO_AXIS # ( 
//		.C_M_AXIS_TDATA_WIDTH(C_M_VIDEO_AXIS_TDATA_WIDTH),
//		.C_M_START_COUNT(C_M_VIDEO_AXIS_START_COUNT)
//	) comperator_axi_ip_v1_0_M_VIDEO_AXIS_inst (
//		.M_AXIS_ACLK(aclk),
//		.M_AXIS_ARESETN(resetn),
//		.M_AXIS_TVALID(m_video_axis_tvalid),
//		.M_AXIS_TDATA(m_video_axis_tdata),
//		.M_AXIS_TLAST(m_video_axis_tlast),
//		.M_AXIS_TREADY(m_video_axis_tready),
//		.M_AXIS_TUSER(m_video_axis_tuser)
//	);

	// Add user logic here
	assign resetn = aresetn & soft_reset;
	
	assign m_video_axis_tvalid = s_frame0_axis_tvalid;
	assign m_video_axis_tdata = s_frame0_axis_tdata;
	assign m_video_axis_tlast = s_frame0_axis_tlast;
	assign m_video_axis_tuser = s_frame0_axis_tuser;
	
	assign s_frame0_axis_tready = frame0_ready | ~running;
	assign s_frame1_axis_tready = frame1_ready | ~running;

    comperator_axi_ip_v1_0_simple_controller controller_0(
        .aclk(aclk),
        .aresetn(resetn),
        .go(go),
        .go0(go_0),
        .go1(go_1),
        .done0(frame_0_done),
        .done1(frame_1_done),
        .running(running)
    );
    
    comperator_axi_ip_v1_0_block_reader #(
        .BLOCK_SIZE(BLOCK_SIZE)
    )block_reader_0(
        .aclk(aclk),
        .aresetn(resetn),
        .s_axis_tdata(s_frame1_axis_tdata),
        .s_axis_tlast(s_frame1_axis_tlast),
        .s_axis_tready(frame1_ready),
        .s_axis_tuser(s_frame1_axis_tuser),
        .s_axis_tvalid(s_frame1_axis_tvalid),
        .go(go_1),
        .done(frame_1_done)
    );
    
    comperator_axi_ip_v1_0_line_reader #(
        .FRAME_WIDTH(FRAME_WIDTH)
    )line_reader_0(
        .aclk(aclk),
        .aresetn(resetn),
        .s_axis_tdata(s_frame0_axis_tdata),
        .s_axis_tlast(s_frame0_axis_tlast),
        .s_axis_tready(frame0_ready),
        .s_axis_tuser(s_frame0_axis_tuser),
        .s_axis_tvalid(s_frame0_axis_tvalid),
        .go(go_0),
        .done(frame_0_done)
    );
	// User logic ends

	endmodule
