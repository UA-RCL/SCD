`timescale 1ns / 1ps

module ConjProdFFT_32Pt_Datapath
#(
    localparam ReImWidth = 32,
    localparam CmplxWidth = 2*ReImWidth,
    localparam FFT_Pts = 32
)
(
    input clk,
    input reset,

    input [CmplxWidth*FFT_Pts-1:0] R_word1, 
    input [CmplxWidth*FFT_Pts-1:0] R_word2,
    input dataValid,
    
    output [ReImWidth*FFT_Pts-1:0] FFT_Output_Real,
    output [ReImWidth*FFT_Pts-1:0] FFT_Output_Imag,
    output FFT_Done
);
    //parameter COMPLEX_MULT_DELAY = 5;
    
    //Wires for holding the input BRAM words split into their real and imaginary parts
    wire [ReImWidth*FFT_Pts-1:0] R_word1_Real, R_word1_Imag, R_word2_Real, R_word2_Imag;
    //Wires for holding the conjugated imaginary parts of word1 and word2
    wire [ReImWidth*FFT_Pts-1:0] R_word2_ImagConj;
    //Wires for holding the outputs of the complex multipliers
    wire [ReImWidth*FFT_Pts-1:0] Mult_Real, Mult_Imag;
    wire [ReImWidth*FFT_Pts-1:0] Mult_Real_Flipped, Mult_Imag_Flipped;
    //Wire for holding the FFT output
    //wire [1023:0] FFT_Output_Real, FFT_Output_Imag;
    //Wire for holding the dataValid signal as it waits for the multiplier
    wire [FFT_Pts-1:0] pairwiseMultValid;
    
    genvar i;
    generate
    
    for (i = 0; i < 32; i = i + 1) begin: distributeDataLoop
        assign R_word1_Real[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = R_word1[(FFT_Pts-i)*CmplxWidth - 0*ReImWidth - 1 -: ReImWidth];
        assign R_word1_Imag[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = R_word1[(FFT_Pts-i)*CmplxWidth - 1*ReImWidth - 1 -: ReImWidth];
        
        assign R_word2_Real[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = R_word2[(FFT_Pts-i)*CmplxWidth - 0*ReImWidth - 1 -: ReImWidth];
        assign R_word2_Imag[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = R_word2[(FFT_Pts-i)*CmplxWidth - 1*ReImWidth - 1 -: ReImWidth];
    end
    
    //Now, add the conjugation unit
    FloP_ComplexConjugate #(.dataWidth(32), .numElements(32)) complexConj(
        .dataIn(R_word2_Imag), .dataOut(R_word2_ImagConj)
    );
    
    //Followed by the set of 32 complex multipliers
    //With accompanying registers to sync up the dataValid signal with its corresponding multiplier data
    //(i.e. delay the dataValid signal for the latency of the multipliers)
    for (i = 0; i < 32; i = i + 1) begin: multipliers
        FloP_Complex_Mult mult(
            .Re_a(R_word1_Real[1023-32*i:1023-32*(i+1)+1]), .Re_b(R_word2_Real[1023-32*i:1023-32*(i+1)+1]),
            .Im_a(R_word1_Imag[1023-32*i:1023-32*(i+1)+1]), .Im_b(R_word2_ImagConj[1023-32*i:1023-32*(i+1)+1]),
            .clk(clk), .reset(reset), .dataValid(dataValid), .dataValidOut(pairwiseMultValid[i]),
            .Re_Z(Mult_Real[1023-32*i:1023-32*(i+1)+1]), .Im_Z(Mult_Imag[1023-32*i:1023-32*(i+1)+1])
        );
    end
    
    //Flip the order of the samples going into the FFT (from 0, 1, 2, 3, ..., 31) to (31, 30, 29, 28, ..., 0)
    for (i = 0; i < FFT_Pts; i = i + 1) begin: flipMultData
        assign Mult_Real_Flipped[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = Mult_Real[(1+i)*ReImWidth - 1 -: ReImWidth];
        assign Mult_Imag_Flipped[(FFT_Pts-i)*ReImWidth - 1 -: ReImWidth] = Mult_Imag[(1+i)*ReImWidth - 1 -: ReImWidth];
    end
    
    endgenerate;
    
    //Finally, the meat of the design is the 32PT FFT Datapath
    FFT_32_Pt_Datapath myFFT(
        .clk(clk), .reset(reset), .dataValid(pairwiseMultValid[0]), 
        .Re_x(Mult_Real_Flipped), .Im_x(Mult_Imag_Flipped),
        .Re_Out(FFT_Output_Real), .Im_Out(FFT_Output_Imag), .done(FFT_Done)
    );
    
    
endmodule
