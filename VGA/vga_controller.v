// --------------------------------------------------------------------------------
//   Ver  :| Author                    :| Mod. Date :| Changes Made:
//   V2.0 :| F. CRISON                 :| 31/01/2019:| Modified for ESIEA Labs
// --------------------------------------------------------------------------------

module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 address,  //pixel number
							 row,column,  // image "row and column"
							 bgr_data_raw
							 );

parameter	pixel_row_size	=	8;
parameter	pixel_column_size	=	8;							 
reg [8:0] rowCntDiv;  //480 max
reg [9:0] columnCntDiv;  //640 max
reg [8:0] reg_row;  //480 max
reg [9:0]  reg_column;  //640 max
reg [9:0]  horizontalCntDiv;  //640 max
			
input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;

output [18:0] address;
output [8:0] row;
output [9:0] column;
input [23:0] bgr_data_raw;                       

							  
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire cBLANK_n,cHS,cVS,rst;
wire [18:0] address=ADDR;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     begin
     ADDR<=19'd0;
	  columnCntDiv<=10'd0;
	  rowCntDiv<=9'd0;
	  reg_column<=10'd0;
	  reg_row<=9'd0;
	  horizontalCntDiv<=9'd0;
	  end
  else if (cHS==1'b0 && cVS==1'b0)
     begin
     ADDR<=19'd0;
	  columnCntDiv<=10'd0;
	  rowCntDiv<=9'd0;
	  reg_column<=10'd0;
	  reg_row<=9'd0;
	  horizontalCntDiv<=9'd0;	  
	  end
  else if (cBLANK_n==1'b1)
     begin
       ADDR<=ADDR+1;
//	  
       horizontalCntDiv<=horizontalCntDiv+1;
       if (horizontalCntDiv==640-1)
		 begin
		   horizontalCntDiv<=9'd0;
	      columnCntDiv<=10'd0;
	      reg_column<=10'd0;		 
	      rowCntDiv<=rowCntDiv+1;
	      if (rowCntDiv == pixel_row_size-1)
	      begin
	         rowCntDiv<=10'd0;
		      reg_row<=reg_row+1;	  
	      end		   
		 end
		 else
		 begin
	      columnCntDiv<=columnCntDiv+1;
  	      if (columnCntDiv == pixel_column_size-1)
	      begin
	         columnCntDiv<=10'd0;
		      reg_column<=reg_column+1;
	      end
		 end
	  end
end

assign row = reg_row;
assign column = reg_column;
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;

//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0];
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	
















