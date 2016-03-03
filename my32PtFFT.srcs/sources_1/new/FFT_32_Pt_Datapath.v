`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2016 07:22:48 PM
// Design Name: 
// Module Name: FFT_32_Pt_TOP
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


module FFT_32_Pt_Datapath(
    input [FFTPoints*(dataWidth)-1:0] Re_x,
    input [FFTPoints*(dataWidth)-1:0] Im_x,
    
    input clk,
    input reset,
    //input dataValid,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out,
    
    output reg done    
);

    parameter FFTPoints = 32;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;

    wire [FFTPoints*dataWidth-1:0] Re_Out_Temp, Im_Out_Temp;
    wire [FFTPoints*dataWidth/2-1:0] Re_w, Im_w;
    
    reg [7:0] cycleCounter;
    
    assign Re_w = 512'hbf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c2248d31323e47c5c23ec3ef153f0e39da3f3504f33f54db313f6c835e3f7b14be3f800000;
    assign Im_w = 512'hbe47c5c2bec3ef15bf0e39dabf3504f3bf54db31bf6c835ebf7b14bebf800000bf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c200000000;
    
    FFT_32_Pt #(.FFTPoints(FFTPoints), .expWidth(expWidth), .sigWidth(sigWidth)) myFFT(
        .Re_x(Re_x), .Im_x(Im_x), .Re_w(Re_w), .Im_w(Im_w), .clk(clk), .reset(reset),
        .Re_Out(Re_Out_Temp), .Im_Out(Im_Out_Temp)
    );
    
    DIF_FFT_Unscrambler_32Pt #(.FFTPoints(FFTPoints), .expWidth(expWidth), .sigWidth(sigWidth)) myUnscrambler(
        .Re_In(Re_Out_Temp), .Im_In(Im_Out_Temp), .Re_Out(Re_Out), .Im_Out(Im_Out)
    );
    
    
    //Simple counter to indicate when the data is available on the output.
    //Data is stable after NumBflyCycles * NumStages clock cycles.
    //In this case, 26 cycles * 5 stages = 130 cycles
    initial begin
        cycleCounter <= 7'd0;
        done <= 1'b0;
    end
    
    always @(posedge clk) begin
        if (reset == 1) begin //| dataValid == 0) begin
            cycleCounter <= 7'd0;
            done <= 1'b0;
        end
        else begin
            if (cycleCounter < 129) begin
                cycleCounter <= cycleCounter + 1;
            end
            else begin
                done <= 1'b1;
            end
        end
    end
    
endmodule
