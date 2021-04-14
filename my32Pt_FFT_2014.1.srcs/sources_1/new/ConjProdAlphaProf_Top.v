`timescale 1ns / 1ps

`include "CLOG2_vh.vh"

module ConjProdAlphaProf_Top
#(
    localparam ReImWidth = 32,
    localparam CmplxWidth = 2*ReImWidth, //Width of a complex number
    localparam FFT_Pts = 32,
    localparam AlphaProfPoints = 16,
    localparam numMemories = 4
)
(
    input start,
    input clk,
    input reset,
    
    //TODO: Change ConjProdFFT to allow for data to come in {(Re, Im), (Re, Im), ..., (Re, Im)} pairs
    input [(FFT_Pts/4)*CmplxWidth-1:0] dataIn1,
    input [(`CLOG2(256))-1:0] wrAddr1,
    input [numMemories-1:0] writeEns1,
    
    output ConjProd_Done,
    output AlphaProf_Done,
    output [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfBRAMOut1Output, alphaProfBRAMOut2Output,
    output [FFT_Pts/4*ReImWidth - 1 : 0] AlphaProf_EightSamples, AlphaProf_FinalEightSamples,
    output AlphaProf_EightSamplesValid
);

wire [FFT_Pts*CmplxWidth-1:0] ConjProd_FFT_to_AlphaProfile;
wire ConjProd_DataValid_to_AlphaProfile;

//Instantiate ConjProdFFT_32Pt_TopController
ConjProdFFT_32Pt_TopController conjProdFFT(
    .start(start),
    .clk(clk),
    .reset(reset),
    
    .dataIn1(dataIn1),
    .wrAddr1(wrAddr1),
    .writeEns1(writeEns1),
    
    .ConjProdDone(ConjProd_Done),
    .ConjProdDataValid(ConjProd_DataValid_to_AlphaProfile),
    .ConjProdFFTOut(ConjProd_FFT_to_AlphaProfile)
);

//Instantiate AlphaProfile
AlphaProfile alphaProf(
    .clk(clk),
    .reset(reset),
    .FFT_Result_In(ConjProd_FFT_to_AlphaProfile),
    .FFT_DataValid(ConjProd_DataValid_to_AlphaProfile),
    .AlphaProfile_Done(AlphaProf_Done),
    .alphaProfBRAMOut1Output(alphaProfBRAMOut1Output), .alphaProfBRAMOut2Output(alphaProfBRAMOut2Output),
    .AlphaProf_EightSamples(AlphaProf_EightSamples),
    .AlphaProf_FinalEightSamples(AlphaProf_FinalEightSamples),
    .AlphaProf_EightSamplesValid(AlphaProf_EightSamplesValid)
);

endmodule
