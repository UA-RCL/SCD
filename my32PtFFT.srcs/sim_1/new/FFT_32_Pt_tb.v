`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2016 07:15:00 PM
// Design Name: 
// Module Name: FFT_32_Pt_tb
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


module FFT_32_Pt_tb();

    parameter FFTPoints = 32;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;
    
    reg [dataWidth*FFTPoints-1:0] Re_X, Im_X;
    reg clk, reset;

    wire [dataWidth*FFTPoints-1:0] Re_Out, Im_Out;
    
    wire [dataWidth-1:0] Re_Out0, Re_Out1, Re_Out2, Re_Out3, Re_Out4, Re_Out5, Re_Out6, Re_Out7,
                         Re_Out8, Re_Out9, Re_Out10, Re_Out11, Re_Out12, Re_Out13, Re_Out14, Re_Out15,
                         Re_Out16, Re_Out17, Re_Out18, Re_Out19, Re_Out20, Re_Out21, Re_Out22, Re_Out23,
                         Re_Out24, Re_Out25, Re_Out26, Re_Out27, Re_Out28, Re_Out29, Re_Out30, Re_Out31;
                         
    wire [dataWidth-1:0] Im_Out0, Im_Out1, Im_Out2, Im_Out3, Im_Out4, Im_Out5, Im_Out6, Im_Out7,
                         Im_Out8, Im_Out9, Im_Out10, Im_Out11, Im_Out12, Im_Out13, Im_Out14, Im_Out15,
                         Im_Out16, Im_Out17, Im_Out18, Im_Out19, Im_Out20, Im_Out21, Im_Out22, Im_Out23,
                         Im_Out24, Im_Out25, Im_Out26, Im_Out27, Im_Out28, Im_Out29, Im_Out30, Im_Out31;
    
    wire done;
    
    /*
    FFT_32_Pt_Datapath myFFT(.Re_x(Re_X), .Im_x(Im_X), .Re_Out(Re_Out), .Im_Out(Im_Out),
                    .clk(clk), .reset(reset), .done(done));
    */
    FFT_32_Pt_TopControllerWithRAM myFFT(.clk(clk), .reset(reset));
    
    always begin
        clk <= 1'b0; #10;
        clk <= 1'b1; #10;
    end
    
    initial begin
        //Re_w = [W_N^(N/2-1), W_N^(N/2-2), ..., W_N^3, W_N^2, W_N^1, W_N^0]
        /*
        Re_w <= 512'hbf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c2248d31323e47c5c23ec3ef153f0e39da3f3504f33f54db313f6c835e3f7b14be3f800000;
        Im_w <= 512'hbe47c5c2bec3ef15bf0e39dabf3504f3bf54db31bf6c835ebf7b14bebf800000bf7b14bebf6c835ebf54db31bf3504f3bf0e39dabec3ef15be47c5c200000000;
        */
        
        reset <= 1'b1;
        @(posedge clk);
        reset <= 1'b0;
        
        //X[n] = array of elements of 1's
        Re_X <= {FFTPoints{32'b00111111100000000000000000000000}};
        Im_X <= {FFTPoints{32'd0}};
        //The expected transform is a delta function

        //repeat(20)@(posedge clk);
        @(posedge clk);
        
        //X[n] = array of all j's
        Re_X <= {FFTPoints{32'd0}};
        Im_X <= {FFTPoints{32'b00111111100000000000000000000000}};
        //The expected transform is an imaginary delta function        
        
        //repeat(20)@(posedge clk);
        @(posedge clk);
        
        //X[n] = array of all 1+j1's
        Re_X <= {FFTPoints{32'b00111111100000000000000000000000}};
        Im_X <= {FFTPoints{32'b00111111100000000000000000000000}};
        //The expected transform is a real delta function + an imaginary delta function
        
        //repeat(20)@(posedge clk);
        @(posedge clk);
        
        //X[0] = 1
        Re_X <= 1024'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111100000000000000000000000;
        Im_X <= 1024'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        //The expected transform is all 1s in the real component, 0s in the imaginary component
        
        //repeat(20)@(posedge clk);
        @(posedge clk);        
        
        //X[n] is an array of elements of e^(2*pi*j*5*t) with t = linspace(0, 2*pi, 32);
        Re_X <= 1024'hbf5d1ad8bf517485bf44515cbf35c93dbf25f697bf14f62ebf02e6ecbedfd34cbeb841c9be8f613fbe4af806bdeb7901bcfd57453d5a810f3e0c881d3e6170713e9a5f6f3ec2edf53eea1a0e3f07ce3f3f19988a3f2a4b8f3f39c8f03f47f4843f54b4863f5ff1c93f6997db3f7195333f77db4a3f7c5eb63f7f17443f800000;
        Im_X <= 1024'h3f0107953f1330543f244d723f343fd33f42ea773f5032b43f5c00623f663e0c3f6ed9133f75c1d13f7aebb73f7e4d603f7fe0a73f7fa2af3f7d93e83f79b80f3f74162a3f6cb8763f63ac573f5902413f4ccd983f3f248d3f301ff73f1fdb243f0e73a83ef812533ed17a473ea9655a3e801c6c3e2bd51c3dac71e200000000;
        
        //repeat(20)@(posedge clk);
        @(posedge clk);
        
        //X[n] is a random array of 32 complex numbers of the form 100*rand() + 1j*100*rand() generated in MATLAB
        //Saved the array to randomArray_1.m
        Re_X <= 1024'h427a2476423dfeb3420297c24181808b428f3ae741d55d04418643234297a785423f04bf4297933040d18406407df3e142c2a68941f89f1941579a6e4235e4fc423eb9d74021a16942932fc4419f47f642b3856c42882f1f4296f7cf421ffb79409e7c2642931548420d916d419961fe4088f0d24212376f42602eba41f1e697;
        Im_X <= 1024'h4035c127424623494226fe854021a459424fac4442258c4541c3d8a542a78ec941e670864292bea342c5f70f429b951e42260d1242719a1c4191cbc24202021d4092290c410d82c242a097bc42b7884d4269783342a6f5df4267460d4088641b41f2a48541f424f7425f2dfc426b568f42a026ca41c42ab14279b301423d06f0;
        
        //repeat(20)@(posedge clk);
        @(posedge clk);
        
//        $finish;
    end
    
    assign Re_Out0 = Re_Out[dataWidth-1:0];
    assign Re_Out1 = Re_Out[1*dataWidth+dataWidth-1:1*dataWidth];
    assign Re_Out2 = Re_Out[2*dataWidth+dataWidth-1:2*dataWidth];
    assign Re_Out3 = Re_Out[3*dataWidth+dataWidth-1:3*dataWidth];
    assign Re_Out4 = Re_Out[4*dataWidth+dataWidth-1:4*dataWidth];
    assign Re_Out5 = Re_Out[5*dataWidth+dataWidth-1:5*dataWidth];
    assign Re_Out6 = Re_Out[6*dataWidth+dataWidth-1:6*dataWidth];
    assign Re_Out7 = Re_Out[7*dataWidth+dataWidth-1:7*dataWidth];
    assign Re_Out8 = Re_Out[8*dataWidth+dataWidth-1:8*dataWidth];
    assign Re_Out9 = Re_Out[9*dataWidth+dataWidth-1:9*dataWidth];
    assign Re_Out10 = Re_Out[10*dataWidth+dataWidth-1:10*dataWidth];
    assign Re_Out11 = Re_Out[11*dataWidth+dataWidth-1:11*dataWidth];
    assign Re_Out12 = Re_Out[12*dataWidth+dataWidth-1:12*dataWidth];
    assign Re_Out13 = Re_Out[13*dataWidth+dataWidth-1:13*dataWidth];
    assign Re_Out14 = Re_Out[14*dataWidth+dataWidth-1:14*dataWidth];
    assign Re_Out15 = Re_Out[15*dataWidth+dataWidth-1:15*dataWidth];
    assign Re_Out16 = Re_Out[16*dataWidth+dataWidth-1:16*dataWidth];
    assign Re_Out17 = Re_Out[17*dataWidth+dataWidth-1:17*dataWidth];
    assign Re_Out18 = Re_Out[18*dataWidth+dataWidth-1:18*dataWidth];
    assign Re_Out19 = Re_Out[19*dataWidth+dataWidth-1:19*dataWidth];
    assign Re_Out20 = Re_Out[20*dataWidth+dataWidth-1:20*dataWidth];
    assign Re_Out21 = Re_Out[21*dataWidth+dataWidth-1:21*dataWidth];
    assign Re_Out22 = Re_Out[22*dataWidth+dataWidth-1:22*dataWidth];
    assign Re_Out23 = Re_Out[23*dataWidth+dataWidth-1:23*dataWidth];
    assign Re_Out24 = Re_Out[24*dataWidth+dataWidth-1:24*dataWidth];
    assign Re_Out25 = Re_Out[25*dataWidth+dataWidth-1:25*dataWidth];
    assign Re_Out26 = Re_Out[26*dataWidth+dataWidth-1:26*dataWidth];
    assign Re_Out27 = Re_Out[27*dataWidth+dataWidth-1:27*dataWidth];
    assign Re_Out28 = Re_Out[28*dataWidth+dataWidth-1:28*dataWidth];
    assign Re_Out29 = Re_Out[29*dataWidth+dataWidth-1:29*dataWidth];
    assign Re_Out30 = Re_Out[30*dataWidth+dataWidth-1:30*dataWidth];
    assign Re_Out31 = Re_Out[31*dataWidth+dataWidth-1:31*dataWidth];
    
    assign Im_Out0 = Im_Out[dataWidth-1:0];
    assign Im_Out1 = Im_Out[1*dataWidth+dataWidth-1:1*dataWidth];
    assign Im_Out2 = Im_Out[2*dataWidth+dataWidth-1:2*dataWidth];
    assign Im_Out3 = Im_Out[3*dataWidth+dataWidth-1:3*dataWidth];
    assign Im_Out4 = Im_Out[4*dataWidth+dataWidth-1:4*dataWidth];
    assign Im_Out5 = Im_Out[5*dataWidth+dataWidth-1:5*dataWidth];
    assign Im_Out6 = Im_Out[6*dataWidth+dataWidth-1:6*dataWidth];
    assign Im_Out7 = Im_Out[7*dataWidth+dataWidth-1:7*dataWidth];
    assign Im_Out8 = Im_Out[8*dataWidth+dataWidth-1:8*dataWidth];
    assign Im_Out9 = Im_Out[9*dataWidth+dataWidth-1:9*dataWidth];
    assign Im_Out10 = Im_Out[10*dataWidth+dataWidth-1:10*dataWidth];
    assign Im_Out11 = Im_Out[11*dataWidth+dataWidth-1:11*dataWidth];
    assign Im_Out12 = Im_Out[12*dataWidth+dataWidth-1:12*dataWidth];
    assign Im_Out13 = Im_Out[13*dataWidth+dataWidth-1:13*dataWidth];
    assign Im_Out14 = Im_Out[14*dataWidth+dataWidth-1:14*dataWidth];
    assign Im_Out15 = Im_Out[15*dataWidth+dataWidth-1:15*dataWidth];
    assign Im_Out16 = Im_Out[16*dataWidth+dataWidth-1:16*dataWidth];
    assign Im_Out17 = Im_Out[17*dataWidth+dataWidth-1:17*dataWidth];
    assign Im_Out18 = Im_Out[18*dataWidth+dataWidth-1:18*dataWidth];
    assign Im_Out19 = Im_Out[19*dataWidth+dataWidth-1:19*dataWidth];
    assign Im_Out20 = Im_Out[20*dataWidth+dataWidth-1:20*dataWidth];
    assign Im_Out21 = Im_Out[21*dataWidth+dataWidth-1:21*dataWidth];
    assign Im_Out22 = Im_Out[22*dataWidth+dataWidth-1:22*dataWidth];
    assign Im_Out23 = Im_Out[23*dataWidth+dataWidth-1:23*dataWidth];
    assign Im_Out24 = Im_Out[24*dataWidth+dataWidth-1:24*dataWidth];
    assign Im_Out25 = Im_Out[25*dataWidth+dataWidth-1:25*dataWidth];
    assign Im_Out26 = Im_Out[26*dataWidth+dataWidth-1:26*dataWidth];
    assign Im_Out27 = Im_Out[27*dataWidth+dataWidth-1:27*dataWidth];
    assign Im_Out28 = Im_Out[28*dataWidth+dataWidth-1:28*dataWidth];
    assign Im_Out29 = Im_Out[29*dataWidth+dataWidth-1:29*dataWidth];
    assign Im_Out30 = Im_Out[30*dataWidth+dataWidth-1:30*dataWidth];
    assign Im_Out31 = Im_Out[31*dataWidth+dataWidth-1:31*dataWidth];

endmodule
