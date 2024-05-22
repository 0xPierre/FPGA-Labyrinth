// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================
//
// Revision History :
// --------------------------------------------------------------------------------
//   Ver  :| Author                    :| Mod. Date :| Changes Made:
//   V2.0 :| F. CRISON                 :| 31/01/2019:| Modified for ESIEA Labs
// --------------------------------------------------------------------------------

module vga(

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// address (pixel) / data /////////
		output      bgr_data_raw_clk, //data must be set on positive edge
      output      [18:0] address_bgr_data_raw,
	   output      [8:0] row,  // image "row 		
		output      [9:0] column,  // image  column"
		input       [23:0] bgr_data_raw,

      ///////// FPGA /////////
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,

      ///////// KEY /////////
      input        KEY,

      ///////// VGA /////////
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      //output             VGA_SYNC_N,
      output             VGA_VS
);

parameter	pixel_row_size	=	8;
parameter	pixel_column_size	=	8;							 


//=======================================================
//  REG/WIRE declarations
//=======================================================

//	For VGA Controller
wire		   VGA_CTRL_CLK;
wire  [9:0]	mVGA_R;
wire  [9:0]	mVGA_G;
wire  [9:0]	mVGA_B;
wire [19:0]	mVGA_ADDR;

wire	[9:0]	mRed;
wire	[9:0]	mGreen;
wire	[9:0]	mBlue;

wire  [9:0] recon_VGA_R;
wire  [9:0] recon_VGA_G;
wire  [9:0] recon_VGA_B;

wire		   DLY_RST;

//=======================================================
//  Structural coding
//=======================================================
   						
assign FPGA_I2C_SDAT		= 1'bz;     						
assign FPGA_I2C_SCLK		= 1'bz; 
assign bgr_data_raw_clk =~VGA_CTRL_CLK;

//	Reset Delay Timer
Reset_Delay			r0	(	
							 .iCLK(CLOCK_50),
							 .oRESET(DLY_RST));
//	 Audio VGA PLL clock							 

VGA_Audio u1(
		                .refclk(CLOCK_50),   //  refclk.clk
		                .rst(~DLY_RST),      //   reset.reset
		                .outclk_0(VGA_CTRL_CLK), // outclk0.clk
		                .outclk_1(), // outclk1.clk
		                .outclk_2(), // outclk2.clk
		                .locked()    //  locked.export
	);



	
assign VGA_CLK = VGA_CTRL_CLK;
vga_controller #( .pixel_row_size(pixel_row_size),.pixel_column_size(pixel_column_size))
              vga_ins(.iRST_n(DLY_RST),
                      .iVGA_CLK(VGA_CTRL_CLK),
                      .oBLANK_n(VGA_BLANK_N),
                      .oHS(VGA_HS),
                      .oVS(VGA_VS),
                      .b_data(VGA_B),
                      .g_data(VGA_G),
                      .r_data(VGA_R),
							 .address(address_bgr_data_raw),
							 .row(row),
							 .column(column),
							 .bgr_data_raw(bgr_data_raw));	
							 						  
							  
I2C_AV_Config 		u3	(	//	Host Side
							.iCLK(CLOCK_50),
							.iRST_N(KEY),
							//	I2C Side
							.I2C_SCLK(FPGA_I2C_SCLK),
							.I2C_SDAT(FPGA_I2C_SDAT)	);


endmodule


