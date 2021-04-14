`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2016 10:48:39 AM
// Design Name: 
// Module Name: FFT_8_Pt
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

module FFT_8_Pt(

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
    

    //-------------Tree Level 1: 1x4 butterflies----------//
    wire [dataWidth*FFTPoints/2-1:0] Re_Y_Stg1, Re_Z_Stg1, Im_Y_Stg1, Im_Z_Stg1;
       
    genvar i;
    generate
       for (i = 0; i < dataWidth*FFTPoints/2 - 1; i = i + dataWidth) begin: bflies
           FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
               //Top butterflies, the ones whose 
               level1_bfly(.Re_a(Re_x[i+dataWidth-1:i]), .Im_a(Im_x[i+dataWidth-1:i]),
                           .Re_b(Re_x[i + dataWidth-1 + dataWidth*FFTPoints/2 : i + dataWidth*FFTPoints/2]), 
                           .Im_b(Im_x[i + dataWidth-1 + dataWidth*FFTPoints/2 : i + dataWidth*FFTPoints/2]),
                           .Re_w(Re_w[i+dataWidth-1:i]), .Im_w(Im_w[i+dataWidth-1:i]),
                           .clk(clk), .reset(reset),
                           .Re_Y(Re_Y_Stg1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg1[i+dataWidth-1:i]),
                           .Re_Z(Re_Z_Stg1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg1[i+dataWidth-1:i]));
       end
    endgenerate
    
    //---------------Pipeline Registers----------------//
    wire [FFTPoints*dataWidth/2-1:0] Re_Y_Stg1_RegOut, Im_Y_Stg1_RegOut, Re_Z_Stg1_RegOut, Im_Z_Stg1_RegOut;
    
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Re_Y_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg1), .writeEn(1'b1), .dataOut(Re_Y_Stg1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Im_Y_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg1), .writeEn(1'b1), .dataOut(Im_Y_Stg1_RegOut));
        
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Re_Z_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg1), .writeEn(1'b1), .dataOut(Re_Z_Stg1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Im_Z_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg1), .writeEn(1'b1), .dataOut(Im_Z_Stg1_RegOut));
    
    
    //---------------Tree Level 2: 2x2 butterflies---------//
    wire [FFTPoints*dataWidth/4-1:0] Re_Y_Stg2_1, Re_Z_Stg2_1, Im_Y_Stg2_1, Im_Z_Stg2_1,
                                     Re_Y_Stg2_2, Re_Z_Stg2_2, Im_Y_Stg2_2, Im_Z_Stg2_2;
                                     
    generate
        //Now half the size of the for loop and do it twice, once for the Y's and once for the Z's
        for (i = 0; i < dataWidth*FFTPoints/4 - 1; i = i + dataWidth) begin: bflies2_1
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level2_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Y_Stg1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Y_Stg1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/4 : i + dataWidth*FFTPoints/4]), 
                            .Im_b(Im_Y_Stg1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/4 : i + dataWidth*FFTPoints/4]),
                            .Re_w(Re_w[2*i+dataWidth-1:2*i]), .Im_w(Im_w[2*i+dataWidth-1:2*i]),
                            .Re_Y(Re_Y_Stg2_1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg2_1[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg2_1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg2_1[i+dataWidth-1:i]));
        end
        //Now do the same thing again for the previous stage's Z arrays
        for (i = 0; i < dataWidth*FFTPoints/4 - 1; i = i + dataWidth) begin: bflies2_2
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level2_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Z_Stg1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Z_Stg1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/4 : i + dataWidth*FFTPoints/4]), 
                            .Im_b(Im_Z_Stg1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/4 : i + dataWidth*FFTPoints/4]),
                            .Re_w(Re_w[2*i+dataWidth-1:2*i]), .Im_w(Im_w[2*i+dataWidth-1:2*i]),
                            .Re_Y(Re_Y_Stg2_2[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg2_2[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg2_2[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg2_2[i+dataWidth-1:i]));
        end
    endgenerate
    
    //-----------------Pipeline Registers Stage 2----------------//
    wire [FFTPoints*dataWidth/4-1:0] Re_Y_Stg2_1_RegOut, Im_Y_Stg2_1_RegOut, Re_Z_Stg2_1_RegOut, Im_Z_Stg2_1_RegOut,
                                     Re_Y_Stg2_2_RegOut, Im_Y_Stg2_2_RegOut, Re_Z_Stg2_2_RegOut, Im_Z_Stg2_2_RegOut;
        
    //Y_Stg2_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Re_Y_Stg2_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg2_1), .writeEn(1'b1), .dataOut(Re_Y_Stg2_1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Im_Y_Stg2_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg2_1), .writeEn(1'b1), .dataOut(Im_Y_Stg2_1_RegOut));
    //Z_Stg2_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Re_Z_Stg2_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg2_1), .writeEn(1'b1), .dataOut(Re_Z_Stg2_1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Im_Z_Stg2_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg2_1), .writeEn(1'b1), .dataOut(Im_Z_Stg2_1_RegOut));
    //Y_Stg2_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Re_Y_Stg2_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg2_2), .writeEn(1'b1), .dataOut(Re_Y_Stg2_2_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Im_Y_Stg2_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg2_2), .writeEn(1'b1), .dataOut(Im_Y_Stg2_2_RegOut));
    //Z_Stg2_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Re_Z_Stg2_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg2_2), .writeEn(1'b1), .dataOut(Re_Z_Stg2_2_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/4)) Im_Z_Stg2_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg2_2), .writeEn(1'b1), .dataOut(Im_Z_Stg2_2_RegOut));
        
        
    //-------------Tree Level 3: 8x1 Butterflies------------//
    
    wire [FFTPoints*dataWidth/8-1:0] Re_Y_Stg3_1, Re_Z_Stg3_1, Im_Y_Stg3_1, Im_Z_Stg3_1,
                                     Re_Y_Stg3_2, Re_Z_Stg3_2, Im_Y_Stg3_2, Im_Z_Stg3_2,
                                     Re_Y_Stg3_3, Re_Z_Stg3_3, Im_Y_Stg3_3, Im_Z_Stg3_3,
                                     Re_Y_Stg3_4, Re_Z_Stg3_4, Im_Y_Stg3_4, Im_Z_Stg3_4;
    
    generate
        //Now half the size of the for loop again and do it four times, twice for the Y's and twice for the Z's
        //First pass for Y_Stg2_1
        for (i = 0; i < dataWidth*FFTPoints/8 - 1; i = i + dataWidth) begin: bflies3_1
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level3_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Y_Stg2_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg2_1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Y_Stg2_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]), 
                            .Im_b(Im_Y_Stg2_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]),
                            .Re_w(Re_w[4*i+dataWidth-1:4*i]), .Im_w(Im_w[4*i+dataWidth-1:4*i]),
                            .Re_Y(Re_Y_Stg3_1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg3_1[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg3_1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg3_1[i+dataWidth-1:i]));
        end
        //Now pass for Y_Stg2_2
        for (i = 0; i < dataWidth*FFTPoints/8 - 1; i = i + dataWidth) begin: bflies3_2
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level3_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Z_Stg2_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg2_1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Z_Stg2_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]), 
                            .Im_b(Im_Z_Stg2_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]),
                            .Re_w(Re_w[4*i+dataWidth-1:4*i]), .Im_w(Im_w[4*i+dataWidth-1:4*i]),
                            .Re_Y(Re_Y_Stg3_2[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg3_2[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg3_2[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg3_2[i+dataWidth-1:i]));
        end
        //Now do the same thing again for the previous stage's Z arrays
        //First for Z_Stg2_1
        for (i = 0; i < dataWidth*FFTPoints/8 - 1; i = i + dataWidth) begin: bflies3_3
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level3_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Y_Stg2_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg2_2_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Y_Stg2_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]), 
                            .Im_b(Im_Y_Stg2_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]),
                            .Re_w(Re_w[4*i+dataWidth-1:4*i]), .Im_w(Im_w[4*i+dataWidth-1:4*i]),
                            .Re_Y(Re_Y_Stg3_3[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg3_3[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg3_3[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg3_3[i+dataWidth-1:i]));
        end
        //Now for Z_Stg2_2
        for (i = 0; i < dataWidth*FFTPoints/8 - 1; i = i + dataWidth) begin: bflies3_4
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level3_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Z_Stg2_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg2_2_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Z_Stg2_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]), 
                            .Im_b(Im_Z_Stg2_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/8 : i + dataWidth*FFTPoints/8]),
                            .Re_w(Re_w[4*i+dataWidth-1:4*i]), .Im_w(Im_w[4*i+dataWidth-1:4*i]),
                            .Re_Y(Re_Y_Stg3_4[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg3_4[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg3_4[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg3_4[i+dataWidth-1:i]));
        end
    endgenerate
    
    //----------------------Pipeline Registers Stage 3---------------//
    //Y_Stg3_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_1), .writeEn(1'b1), .dataOut(Re_Out[dataWidth-1:0]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_1), .writeEn(1'b1), .dataOut(Im_Out[dataWidth-1:0]));
    //Z_Stg3_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_1), .writeEn(1'b1), .dataOut(Re_Out[2*dataWidth-1:dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_1), .writeEn(1'b1), .dataOut(Im_Out[2*dataWidth-1:dataWidth]));
    //Y_Stg3_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_2), .writeEn(1'b1), .dataOut(Re_Out[3*dataWidth-1:2*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_2), .writeEn(1'b1), .dataOut(Im_Out[3*dataWidth-1:2*dataWidth]));
    //Z_Stg3_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_2), .writeEn(1'b1), .dataOut(Re_Out[4*dataWidth-1:3*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_2), .writeEn(1'b1), .dataOut(Im_Out[4*dataWidth-1:3*dataWidth]));
        
    //Y_Stg3_3
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_3), .writeEn(1'b1), .dataOut(Re_Out[5*dataWidth-1:4*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_3), .writeEn(1'b1), .dataOut(Im_Out[5*dataWidth-1:4*dataWidth]));
    //Z_Stg3_3
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_3), .writeEn(1'b1), .dataOut(Re_Out[6*dataWidth-1:5*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_3), .writeEn(1'b1), .dataOut(Im_Out[6*dataWidth-1:5*dataWidth]));
    //Y_Stg3_4
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_4), .writeEn(1'b1), .dataOut(Re_Out[7*dataWidth-1:6*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_4), .writeEn(1'b1), .dataOut(Im_Out[7*dataWidth-1:6*dataWidth]));
    //Z_Stg3_4
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_4), .writeEn(1'b1), .dataOut(Re_Out[8*dataWidth-1:7*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_4), .writeEn(1'b1), .dataOut(Im_Out[8*dataWidth-1:7*dataWidth]));

    
endmodule
