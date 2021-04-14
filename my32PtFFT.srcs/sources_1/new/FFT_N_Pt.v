`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2016 06:05:48 PM
// Design Name: 
// Module Name: FFT_N_Pt
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

function integer clogb2;
    input integer value;
    integer i;
    begin
        clogb2 = 0;
        for (i = 0; 2**i < value; i = i + 1)
            clogb2 = i + 1; 
    end
endfunction

module FFT_N_Pt(

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
    parameter FFTDepth = clogb2(FFTPoints);
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;
    
    
    
    //TODO: Finish this FFT-generating for-loop and feel accomplished.
    //TODO: Figure out how exactly j comes into the picture when performing offsets for a generic FFT_Level
    genvar i;
    generate
    for (k = 1; k <= FFTDepth; k = k + 1) begin: FFT_Structure
        wire [dataWidth*FFTPoints-1 : 0] Re_Wire [1:k], Im_Wire [1:k];
        for (j = 0; j < k; j = j + 1) begin: FFT_Level
            for (i = 0; i < dataWidth*FFTPoints/(2**k) - 1; i = i + dataWidth) begin: FFT_Bflies
                if (k == 1) begin: level1
                    FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                        single_bfly(.Re_a(Re_x[i+dataWidth-1:i]), 
                                    .Im_a(Im_x[i+dataWidth-1:i]),
                                    .Re_b(Re_x[i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]), 
                                    .Im_b(Im_x[i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]),
                                    .Re_w(Re_w[i+dataWidth-1:i]), 
                                    .Im_w(Im_w[i+dataWidth-1:i]),
                                    .clk(clk), .reset(reset),
                                    .Re_Y(Re_Wire[1][i+dataWidth-1:i]), 
                                    .Im_Y(Im_Wire[1][i+dataWidth-1:i]),
                                    .Re_Z(Re_Wire[1][i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]), 
                                    .Im_Z(Im_Wire[1][i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]));
                end else if (k == FFTDepth) begin: lastLevel
                    FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                        single_bfly(.Re_a(Re_Wire[k-1][i+dataWidth-1 + j*dataWidth*FFTPoints/(2**(k-1)):i + j*dataWidth*FFTPoints/(2**(k-1))]), 
                                    .Im_a(Im_Wire[k-1][i+dataWidth-1 + j*dataWidth*FFTPoints/(2**(k-1)):i + j*dataWidth*FFTPoints/(2**(k-1))]),
                                    .Re_b(Re_x[i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]), 
                                    .Im_b(Im_x[i+dataWidth*FFTPoints/(2**k) + dataWidth-1 : i+dataWidth*FFTPoints/(2**k)]),
                                    .Re_w(Re_w[i+dataWidth-1:i]), 
                                    .Im_w(Im_w[i+dataWidth-1:i]),
                                    .clk(clk), .reset(reset),
                                    .Re_Y(Re_Out[j*i+dataWidth-1:i]), 
                                    .Im_Y(Im_Wire[1][i+dataWidth-1:i]),
                                    .Re_Z(Re_Wire[1][i+dataWidth-1+dataWidth*FFTPoints/(2**k):i+dataWidth*FFTPoints/(2**k)]), 
                                    .Im_Z(Im_Wire[1][i+dataWidth-1+dataWidth*FFTPoints/(2**k):i+dataWidth*FFTPoints/(2**k)]));
                end else begin: midLevels
                    assign Re_Wire[k] = Re_Wire[k-1];
                    assign Im_Wire[k] = Im_Wire[k-1];
                end 
            end
        end
    end
    endgenerate
     
endmodule
