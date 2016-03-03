`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2016 06:38:59 PM
// Design Name: 
// Module Name: FFT_8_Pt_TOP
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


module FFT_8_Pt_TOP(
    input [FFTPoints*(dataWidth)-1:0] Re_x,
    input [FFTPoints*(dataWidth)-1:0] Im_x,
    
    input [FFTPoints*(dataWidth)/2-1:0] Re_w,
    input [FFTPoints*(dataWidth)/2-1:0] Im_w,
    
    input clk,
    input reset,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out
);

    parameter FFTPoints = 8;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;

    wire [FFTPoints*dataWidth-1:0] Re_Out_Temp, Im_Out_Temp;
    
    FFT_8_Pt #(.FFTPoints(FFTPoints), .expWidth(expWidth), .sigWidth(sigWidth)) myFFT(
        .Re_x(Re_x), .Im_x(Im_x), .Re_w(Re_w), .Im_w(Im_w), .clk(clk), .reset(reset),
        .Re_Out(Re_Out_Temp), .Im_Out(Im_Out_Temp)
    );
    
    
    DIF_FFT_Unscrambler_8Pt #(.dataWidth(dataWidth)) myUnscrambler(
        .Re_In(Re_Out_Temp), .Im_In(Im_Out_Temp),
        .Re_Out(Re_Out), .Im_Out(Im_Out)
    );
    
    
    /*
    assign Re_Out = Re_Out_Temp;
    assign Im_Out = Im_Out_Temp;
    */
    
endmodule
