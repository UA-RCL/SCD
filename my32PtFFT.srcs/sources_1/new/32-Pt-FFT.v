`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2016 12:58:55 AM
// Design Name: 
// Module Name: 32-Pt-FFT
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

module FFT_32_Pt(

    input [FFTPoints*(dataWidth)-1:0] Re_x,
    input [FFTPoints*(dataWidth)-1:0] Im_x,
    
    input [FFTPoints*(dataWidth)/2-1:0] Re_w,
    input [FFTPoints*(dataWidth)/2-1:0] Im_w,
    
    input clk,
    input reset,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out
    
    /*
    output [FFTPoints*dataWidth/2-1:0] Re_Y,
    output [FFTPoints*dataWidth/2-1:0] Im_Y,
    
    output [FFTPoints*dataWidth/2-1:0] Re_Z,
    output [FFTPoints*dataWidth/2-1:0] Im_Z
    */
);

    parameter FFTPoints = 32;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;
    
    //TODO: Verify which roots of unity get distributed to which butterfly
    
    //---------------------------Tree Level 1: 1x16 Butterflies-------------------------//
    wire [dataWidth*FFTPoints/2-1:0] Re_Y_Stg1, Re_Z_Stg1, Im_Y_Stg1, Im_Z_Stg1;
    
    genvar i;
    generate
        for (i = 0; i < dataWidth*FFTPoints/2 - 1; i = i + dataWidth) begin: bflies
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                //Top butterflies, the ones whose 
                level1_bfly(.Re_a(Re_x[i+dataWidth-1:i]), .Im_a(Im_x[i+dataWidth-1:i]),
                            .Re_b(Re_x[i + dataWidth-1 + dataWidth*FFTPoints/2 : i + dataWidth*FFTPoints/2]), .Im_b(Im_x[i + dataWidth-1 + dataWidth*FFTPoints/2 : i + dataWidth*FFTPoints/2]),
                            .Re_w(Re_w[i+dataWidth-1:i]), .Im_w(Im_w[i+dataWidth-1:i]),
                            .clk(clk), .reset(reset),
                            .Re_Y(Re_Y_Stg1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg1[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg1[i+dataWidth-1:i]));
        end
    endgenerate
    
    
    //------------------------------Pipeline Registers--------------------------------//
    //-------Each Butterfly Takes 3 Cycles, so these will be filled on cycle 4--------//
    wire [FFTPoints*dataWidth/2-1:0] Re_Y_Stg1_RegOut, Im_Y_Stg1_RegOut, Re_Z_Stg1_RegOut, Im_Z_Stg1_RegOut;
    
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Re_Y_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg1), .writeEn(1'b1), .dataOut(Re_Y_Stg1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Im_Y_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg1), .writeEn(1'b1), .dataOut(Im_Y_Stg1_RegOut));
        
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Re_Z_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg1), .writeEn(1'b1), .dataOut(Re_Z_Stg1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/2)) Im_Z_Stg1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg1), .writeEn(1'b1), .dataOut(Im_Z_Stg1_RegOut));
    
    //---------------------------Tree Level 2: 2x8 Butterflies-------------------------//
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
    
    //------------------------------Pipeline Registers Stage 2--------------------------------//
    //-----------Each Butterfly Takes 3 Cycles, so these will be filled on cycle 8------------//
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
    
    //---------------------------Tree Level 3: 4x4 Butterflies-------------------------//
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

    //------------------------------Pipeline Registers Stage 3--------------------------------//
    wire [FFTPoints*dataWidth/8-1:0] Re_Y_Stg3_1_RegOut, Re_Z_Stg3_1_RegOut, Im_Y_Stg3_1_RegOut, Im_Z_Stg3_1_RegOut,
                                     Re_Y_Stg3_2_RegOut, Re_Z_Stg3_2_RegOut, Im_Y_Stg3_2_RegOut, Im_Z_Stg3_2_RegOut,
                                     Re_Y_Stg3_3_RegOut, Re_Z_Stg3_3_RegOut, Im_Y_Stg3_3_RegOut, Im_Z_Stg3_3_RegOut,
                                     Re_Y_Stg3_4_RegOut, Re_Z_Stg3_4_RegOut, Im_Y_Stg3_4_RegOut, Im_Z_Stg3_4_RegOut;
    
    //Y_Stg3_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_1), .writeEn(1'b1), .dataOut(Re_Y_Stg3_1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_1), .writeEn(1'b1), .dataOut(Im_Y_Stg3_1_RegOut));
    //Z_Stg3_1
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_1), .writeEn(1'b1), .dataOut(Re_Z_Stg3_1_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_1_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_1), .writeEn(1'b1), .dataOut(Im_Z_Stg3_1_RegOut));
    //Y_Stg3_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_2), .writeEn(1'b1), .dataOut(Re_Y_Stg3_2_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_2), .writeEn(1'b1), .dataOut(Im_Y_Stg3_2_RegOut));
    //Z_Stg3_2
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_2), .writeEn(1'b1), .dataOut(Re_Z_Stg3_2_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_2_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_2), .writeEn(1'b1), .dataOut(Im_Z_Stg3_2_RegOut));
        
    //Y_Stg3_3
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_3), .writeEn(1'b1), .dataOut(Re_Y_Stg3_3_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_3), .writeEn(1'b1), .dataOut(Im_Y_Stg3_3_RegOut));
    //Z_Stg3_3
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_3), .writeEn(1'b1), .dataOut(Re_Z_Stg3_3_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_3_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_3), .writeEn(1'b1), .dataOut(Im_Z_Stg3_3_RegOut));
    //Y_Stg3_4
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Y_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg3_4), .writeEn(1'b1), .dataOut(Re_Y_Stg3_4_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Y_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg3_4), .writeEn(1'b1), .dataOut(Im_Y_Stg3_4_RegOut));
    //Z_Stg3_4
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Re_Z_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg3_4), .writeEn(1'b1), .dataOut(Re_Z_Stg3_4_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/8)) Im_Z_Stg3_4_Reg 
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg3_4), .writeEn(1'b1), .dataOut(Im_Z_Stg3_4_RegOut));
    

    //---------------------------Tree Level 4: 16 Butterflies-------------------------//
    
    wire[FFTPoints*dataWidth/16-1:0] Re_Y_Stg4_1, Re_Z_Stg4_1, Im_Y_Stg4_1, Im_Z_Stg4_1,
                                     Re_Y_Stg4_2, Re_Z_Stg4_2, Im_Y_Stg4_2, Im_Z_Stg4_2,
                                     Re_Y_Stg4_3, Re_Z_Stg4_3, Im_Y_Stg4_3, Im_Z_Stg4_3,
                                     Re_Y_Stg4_4, Re_Z_Stg4_4, Im_Y_Stg4_4, Im_Z_Stg4_4,
                                     Re_Y_Stg4_5, Re_Z_Stg4_5, Im_Y_Stg4_5, Im_Z_Stg4_5,
                                     Re_Y_Stg4_6, Re_Z_Stg4_6, Im_Y_Stg4_6, Im_Z_Stg4_6,
                                     Re_Y_Stg4_7, Re_Z_Stg4_7, Im_Y_Stg4_7, Im_Z_Stg4_7,
                                     Re_Y_Stg4_8, Re_Z_Stg4_8, Im_Y_Stg4_8, Im_Z_Stg4_8;

    generate
        //Now half the size of the for loop again and do it 8 times, four times for the Y's and four times for the Z's
        //First pass for Y_Stg3_1
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_1
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level4_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Y_Stg3_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg3_1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Y_Stg3_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]), 
                            .Im_b(Im_Y_Stg3_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),
                            .Re_Y(Re_Y_Stg4_1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_1[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg4_1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_1[i+dataWidth-1:i]));
        end
        //Now pass for Y_Stg3_2
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_2
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level4_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Z_Stg3_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg3_1_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Z_Stg3_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]), 
                            .Im_b(Im_Z_Stg3_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),
                            .Re_Y(Re_Y_Stg4_2[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_2[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg4_2[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_2[i+dataWidth-1:i]));
        end
        //Now do the same thing again for the previous stage's Z arrays
        //First for Z_Stg3_1
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_3
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level4_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Y_Stg3_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg3_2_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Y_Stg3_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]), 
                            .Im_b(Im_Y_Stg3_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),
                            .Re_Y(Re_Y_Stg4_3[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_3[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg4_3[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_3[i+dataWidth-1:i]));
        end
        //Now for Z_Stg3_2
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_4
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))
                level4_bfly(.clk(clk), .reset(reset),
                            .Re_a(Re_Z_Stg3_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg3_2_RegOut[i+dataWidth-1:i]),
                            .Re_b(Re_Z_Stg3_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]), 
                            .Im_b(Im_Z_Stg3_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),
                            .Re_Y(Re_Y_Stg4_4[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_4[i+dataWidth-1:i]),
                            .Re_Z(Re_Z_Stg4_4[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_4[i+dataWidth-1:i]));
        end
        //First pass for Y_Stg3_3                                                                                          
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_5                                     
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                      
                level4_bfly(.clk(clk), .reset(reset),                                                                      
                            .Re_a(Re_Y_Stg3_3_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg3_3_RegOut[i+dataWidth-1:i]),        
                            .Re_b(Re_Y_Stg3_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Im_b(Im_Y_Stg3_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),                                            
                            .Re_Y(Re_Y_Stg4_5[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_5[i+dataWidth-1:i]),                      
                            .Re_Z(Re_Z_Stg4_5[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_5[i+dataWidth-1:i]));                     
        end                                                                                                                
        //Now pass for Y_Stg3_4                                                                                            
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_6                                     
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                      
                level4_bfly(.clk(clk), .reset(reset),                                                                      
                            .Re_a(Re_Z_Stg3_3_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg3_3_RegOut[i+dataWidth-1:i]),        
                            .Re_b(Re_Z_Stg3_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Im_b(Im_Z_Stg3_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),                                            
                            .Re_Y(Re_Y_Stg4_6[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_6[i+dataWidth-1:i]),                      
                            .Re_Z(Re_Z_Stg4_6[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_6[i+dataWidth-1:i]));                     
        end                                                                                                                
        //Now do the same thing again for the previous stage's Z arrays                                                    
        //First for Z_Stg3_3                                                                                               
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_7                                     
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                      
                level4_bfly(.clk(clk), .reset(reset),                                                                      
                            .Re_a(Re_Y_Stg3_4_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg3_4_RegOut[i+dataWidth-1:i]),        
                            .Re_b(Re_Y_Stg3_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Im_b(Im_Y_Stg3_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),                                            
                            .Re_Y(Re_Y_Stg4_7[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_7[i+dataWidth-1:i]),                      
                            .Re_Z(Re_Z_Stg4_7[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_7[i+dataWidth-1:i]));                     
        end                                                                                                                
        //Now for Z_Stg3_4                                                                                                 
        for (i = 0; i < dataWidth*FFTPoints/16 - 1; i = i + dataWidth) begin: bflies4_8                                     
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                      
                level4_bfly(.clk(clk), .reset(reset),                                                                      
                            .Re_a(Re_Z_Stg3_4_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg3_4_RegOut[i+dataWidth-1:i]),        
                            .Re_b(Re_Z_Stg3_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Im_b(Im_Z_Stg3_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/16 : i + dataWidth*FFTPoints/16]),
                            .Re_w(Re_w[8*i+dataWidth-1:8*i]), .Im_w(Im_w[8*i+dataWidth-1:8*i]),                                            
                            .Re_Y(Re_Y_Stg4_8[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg4_8[i+dataWidth-1:i]),                      
                            .Re_Z(Re_Z_Stg4_8[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg4_8[i+dataWidth-1:i]));                     
        end                                                                                                                
    endgenerate
    
    
    //------------------------------Pipeline Registers Stage 4--------------------------------//
    wire[FFTPoints*dataWidth/16-1:0] Re_Y_Stg4_1_RegOut, Re_Z_Stg4_1_RegOut, Im_Y_Stg4_1_RegOut, Im_Z_Stg4_1_RegOut,
                                     Re_Y_Stg4_2_RegOut, Re_Z_Stg4_2_RegOut, Im_Y_Stg4_2_RegOut, Im_Z_Stg4_2_RegOut,
                                     Re_Y_Stg4_3_RegOut, Re_Z_Stg4_3_RegOut, Im_Y_Stg4_3_RegOut, Im_Z_Stg4_3_RegOut,
                                     Re_Y_Stg4_4_RegOut, Re_Z_Stg4_4_RegOut, Im_Y_Stg4_4_RegOut, Im_Z_Stg4_4_RegOut,
                                     Re_Y_Stg4_5_RegOut, Re_Z_Stg4_5_RegOut, Im_Y_Stg4_5_RegOut, Im_Z_Stg4_5_RegOut,
                                     Re_Y_Stg4_6_RegOut, Re_Z_Stg4_6_RegOut, Im_Y_Stg4_6_RegOut, Im_Z_Stg4_6_RegOut,
                                     Re_Y_Stg4_7_RegOut, Re_Z_Stg4_7_RegOut, Im_Y_Stg4_7_RegOut, Im_Z_Stg4_7_RegOut,
                                     Re_Y_Stg4_8_RegOut, Re_Z_Stg4_8_RegOut, Im_Y_Stg4_8_RegOut, Im_Z_Stg4_8_RegOut;            
                                                                                                                    
    //Y_Stg4_1                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_1), .writeEn(1'b1), .dataOut(Re_Y_Stg4_1_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_1), .writeEn(1'b1), .dataOut(Im_Y_Stg4_1_RegOut));             
    //Z_Stg4_1                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_1), .writeEn(1'b1), .dataOut(Re_Z_Stg4_1_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_1), .writeEn(1'b1), .dataOut(Im_Z_Stg4_1_RegOut));             
    //Y_Stg4_2                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_2), .writeEn(1'b1), .dataOut(Re_Y_Stg4_2_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_2), .writeEn(1'b1), .dataOut(Im_Y_Stg4_2_RegOut));             
    //Z_Stg4_2                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_2), .writeEn(1'b1), .dataOut(Re_Z_Stg4_2_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_2), .writeEn(1'b1), .dataOut(Im_Z_Stg4_2_RegOut));                                                                                                                    
    //Y_Stg4_3                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_3), .writeEn(1'b1), .dataOut(Re_Y_Stg4_3_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_3), .writeEn(1'b1), .dataOut(Im_Y_Stg4_3_RegOut));             
    //Z_Stg4_3                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_3), .writeEn(1'b1), .dataOut(Re_Z_Stg4_3_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_3), .writeEn(1'b1), .dataOut(Im_Z_Stg4_3_RegOut));             
    //Y_Stg4_4                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_4), .writeEn(1'b1), .dataOut(Re_Y_Stg4_4_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_4), .writeEn(1'b1), .dataOut(Im_Y_Stg4_4_RegOut));             
    //Z_Stg4_4                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_4), .writeEn(1'b1), .dataOut(Re_Z_Stg4_4_RegOut));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_4), .writeEn(1'b1), .dataOut(Im_Z_Stg4_4_RegOut));   
    //Y_Stg4_5                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_5), .writeEn(1'b1), .dataOut(Re_Y_Stg4_5_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_5), .writeEn(1'b1), .dataOut(Im_Y_Stg4_5_RegOut));
    //Z_Stg4_5                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_5), .writeEn(1'b1), .dataOut(Re_Z_Stg4_5_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_5), .writeEn(1'b1), .dataOut(Im_Z_Stg4_5_RegOut));
    //Y_Stg4_6                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_6), .writeEn(1'b1), .dataOut(Re_Y_Stg4_6_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_6), .writeEn(1'b1), .dataOut(Im_Y_Stg4_6_RegOut));
    //Z_Stg4_6                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_6), .writeEn(1'b1), .dataOut(Re_Z_Stg4_6_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_6), .writeEn(1'b1), .dataOut(Im_Z_Stg4_6_RegOut));
                                                                                                       
    //Y_Stg4_7                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_7), .writeEn(1'b1), .dataOut(Re_Y_Stg4_7_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_7), .writeEn(1'b1), .dataOut(Im_Y_Stg4_7_RegOut));
    //Z_Stg4_7                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_7), .writeEn(1'b1), .dataOut(Re_Z_Stg4_7_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_7), .writeEn(1'b1), .dataOut(Im_Z_Stg4_7_RegOut));
    //Y_Stg4_8                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Y_Stg4_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg4_8), .writeEn(1'b1), .dataOut(Re_Y_Stg4_8_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Y_Stg4_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg4_8), .writeEn(1'b1), .dataOut(Im_Y_Stg4_8_RegOut));
    //Z_Stg4_8                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Re_Z_Stg4_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg4_8), .writeEn(1'b1), .dataOut(Re_Z_Stg4_8_RegOut));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/16)) Im_Z_Stg4_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg4_8), .writeEn(1'b1), .dataOut(Im_Z_Stg4_8_RegOut));
    
    //---------------------------Tree Level 5: 16 Butterfly-------------------------//

    wire[FFTPoints*dataWidth/32-1:0] Re_Y_Stg5_1, Re_Z_Stg5_1, Im_Y_Stg5_1, Im_Z_Stg5_1,
                                     Re_Y_Stg5_2, Re_Z_Stg5_2, Im_Y_Stg5_2, Im_Z_Stg5_2,
                                     Re_Y_Stg5_3, Re_Z_Stg5_3, Im_Y_Stg5_3, Im_Z_Stg5_3,
                                     Re_Y_Stg5_4, Re_Z_Stg5_4, Im_Y_Stg5_4, Im_Z_Stg5_4,
                                     Re_Y_Stg5_5, Re_Z_Stg5_5, Im_Y_Stg5_5, Im_Z_Stg5_5,
                                     Re_Y_Stg5_6, Re_Z_Stg5_6, Im_Y_Stg5_6, Im_Z_Stg5_6,
                                     Re_Y_Stg5_7, Re_Z_Stg5_7, Im_Y_Stg5_7, Im_Z_Stg5_7,
                                     Re_Y_Stg5_8, Re_Z_Stg5_8, Im_Y_Stg5_8, Im_Z_Stg5_8,
                                     Re_Y_Stg5_9, Re_Z_Stg5_9, Im_Y_Stg5_9, Im_Z_Stg5_9,
                                     Re_Y_Stg5_10, Re_Z_Stg5_10, Im_Y_Stg5_10, Im_Z_Stg5_10,
                                     Re_Y_Stg5_11, Re_Z_Stg5_11, Im_Y_Stg5_11, Im_Z_Stg5_11,
                                     Re_Y_Stg5_12, Re_Z_Stg5_12, Im_Y_Stg5_12, Im_Z_Stg5_12,
                                     Re_Y_Stg5_13, Re_Z_Stg5_13, Im_Y_Stg5_13, Im_Z_Stg5_13,
                                     Re_Y_Stg5_14, Re_Z_Stg5_14, Im_Y_Stg5_14, Im_Z_Stg5_14,
                                     Re_Y_Stg5_15, Re_Z_Stg5_15, Im_Y_Stg5_15, Im_Z_Stg5_15,
                                     Re_Y_Stg5_16, Re_Z_Stg5_16, Im_Y_Stg5_16, Im_Z_Stg5_16;

    generate                                                                                                                 
        //Now half the size of the for loop again and do it 16 times, 8 times for the Y's and 8 times for the Z's       
        //First pass for Y_Stg4_1                                                                                            
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_1                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_1_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_1[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_1[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_1[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_1[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now pass for Y_Stg4_2                                                                                              
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_2                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_1_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_1_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_1_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_2[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_2[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_2[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_2[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now do the same thing again for the previous stage's Z arrays                                                      
        //First for Z_Stg4_1                                                                                                 
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_3                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_2_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_3[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_3[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_3[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_3[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now for Z_Stg4_2                                                                                                   
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_4                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_2_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_2_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_2_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_4[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_4[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_4[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_4[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //First pass for Y_Stg4_3                                                                                            
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_5                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_3_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_3_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_5[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_5[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_5[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_5[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now pass for Y_Stg4_4                                                                                              
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_6                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_3_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_3_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_3_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_6[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_6[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_6[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_6[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now do the same thing again for the previous stage's Z arrays                                                      
        //First for Z_Stg4_3                                                                                                 
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_7                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_4_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_4_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_7[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_7[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_7[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_7[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now for Z_Stg4_4                                                                                                   
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_8                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_4_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_4_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_4_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_8[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_8[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_8[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_8[i+dataWidth-1:i]));                       
        end

     
        //First pass for Y_Stg4_5                                                                                            
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_9                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_5_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_5_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_5_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_5_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_9[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_9[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_9[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_9[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now pass for Y_Stg4_6                                                                                              
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_10                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_5_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_5_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_5_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_5_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_10[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_10[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_10[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_10[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now do the same thing again for the previous stage's Z arrays                                                      
        //First for Z_Stg4_5                                                                                                 
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_11                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_6_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_6_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_6_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_6_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_11[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_11[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_11[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_11[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now for Z_Stg4_6                                                                                                   
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_12                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_6_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_6_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_6_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_6_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_12[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_12[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_12[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_12[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //First pass for Y_Stg4_7                                                                                            
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_13                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_7_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_7_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_7_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_7_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_13[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_13[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_13[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_13[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now pass for Y_Stg4_8                                                                                              
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_14                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_7_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_7_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_7_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_7_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_14[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_14[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_14[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_14[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now do the same thing again for the previous stage's Z arrays                                                      
        //First for Z_Stg4_7                                                                                                 
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_15                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Y_Stg4_8_RegOut[i+dataWidth-1:i]), .Im_a(Im_Y_Stg4_8_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Y_Stg4_8_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Y_Stg4_8_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_15[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_15[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_15[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_15[i+dataWidth-1:i]));                       
        end                                                                                                                  
        //Now for Z_Stg4_8                                                                                                   
        for (i = 0; i < dataWidth*FFTPoints/32 - 1; i = i + dataWidth) begin: bflies5_16                                      
            FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth))                                                        
                level5_bfly(.clk(clk), .reset(reset),                                                                        
                            .Re_a(Re_Z_Stg4_8_RegOut[i+dataWidth-1:i]), .Im_a(Im_Z_Stg4_8_RegOut[i+dataWidth-1:i]),          
                            .Re_b(Re_Z_Stg4_8_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Im_b(Im_Z_Stg4_8_RegOut[i + dataWidth-1 + dataWidth*FFTPoints/32 : i + dataWidth*FFTPoints/32]),
                            .Re_w(Re_w[16*i+dataWidth-1:16*i]), .Im_w(Im_w[16*i+dataWidth-1:16*i]),                                              
                            .Re_Y(Re_Y_Stg5_16[i+dataWidth-1:i]), .Im_Y(Im_Y_Stg5_16[i+dataWidth-1:i]),                        
                            .Re_Z(Re_Z_Stg5_16[i+dataWidth-1:i]), .Im_Z(Im_Z_Stg5_16[i+dataWidth-1:i]));                       
        end  
    endgenerate                                                                                                             

    //------------------------------Pipeline Registers Stage 5--------------------------------//
    
    //Y_Stg5_1                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_1), .writeEn(1'b1), .dataOut(Re_Out[dataWidth-1:0]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_1), .writeEn(1'b1), .dataOut(Im_Out[dataWidth-1:0]));             
    //Z_Stg5_1                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_1), .writeEn(1'b1), .dataOut(Re_Out[2*dataWidth-1:dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_1_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_1), .writeEn(1'b1), .dataOut(Im_Out[2*dataWidth-1:dataWidth]));             
    //Y_Stg5_2                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_2), .writeEn(1'b1), .dataOut(Re_Out[3*dataWidth-1:2*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_2), .writeEn(1'b1), .dataOut(Im_Out[3*dataWidth-1:2*dataWidth]));             
    //Z_Stg5_2                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_2), .writeEn(1'b1), .dataOut(Re_Out[4*dataWidth-1:3*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_2_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_2), .writeEn(1'b1), .dataOut(Im_Out[4*dataWidth-1:3*dataWidth]));                                                                                                                    
    //Y_Stg5_3                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_3), .writeEn(1'b1), .dataOut(Re_Out[5*dataWidth-1:4*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_3), .writeEn(1'b1), .dataOut(Im_Out[5*dataWidth-1:4*dataWidth]));             
    //Z_Stg5_3                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_3), .writeEn(1'b1), .dataOut(Re_Out[6*dataWidth-1:5*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_3_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_3), .writeEn(1'b1), .dataOut(Im_Out[6*dataWidth-1:5*dataWidth]));             
    //Y_Stg5_4                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_4), .writeEn(1'b1), .dataOut(Re_Out[7*dataWidth-1:6*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_4), .writeEn(1'b1), .dataOut(Im_Out[7*dataWidth-1:6*dataWidth]));             
    //Z_Stg5_4                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_4), .writeEn(1'b1), .dataOut(Re_Out[8*dataWidth-1:7*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_4_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_4), .writeEn(1'b1), .dataOut(Im_Out[8*dataWidth-1:7*dataWidth]));   
    //Y_Stg5_5                                                                                        
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_5), .writeEn(1'b1), .dataOut(Re_Out[9*dataWidth-1:8*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_5), .writeEn(1'b1), .dataOut(Im_Out[9*dataWidth-1:8*dataWidth]));
    //Z_Stg5_5                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_5), .writeEn(1'b1), .dataOut(Re_Out[10*dataWidth-1:9*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_5_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_5), .writeEn(1'b1), .dataOut(Im_Out[10*dataWidth-1:9*dataWidth]));
    //Y_Stg5_6                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_6), .writeEn(1'b1), .dataOut(Re_Out[11*dataWidth-1:10*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_6), .writeEn(1'b1), .dataOut(Im_Out[11*dataWidth-1:10*dataWidth]));
    //Z_Stg5_6                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_6), .writeEn(1'b1), .dataOut(Re_Out[12*dataWidth-1:11*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_6_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_6), .writeEn(1'b1), .dataOut(Im_Out[12*dataWidth-1:11*dataWidth]));                                                                                     
    //Y_Stg5_7                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_7), .writeEn(1'b1), .dataOut(Re_Out[13*dataWidth-1:12*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_7), .writeEn(1'b1), .dataOut(Im_Out[13*dataWidth-1:12*dataWidth]));
    //Z_Stg5_7                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_7), .writeEn(1'b1), .dataOut(Re_Out[14*dataWidth-1:13*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_7_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_7), .writeEn(1'b1), .dataOut(Im_Out[14*dataWidth-1:13*dataWidth]));
    //Y_Stg5_8                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_8), .writeEn(1'b1), .dataOut(Re_Out[15*dataWidth-1:14*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_8), .writeEn(1'b1), .dataOut(Im_Out[15*dataWidth-1:14*dataWidth]));
    //Z_Stg5_8                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_8), .writeEn(1'b1), .dataOut(Re_Out[16*dataWidth-1:15*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_8_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_8), .writeEn(1'b1), .dataOut(Im_Out[16*dataWidth-1:15*dataWidth]));
    //Y_Stg5_9                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_9_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_9), .writeEn(1'b1), .dataOut(Re_Out[17*dataWidth-1:16*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_9_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_9), .writeEn(1'b1), .dataOut(Im_Out[17*dataWidth-1:16*dataWidth]));             
    //Z_Stg5_9                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_9_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_9), .writeEn(1'b1), .dataOut(Re_Out[18*dataWidth-1:17*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_9_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_9), .writeEn(1'b1), .dataOut(Im_Out[18*dataWidth-1:17*dataWidth]));             
    //Y_Stg5_10                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_10_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_10), .writeEn(1'b1), .dataOut(Re_Out[19*dataWidth-1:18*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_10_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_10), .writeEn(1'b1), .dataOut(Im_Out[19*dataWidth-1:18*dataWidth]));             
    //Z_Stg5_10                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_10_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_10), .writeEn(1'b1), .dataOut(Re_Out[20*dataWidth-1:19*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_10_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_10), .writeEn(1'b1), .dataOut(Im_Out[20*dataWidth-1:19*dataWidth]));                                                                                                                    
    //Y_Stg5_11                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_11_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_11), .writeEn(1'b1), .dataOut(Re_Out[21*dataWidth-1:20*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_11_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_11), .writeEn(1'b1), .dataOut(Im_Out[21*dataWidth-1:20*dataWidth]));             
    //Z_Stg5_11                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_11_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_11), .writeEn(1'b1), .dataOut(Re_Out[22*dataWidth-1:21*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_11_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_11), .writeEn(1'b1), .dataOut(Im_Out[22*dataWidth-1:21*dataWidth]));             
    //Y_Stg5_12                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_12_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_12), .writeEn(1'b1), .dataOut(Re_Out[23*dataWidth-1:22*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_12_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_12), .writeEn(1'b1), .dataOut(Im_Out[23*dataWidth-1:22*dataWidth]));             
    //Z_Stg5_12                                                                                                      
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_12_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_12), .writeEn(1'b1), .dataOut(Re_Out[24*dataWidth-1:23*dataWidth]));             
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_12_Reg                                                    
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_12), .writeEn(1'b1), .dataOut(Im_Out[24*dataWidth-1:23*dataWidth]));   
    //Y_Stg5_13                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_13_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_13), .writeEn(1'b1), .dataOut(Re_Out[25*dataWidth-1:24*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_13_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_13), .writeEn(1'b1), .dataOut(Im_Out[25*dataWidth-1:24*dataWidth]));
    //Z_Stg5_13                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_13_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_13), .writeEn(1'b1), .dataOut(Re_Out[26*dataWidth-1:25*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_13_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_13), .writeEn(1'b1), .dataOut(Im_Out[26*dataWidth-1:25*dataWidth]));
    //Y_Stg5_14                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_14_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_14), .writeEn(1'b1), .dataOut(Re_Out[27*dataWidth-1:26*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_14_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_14), .writeEn(1'b1), .dataOut(Im_Out[27*dataWidth-1:26*dataWidth]));
    //Z_Stg5_14                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_14_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_14), .writeEn(1'b1), .dataOut(Re_Out[28*dataWidth-1:27*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_14_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_14), .writeEn(1'b1), .dataOut(Im_Out[28*dataWidth-1:27*dataWidth]));                                                                                               
    //Y_Stg5_15                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_15_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_15), .writeEn(1'b1), .dataOut(Re_Out[29*dataWidth-1:28*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_15_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_15), .writeEn(1'b1), .dataOut(Im_Out[29*dataWidth-1:28*dataWidth]));
    //Z_Stg5_15                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_15_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_15), .writeEn(1'b1), .dataOut(Re_Out[30*dataWidth-1:29*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_15_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_15), .writeEn(1'b1), .dataOut(Im_Out[30*dataWidth-1:29*dataWidth]));
    //Y_Stg5_16                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Y_Stg5_16_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Y_Stg5_16), .writeEn(1'b1), .dataOut(Re_Out[31*dataWidth-1:30*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Y_Stg5_16_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Y_Stg5_16), .writeEn(1'b1), .dataOut(Im_Out[31*dataWidth-1:30*dataWidth]));
    //Z_Stg5_16                                                                                         
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Re_Z_Stg5_16_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Re_Z_Stg5_16), .writeEn(1'b1), .dataOut(Re_Out[32*dataWidth-1:31*dataWidth]));
    NBitReg #(.dataWidth(dataWidth*FFTPoints/32)) Im_Z_Stg5_16_Reg                                      
        (.clk(clk), .reset(reset), .dataIn(Im_Z_Stg5_16), .writeEn(1'b1), .dataOut(Im_Out[32*dataWidth-1:31*dataWidth]));
    
endmodule
