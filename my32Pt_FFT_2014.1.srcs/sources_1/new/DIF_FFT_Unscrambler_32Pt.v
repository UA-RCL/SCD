`timescale 1ns / 1ps

module DIF_FFT_Unscrambler_32Pt
#(
    parameter FFTPoints = 32,
    parameter expWidth = 8,
    parameter sigWidth = 23,
    parameter dataWidth = expWidth+sigWidth+1
)
(
    
    input [FFTPoints*dataWidth-1:0] Re_In,
    input [FFTPoints*dataWidth-1:0] Im_In,
    
    output [FFTPoints*dataWidth-1:0] Re_Out,
    output [FFTPoints*dataWidth-1:0] Im_Out
    
);

    assign Re_Out[dataWidth*0 + dataWidth-1: 0] = Re_In[dataWidth*0 + dataWidth-1: 0];
    assign Re_Out[dataWidth*1 + dataWidth-1: dataWidth*1] = Re_In[dataWidth*16 + dataWidth-1: dataWidth*16];
    assign Re_Out[dataWidth*2 + dataWidth-1: dataWidth*2] = Re_In[dataWidth*8 + dataWidth-1: dataWidth*8];
    assign Re_Out[dataWidth*3 + dataWidth-1: dataWidth*3] = Re_In[dataWidth*24 + dataWidth-1: dataWidth*24];
    assign Re_Out[dataWidth*4 + dataWidth-1: dataWidth*4] = Re_In[dataWidth*4 + dataWidth-1: dataWidth*4];
    assign Re_Out[dataWidth*5 + dataWidth-1: dataWidth*5] = Re_In[dataWidth*20 + dataWidth-1: dataWidth*20];
    assign Re_Out[dataWidth*6 + dataWidth-1: dataWidth*6] = Re_In[dataWidth*12 + dataWidth-1: dataWidth*12];
    assign Re_Out[dataWidth*7 + dataWidth-1: dataWidth*7] = Re_In[dataWidth*28 + dataWidth-1: dataWidth*28];
    assign Re_Out[dataWidth*8 + dataWidth-1: dataWidth*8] = Re_In[dataWidth*2 + dataWidth-1: dataWidth*2];
    assign Re_Out[dataWidth*9 + dataWidth-1: dataWidth*9] = Re_In[dataWidth*18 + dataWidth-1: dataWidth*18];
    assign Re_Out[dataWidth*10 + dataWidth-1: dataWidth*10] = Re_In[dataWidth*10 + dataWidth-1: dataWidth*10];
    assign Re_Out[dataWidth*11 + dataWidth-1: dataWidth*11] = Re_In[dataWidth*26 + dataWidth-1: dataWidth*26];
    assign Re_Out[dataWidth*12 + dataWidth-1: dataWidth*12] = Re_In[dataWidth*6 + dataWidth-1: dataWidth*6];
    assign Re_Out[dataWidth*13 + dataWidth-1: dataWidth*13] = Re_In[dataWidth*22 + dataWidth-1: dataWidth*22];
    assign Re_Out[dataWidth*14 + dataWidth-1: dataWidth*14] = Re_In[dataWidth*14 + dataWidth-1: dataWidth*14];
    assign Re_Out[dataWidth*15 + dataWidth-1: dataWidth*15] = Re_In[dataWidth*30 + dataWidth-1: dataWidth*30];
    assign Re_Out[dataWidth*16 + dataWidth-1: dataWidth*16] = Re_In[dataWidth*1 + dataWidth-1: dataWidth*1];
    assign Re_Out[dataWidth*17 + dataWidth-1: dataWidth*17] = Re_In[dataWidth*17 + dataWidth-1: dataWidth*17];
    assign Re_Out[dataWidth*18 + dataWidth-1: dataWidth*18] = Re_In[dataWidth*9 + dataWidth-1: dataWidth*9];
    assign Re_Out[dataWidth*19 + dataWidth-1: dataWidth*19] = Re_In[dataWidth*25 + dataWidth-1: dataWidth*25];
    assign Re_Out[dataWidth*20 + dataWidth-1: dataWidth*20] = Re_In[dataWidth*5 + dataWidth-1: dataWidth*5];
    assign Re_Out[dataWidth*21 + dataWidth-1: dataWidth*21] = Re_In[dataWidth*21 + dataWidth-1: dataWidth*21];
    assign Re_Out[dataWidth*22 + dataWidth-1: dataWidth*22] = Re_In[dataWidth*13 + dataWidth-1: dataWidth*13];
    assign Re_Out[dataWidth*23 + dataWidth-1: dataWidth*23] = Re_In[dataWidth*29 + dataWidth-1: dataWidth*29];
    assign Re_Out[dataWidth*24 + dataWidth-1: dataWidth*24] = Re_In[dataWidth*3 + dataWidth-1: dataWidth*3];
    assign Re_Out[dataWidth*25 + dataWidth-1: dataWidth*25] = Re_In[dataWidth*19 + dataWidth-1: dataWidth*19];
    assign Re_Out[dataWidth*26 + dataWidth-1: dataWidth*26] = Re_In[dataWidth*11 + dataWidth-1: dataWidth*11];
    assign Re_Out[dataWidth*27 + dataWidth-1: dataWidth*27] = Re_In[dataWidth*27 + dataWidth-1: dataWidth*27];
    assign Re_Out[dataWidth*28 + dataWidth-1: dataWidth*28] = Re_In[dataWidth*7 + dataWidth-1: dataWidth*7];
    assign Re_Out[dataWidth*29 + dataWidth-1: dataWidth*29] = Re_In[dataWidth*23 + dataWidth-1: dataWidth*23];
    assign Re_Out[dataWidth*30 + dataWidth-1: dataWidth*30] = Re_In[dataWidth*15 + dataWidth-1: dataWidth*15];
    assign Re_Out[dataWidth*31 + dataWidth-1: dataWidth*31] = Re_In[dataWidth*31 + dataWidth-1: dataWidth*31];
    
    assign Im_Out[dataWidth*0 + dataWidth-1: 0] = Im_In[dataWidth*0 + dataWidth-1: 0];
    assign Im_Out[dataWidth*1 + dataWidth-1: dataWidth*1] = Im_In[dataWidth*16 + dataWidth-1: dataWidth*16];
    assign Im_Out[dataWidth*2 + dataWidth-1: dataWidth*2] = Im_In[dataWidth*8 + dataWidth-1: dataWidth*8];
    assign Im_Out[dataWidth*3 + dataWidth-1: dataWidth*3] = Im_In[dataWidth*24 + dataWidth-1: dataWidth*24];
    assign Im_Out[dataWidth*4 + dataWidth-1: dataWidth*4] = Im_In[dataWidth*4 + dataWidth-1: dataWidth*4];
    assign Im_Out[dataWidth*5 + dataWidth-1: dataWidth*5] = Im_In[dataWidth*20 + dataWidth-1: dataWidth*20];
    assign Im_Out[dataWidth*6 + dataWidth-1: dataWidth*6] = Im_In[dataWidth*12 + dataWidth-1: dataWidth*12];
    assign Im_Out[dataWidth*7 + dataWidth-1: dataWidth*7] = Im_In[dataWidth*28 + dataWidth-1: dataWidth*28];
    assign Im_Out[dataWidth*8 + dataWidth-1: dataWidth*8] = Im_In[dataWidth*2 + dataWidth-1: dataWidth*2];
    assign Im_Out[dataWidth*9 + dataWidth-1: dataWidth*9] = Im_In[dataWidth*18 + dataWidth-1: dataWidth*18];
    assign Im_Out[dataWidth*10 + dataWidth-1: dataWidth*10] = Im_In[dataWidth*10 + dataWidth-1: dataWidth*10];
    assign Im_Out[dataWidth*11 + dataWidth-1: dataWidth*11] = Im_In[dataWidth*26 + dataWidth-1: dataWidth*26];
    assign Im_Out[dataWidth*12 + dataWidth-1: dataWidth*12] = Im_In[dataWidth*6 + dataWidth-1: dataWidth*6];
    assign Im_Out[dataWidth*13 + dataWidth-1: dataWidth*13] = Im_In[dataWidth*22 + dataWidth-1: dataWidth*22];
    assign Im_Out[dataWidth*14 + dataWidth-1: dataWidth*14] = Im_In[dataWidth*14 + dataWidth-1: dataWidth*14];
    assign Im_Out[dataWidth*15 + dataWidth-1: dataWidth*15] = Im_In[dataWidth*30 + dataWidth-1: dataWidth*30];
    assign Im_Out[dataWidth*16 + dataWidth-1: dataWidth*16] = Im_In[dataWidth*1 + dataWidth-1: dataWidth*1];
    assign Im_Out[dataWidth*17 + dataWidth-1: dataWidth*17] = Im_In[dataWidth*17 + dataWidth-1: dataWidth*17];
    assign Im_Out[dataWidth*18 + dataWidth-1: dataWidth*18] = Im_In[dataWidth*9 + dataWidth-1: dataWidth*9];
    assign Im_Out[dataWidth*19 + dataWidth-1: dataWidth*19] = Im_In[dataWidth*25 + dataWidth-1: dataWidth*25];
    assign Im_Out[dataWidth*20 + dataWidth-1: dataWidth*20] = Im_In[dataWidth*5 + dataWidth-1: dataWidth*5];
    assign Im_Out[dataWidth*21 + dataWidth-1: dataWidth*21] = Im_In[dataWidth*21 + dataWidth-1: dataWidth*21];
    assign Im_Out[dataWidth*22 + dataWidth-1: dataWidth*22] = Im_In[dataWidth*13 + dataWidth-1: dataWidth*13];
    assign Im_Out[dataWidth*23 + dataWidth-1: dataWidth*23] = Im_In[dataWidth*29 + dataWidth-1: dataWidth*29];
    assign Im_Out[dataWidth*24 + dataWidth-1: dataWidth*24] = Im_In[dataWidth*3 + dataWidth-1: dataWidth*3];
    assign Im_Out[dataWidth*25 + dataWidth-1: dataWidth*25] = Im_In[dataWidth*19 + dataWidth-1: dataWidth*19];
    assign Im_Out[dataWidth*26 + dataWidth-1: dataWidth*26] = Im_In[dataWidth*11 + dataWidth-1: dataWidth*11];
    assign Im_Out[dataWidth*27 + dataWidth-1: dataWidth*27] = Im_In[dataWidth*27 + dataWidth-1: dataWidth*27];
    assign Im_Out[dataWidth*28 + dataWidth-1: dataWidth*28] = Im_In[dataWidth*7 + dataWidth-1: dataWidth*7];
    assign Im_Out[dataWidth*29 + dataWidth-1: dataWidth*29] = Im_In[dataWidth*23 + dataWidth-1: dataWidth*23];
    assign Im_Out[dataWidth*30 + dataWidth-1: dataWidth*30] = Im_In[dataWidth*15 + dataWidth-1: dataWidth*15];
    assign Im_Out[dataWidth*31 + dataWidth-1: dataWidth*31] = Im_In[dataWidth*31 + dataWidth-1: dataWidth*31];

endmodule
