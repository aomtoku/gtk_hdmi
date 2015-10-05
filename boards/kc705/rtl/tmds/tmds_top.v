`default_nettype none

module tmds_top (
	input  wire       pix_clk,
	input  wire       sys_rst,
	output wire  [9:0] tmds_0,
	output wire  [9:0] tmds_1,
	output wire  [9:0] tmds_2,
	output wire  [9:0] tmds_3
);


//1920x1080@60Hz
parameter HPIXELS_HDTV1080P = 12'd1920;  //Horizontal Live Pixels
parameter VLINES_HDTV1080P  = 12'd1080;  //Vertical Live ines
parameter HFNPRCH_HDTV1080P = 12'd88;    //Horizontal Front Portch
parameter HSYNCPW_HDTV1080P = 12'd44;    //HSYNC Pulse Width
parameter HBKPRCH_HDTV1080P = 12'd148;   //Horizontal Back Portch
parameter VFNPRCH_HDTV1080P = 12'd4;     //Vertical Front Portch
parameter VSYNCPW_HDTV1080P = 12'd5;     //VSYNC Pulse Width
parameter VBKPRCH_HDTV1080P = 12'd36;    //Vertical Back Portch


wire [11:0] tc_hsblnk = HPIXELS_HDTV1080P - 12'd1;
wire [11:0] tc_hssync = HPIXELS_HDTV1080P - 12'd1 + HFNPRCH_HDTV1080P;
wire [11:0] tc_hesync = HPIXELS_HDTV1080P - 12'd1 + HFNPRCH_HDTV1080P + HSYNCPW_HDTV1080P;
wire [11:0] tc_heblnk = HPIXELS_HDTV1080P - 12'd1 + HFNPRCH_HDTV1080P + HSYNCPW_HDTV1080P + HBKPRCH_HDTV1080P;
wire [11:0] tc_vsblnk = VLINES_HDTV1080P  - 12'd1;
wire [11:0] tc_vssync = VLINES_HDTV1080P  - 12'd1 + VFNPRCH_HDTV1080P;
wire [11:0] tc_vesync = VLINES_HDTV1080P  - 12'd1 + VFNPRCH_HDTV1080P + VSYNCPW_HDTV1080P;
wire [11:0] tc_veblnk = VLINES_HDTV1080P  - 12'd1 + VFNPRCH_HDTV1080P + VSYNCPW_HDTV1080P + VBKPRCH_HDTV1080P;
wire hvsync_polarity  = 1'b0;

wire hdmi_hsync_int, hdmi_vsync_int;
wire   [11:0] bgnd_hcount;
wire          bgnd_hsync;
wire          bgnd_hblnk;
wire   [11:0] bgnd_vcount;
wire          bgnd_vsync;
wire          bgnd_vblnk;

timing timing_inst (
    .tc_hsblnk(tc_hsblnk), //input
    .tc_hssync(tc_hssync), //input
    .tc_hesync(tc_hesync), //input
    .tc_heblnk(tc_heblnk), //input
    .hcount(bgnd_hcount), //output
    .hsync(hdmi_hsync_int), //output
    .hblnk(bgnd_hblnk), //output
    .tc_vsblnk(tc_vsblnk), //input
    .tc_vssync(tc_vssync), //input
    .tc_vesync(tc_vesync), //input
    .tc_veblnk(tc_veblnk), //input
    .vcount(bgnd_vcount), //output
    .vsync(hdmi_vsync_int), //output
    .vblnk(bgnd_vblnk), //output
    .restart(sys_rst),
    .clk(pix_clk)
);

/* ------ V/H SYNC and DE generator ------ */
wire active;
assign active = !bgnd_hblnk && !bgnd_vblnk;

reg active_q;
reg vsync, hsync;
reg hdmi_hsync, hdmi_vsync;
reg vde;
wire [7:0] red_data, green_data, blue_data;

always @ (posedge pix_clk) begin
	hsync <= hdmi_hsync_int ^ hvsync_polarity ;
	vsync <= hdmi_vsync_int ^ hvsync_polarity ;
	hdmi_hsync <= hsync;
	hdmi_vsync <= vsync;
	
	active_q <= active;
	vde <= active_q;
end

/* ------------- TMDS Encoder ---------------- */
hdmi_encoder_top enc0 (
	.pclk            (pix_clk),
	.rstin           (sys_rst),
	.blue_din        (blue_data),
	.green_din       (green_data),
	.red_din         (red_data),
	.aux0_din        (4'd0),
	.aux1_din        (4'd0),
	.aux2_din        (4'd0),
	.hsync           (hdmi_hsync),
	.vsync           (hdmi_vsync),
	.vde             (vde),
	.ade             (1'b0),
	.sdata_r         (tmds_2), // 10bit Red Channel
	.sdata_g         (tmds_1), // 10bit Green Channel
	.sdata_b         (tmds_0)  // 10bit Blue Channel

);

assign tmds_3 = 10'b1111100000;

hdcolorbar clrbar(
	.i_clk_74M (pix_clk),
	.i_rst     (sys_rst),
	.i_hcnt    (bgnd_hcount),
	.i_vcnt    (bgnd_vcount),
	.baronly   (1'b0),
	.i_format  (2'b00),
	.o_r       (red_data),
	.o_g       (green_data),
	.o_b       (blue_data)
);

endmodule
`default_nettype wire