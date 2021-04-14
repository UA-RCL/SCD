`timescale 1ns / 1ps

module FFT_32_Pt_Datapath 
#(
    parameter FFTPoints = 32,
    parameter expWidth = 8,
    parameter sigWidth = 23,
    parameter dataWidth = expWidth+sigWidth+1
)
(
    input [FFTPoints*(dataWidth)-1:0] Re_x,
    input [FFTPoints*(dataWidth)-1:0] Im_x,
    
    input clk,
    input reset,
    input dataValid,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out,
    
    output done   
);
    wire [FFTPoints*dataWidth-1:0] Re_Out_Temp, Im_Out_Temp;
    wire [FFTPoints*dataWidth/2-1:0] Re_w, Im_w;
    
    //Re_w = Re{[W_N^(N/2-1), W_N^(N/2-2), ..., W_N^3, W_N^2, W_N^1, W_N^0]}
    //Im_w = Im{[W_N^(N/2-1), W_N^(N/2-2), ..., W_N^3, W_N^2, W_N^1, W_N^0]}
    assign Re_w = 512'hbf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c2248d31323e47c5c23ec3ef153f0e39da3f3504f33f54db313f6c835e3f7b14be3f800000;
    assign Im_w = 512'hbe47c5c2bec3ef15bf0e39dabf3504f3bf54db31bf6c835ebf7b14bebf800000bf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c200000000;
    
    FFT_32_Pt #(.FFTPoints(FFTPoints), .expWidth(expWidth), .sigWidth(sigWidth)) myFFT(
        .Re_x(Re_x), .Im_x(Im_x), .Re_w(Re_w), .Im_w(Im_w), .clk(clk), .reset(reset), .dataValid(dataValid),
        .Re_Out(Re_Out_Temp), .Im_Out(Im_Out_Temp), .done(done)
    );
    
    DIF_FFT_Unscrambler_32Pt #(.FFTPoints(FFTPoints), .expWidth(expWidth), .sigWidth(sigWidth)) myUnscrambler(
        .Re_In(Re_Out_Temp), .Im_In(Im_Out_Temp), .Re_Out(Re_Out), .Im_Out(Im_Out)
    );
    
endmodule
