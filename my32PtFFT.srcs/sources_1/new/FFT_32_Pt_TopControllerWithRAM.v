`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2016 09:19:48 PM
// Design Name: 
// Module Name: FFT_32_Pt_TopControllerWithRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFT_32_Pt_TopControllerWithRAM(
    input clk,
    input reset
);

reg [7:0] addr;
reg [1023:0] Re_Reg, Im_Reg;

wire [1023:0] Re_Mem, Im_Mem, Re_Out, Im_Out;

DualPortRAM #(.wordWidth(1024), .addrSize(8), .filename("testFile.txt")) myRam(
    .clk1(clk), .clk2(clk), .addr1(addr), .addr2(8'd0), .writeEn1(1'b0), .writeEn2(1'b0),
    .dataIn1(32'd0), .dataIn2(32'd0), .dataOut1(Re_Mem), .dataOut2(Im_Mem)
);

FFT_32_Pt_Datapath myFFT(
    .clk(clk), .reset(reset), .Re_x(Re_Mem), .Im_x(Im_Mem),
    .Re_Out(Re_Out), .Im_Out(Im_Out)
);

always @(posedge clk) begin
    Re_Reg <= Re_Out;
    Im_Reg <= Im_Out;
end
    
endmodule
