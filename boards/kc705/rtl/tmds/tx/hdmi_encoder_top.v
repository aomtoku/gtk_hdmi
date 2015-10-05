`default_nettype none
//////////////////////////////////////////////////////////////////////////////
//
//  Xilinx, Inc. 2009                 www.xilinx.com
//
//  XAPP xyz
//
//////////////////////////////////////////////////////////////////////////////
//
//  File name :       dvi_encoder.v
//
//  Description :     dvi_encoder 
//
//  Date - revision : April 2009 - 1.0.0
//
//  Author :          Bob Feng
//
//  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are
//              provided to you "as is". Xilinx and its licensors makeand you
//              receive no warranties or conditions, express, implied,
//              statutory or otherwise, and Xilinx specificallydisclaims any
//              implied warranties of merchantability, non-infringement,or
//              fitness for a particular purpose. Xilinx does notwarrant that
//              the functions contained in these designs will meet your
//              requirements, or that the operation of these designswill be
//              uninterrupted or error free, or that defects in theDesigns
//              will be corrected. Furthermore, Xilinx does not warrantor
//              make any representations regarding use or the results ofthe
//              use of the designs in terms of correctness, accuracy,
//              reliability, or otherwise.
//
//              LIMITATION OF LIABILITY. In no event will Xilinx or its
//              licensors be liable for any loss of data, lost profits,cost
//              or procurement of substitute goods or services, or forany
//              special, incidental, consequential, or indirect damages
//              arising from the use or operation of the designs or
//              accompanying documentation, however caused and on anytheory
//              of liability. This limitation will apply even if Xilinx
//              has been advised of the possibility of such damage. This
//              limitation shall apply not-withstanding the failure ofthe
//              essential purpose of any limited remedies herein.
//
//  Copyright � 2009 Xilinx, Inc.
//  All rights reserved
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1ps

module hdmi_encoder_top (
  input  wire       pclk,           // pixel clock
  input  wire       rstin,          // reset
  input  wire [7:0] blue_din,       // Blue data in
  input  wire [7:0] green_din,      // Green data in
  input  wire [7:0] red_din,        // Red data in
  input  wire [3:0] aux0_din,        // Red data in
  input  wire [3:0] aux1_din,        // Red data in
  input  wire [3:0] aux2_din,        // Red data in
  input  wire       hsync,          // hsync data
  input  wire       vsync,          // vsync data
  input  wire       ade,          // vsync data
  input  wire       vde,             // data enable
  output wire [9:0] sdata_r,
  output wire [9:0] sdata_g,
  output wire [9:0] sdata_b
  );
    
  wire 	[9:0]	red ;
  wire 	[9:0]	green ;
  wire 	[9:0]	blue ;

  wire [4:0] tmds_data0, tmds_data1, tmds_data2;
  wire [2:0] tmdsint;

	reg  ctl0, ctl1, ctl2, ctl3;

	parameter DILNDPREAM = 4'b1010;
	parameter VIDEOPREAM = 4'b1000;
	parameter NULLCONTRL = 4'b0000;

	always @ (posedge pclk) begin
  	if(vde)
    	{ctl0, ctl1, ctl2, ctl3} <=#1 VIDEOPREAM;
  	else if(ade)
    	{ctl0, ctl1, ctl2, ctl3} <=#1 DILNDPREAM;
  	else
    	{ctl0, ctl1, ctl2, ctl3} <=#1 NULLCONTRL;
	end

	
	wire [7:0] blue_dly, green_dly, red_dly;
	wire [3:0] aux0_dly, aux1_dly, aux2_dly;
	wire       hsync_dly, vsync_dly, vde_dly, ade_dly;

	srldelay # (
 		.WIDTH(40),
  	.TAPS(4'b1010)
	) srldly_0 (
  	.data_i({blue_din, green_din, red_din, aux0_din, aux1_din, aux2_din, hsync, vsync, vde, ade}),
  	.data_o({blue_dly, green_dly, red_dly, aux0_dly, aux1_dly, aux2_dly, hsync_dly, vsync_dly, vde_dly, ade_dly}),
  	.clk(pclk)
	);

  encode # (
	  .CHANNEL("BLUE")
	) encb (
    .clkin	(pclk),
    .rstin	(rstin),
    .vdin		(blue_dly),
    .adin		(aux0_dly),
    .c0			(hsync_dly),
    .c1			(vsync_dly),
    .ade		(ade_dly),
    .vde		(vde_dly),
    .dout		(blue)) ;

  encode # (
	  .CHANNEL("GREEN")
	) encg (
    .clkin	(pclk),
    .rstin	(rstin),
    .vdin		(green_dly),
    .adin		(aux1_dly),
    .c0			(ctl0),
    .c1			(ctl1),
    .ade		(ade_dly),
    .vde		(vde_dly),
    .dout		(green)) ;
    
  encode # (
	  .CHANNEL("RED")
	) encr (
    .clkin	(pclk),
    .rstin	(rstin),
    .vdin		(red_dly),
    .adin		(aux2_dly),
    .c0			(ctl2),
    .c1			(ctl3),
    .ade		(ade_dly),
    .vde		(vde_dly),
    .dout		(red)) ;

  wire [29:0] s_data = {red[9:5], green[9:5], blue[9:5],
                        red[4:0], green[4:0], blue[4:0]};

  assign sdata_r = red[9:0];
  assign sdata_g = green[9:0];
  assign sdata_b = blue[9:0];



endmodule
`default_nettype wire