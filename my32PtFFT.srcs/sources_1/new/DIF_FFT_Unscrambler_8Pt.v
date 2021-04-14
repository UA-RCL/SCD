`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2016 07:18:25 PM
// Design Name: 
// Module Name: DIF_FFT_Unscrambler_8Pt
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


module DIF_FFT_Unscrambler_8Pt(
    
    input [FFTPoints*dataWidth-1:0] Re_In,
    input [FFTPoints*dataWidth-1:0] Im_In,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out
    
);
    
    parameter FFTPoints = 8;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;

    assign Re_Out[0*dataWidth + dataWidth-1 : 0*dataWidth] = Re_In[0*dataWidth + dataWidth-1 : 0*dataWidth];
    assign Re_Out[4*dataWidth + dataWidth-1 : 4*dataWidth] = Re_In[1*dataWidth + dataWidth-1 : 1*dataWidth];
    assign Re_Out[2*dataWidth + dataWidth-1 : 2*dataWidth] = Re_In[2*dataWidth + dataWidth-1 : 2*dataWidth];
    assign Re_Out[6*dataWidth + dataWidth-1 : 6*dataWidth] = Re_In[3*dataWidth + dataWidth-1 : 3*dataWidth];
    assign Re_Out[1*dataWidth + dataWidth-1 : 1*dataWidth] = Re_In[4*dataWidth + dataWidth-1 : 4*dataWidth];
    assign Re_Out[5*dataWidth + dataWidth-1 : 5*dataWidth] = Re_In[5*dataWidth + dataWidth-1 : 5*dataWidth];
    assign Re_Out[3*dataWidth + dataWidth-1 : 3*dataWidth] = Re_In[6*dataWidth + dataWidth-1 : 6*dataWidth];
    assign Re_Out[7*dataWidth + dataWidth-1 : 7*dataWidth] = Re_In[7*dataWidth + dataWidth-1 : 7*dataWidth];

    assign Im_Out[0*dataWidth + dataWidth-1 : 0*dataWidth] = Im_In[0*dataWidth + dataWidth-1 : 0*dataWidth];
    assign Im_Out[4*dataWidth + dataWidth-1 : 4*dataWidth] = Im_In[1*dataWidth + dataWidth-1 : 1*dataWidth];
    assign Im_Out[2*dataWidth + dataWidth-1 : 2*dataWidth] = Im_In[2*dataWidth + dataWidth-1 : 2*dataWidth];
    assign Im_Out[6*dataWidth + dataWidth-1 : 6*dataWidth] = Im_In[3*dataWidth + dataWidth-1 : 3*dataWidth];
    assign Im_Out[1*dataWidth + dataWidth-1 : 1*dataWidth] = Im_In[4*dataWidth + dataWidth-1 : 4*dataWidth];
    assign Im_Out[5*dataWidth + dataWidth-1 : 5*dataWidth] = Im_In[5*dataWidth + dataWidth-1 : 5*dataWidth];
    assign Im_Out[3*dataWidth + dataWidth-1 : 3*dataWidth] = Im_In[6*dataWidth + dataWidth-1 : 6*dataWidth];
    assign Im_Out[7*dataWidth + dataWidth-1 : 7*dataWidth] = Im_In[7*dataWidth + dataWidth-1 : 7*dataWidth];

endmodule
