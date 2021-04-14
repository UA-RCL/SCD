`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2016 05:43:14 PM
// Design Name: 
// Module Name: FFT_8_Pt_tb
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


module FFT_8_Pt_tb(
);

    parameter FFTPoints = 8;
    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth+sigWidth+1;

    reg [FFTPoints*dataWidth-1:0] Re_x, Im_x;
    reg [FFTPoints*dataWidth/2-1:0] Re_w, Im_w;
    reg clk, reset;
    wire [FFTPoints*dataWidth-1:0] Re_Out, Im_Out;
    
    wire [dataWidth-1:0] Re_Out0, Re_Out1, Re_Out2, Re_Out3, Re_Out4, Re_Out5, Re_Out6, Re_Out7;
    wire [dataWidth-1:0] Im_Out0, Im_Out1, Im_Out2, Im_Out3, Im_Out4, Im_Out5, Im_Out6, Im_Out7;

FFT_8_Pt_TOP #(.FFTPoints(8), .expWidth(8), .sigWidth(23)) myFFT
    (.clk(clk), .reset(reset), .Re_x(Re_x), .Im_x(Im_x), .Re_w(Re_w), .Im_w(Im_w),
    .Re_Out(Re_Out), .Im_Out(Im_Out));
    
    always begin
        clk <= 1'b0; #10;
        clk <= 1'b1; #10;
    end
    
    initial begin
        //Re_w = Re([W_8^7, W_8^6, W_8^5, W_8^4, W_8^3, W_8^2, W_8^1, 1])
        //Re_w = 256'b0011111100110101000001001111001110100101010100111100100111001010101111110011010100000100111100111011111110000000000000000000000010111111001101010000010011110011001001001000110100110001001100100011111100110101000001001111001100111111100000000000000000000000;
        //Im_w = Im([W_8^7, W_8^6, W_8^5, W_8^4, W_8^3, W_8^2, W_8^1, 1])
        //Im_w = 256'b0011111100110101000001001111001100111111100000000000000000000000001111110011010100000100111100111010010100001101001100010011001010111111001101010000010011110011101111111000000000000000000000001011111100110101000001001111001100000000000000000000000000000000;
        Re_w = 128'hbf3504f3248d31323f3504f33f800000;
        Im_w = 128'hbf3504f3bf800000bf3504f300000000;
        reset <= 1'b0;
        
        //Re_x = [1, 1, 1, 1, 1, 1, 1, 1] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h3F8000003F8000003F8000003F8000003F8000003F8000003F8000003F800000;
        //Im_x = [1, 1, 1, 1, 1, 1, 1, 1]
        Im_x <= 256'h3F8000003F8000003F8000003F8000003F8000003F8000003F8000003F800000;
        //Expected = [8+j8, 0, 0, 0, 0, 0, 0, 0] = [x0 x1 x2 x3 x4 x5 x6 x7]
        //repeat (20) @(posedge clk);
        @(posedge clk);
        
        //Re_x = [1, 0, 0, 0, 0, 0, 0, 0] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h3F80000000000000000000000000000000000000000000000000000000000000;
        //Im_x = [1, 0, 0, 0, 0, 0, 0, 0]
        Im_x <= 256'h3F80000000000000000000000000000000000000000000000000000000000000;
        //Expected = [x0 x1 x2 x3 x4 x5 x6 x7] = [1.0000 + 1.0000i   0.0000 + 1.4142i  -1.0000 + 1.0000i  -1.4142 + 0.0000i  -1.0000 - 1.0000i   0.0000 - 1.4142i   1.0000 - 1.0000i   1.4142 + 0.0000i] 
        //repeat (20) @(posedge clk);
        @(posedge clk);
        
        //Re_x = [0, 0, 0, 0, 0, 0, 0, 1] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h000000000000000000000000000000000000000000000000000000003F800000;
        //Im_x = [0, 0, 0, 0, 0, 0, 0, 0]
        Im_x <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        //Expected = [1, 1, 1, 1, 1, 1, 1, 1] = [x0 x1 x2 x3 x4 x5 x6 x7]
        //repeat (20) @(posedge clk);
        @(posedge clk);
        
        //Re_x = [0, 0, 0, 0, 0, 0, 0, 0] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
        //Im_x = [0, 0, 0, 0, 0, 0, 0, 1]
        Im_x <= 256'h000000000000000000000000000000000000000000000000000000003F800000;
        //Expected = [j, j, j, j, j, j, j, j] = [x0 x1 x2 x3 x4 x5 x6 x7]
        //repeat (20) @(posedge clk);
        @(posedge clk);
        
        //Re_x = [0, 0, 0, 0, 0, 0, 0, 1] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h000000000000000000000000000000000000000000000000000000003F800000;
        //Im_x = [0, 0, 0, 0, 0, 0, 0, 1]
        Im_x <= 256'h000000000000000000000000000000000000000000000000000000003F800000;
        //Expected = [1+j, 1+j, 1+j, 1+j, 1+j, 1+j, 1+j, 1+j] = [x0 x1 x2 x3 x4 x5 x6 x7]
        @(posedge clk);
        
        //Re_x = [1, 2, 3, 4, 3, 2, 1, 0] = [x7 x6 x5 x4 x3 x2 x1 x0]
        Re_x <= 256'h3f80000040000000404000004080000040400000400000003f80000000000000;
        //Im_x = [55, 12, -1, -10, 212, -100, 2, 1]
        Im_x <= 256'h425c000041400000bf800000c120000043540000c2c80000400000003f800000;
        //Expected = [16+j171, -5.691-j97.894, -266+j79, 223.966+j119.894, 0-j365, -226.309+j119.894, 266+j79, -7.966-j97.894] = [x0 x1 x2 x3 x4 x5 x6 x7]
        @(posedge clk);
    end
    
    assign Re_Out0 = Re_Out[dataWidth-1:0];
    assign Re_Out1 = Re_Out[2*dataWidth-1:dataWidth];
    assign Re_Out2 = Re_Out[3*dataWidth-1:2*dataWidth];
    assign Re_Out3 = Re_Out[4*dataWidth-1:3*dataWidth];
    assign Re_Out4 = Re_Out[5*dataWidth-1:4*dataWidth];
    assign Re_Out5 = Re_Out[6*dataWidth-1:5*dataWidth];
    assign Re_Out6 = Re_Out[7*dataWidth-1:6*dataWidth];
    assign Re_Out7 = Re_Out[8*dataWidth-1:7*dataWidth];
    
    assign Im_Out0 = Im_Out[dataWidth-1:0];
    assign Im_Out1 = Im_Out[2*dataWidth-1:dataWidth];
    assign Im_Out2 = Im_Out[3*dataWidth-1:2*dataWidth];
    assign Im_Out3 = Im_Out[4*dataWidth-1:3*dataWidth];
    assign Im_Out4 = Im_Out[5*dataWidth-1:4*dataWidth];
    assign Im_Out5 = Im_Out[6*dataWidth-1:5*dataWidth];
    assign Im_Out6 = Im_Out[7*dataWidth-1:6*dataWidth];
    assign Im_Out7 = Im_Out[8*dataWidth-1:7*dataWidth];

endmodule
