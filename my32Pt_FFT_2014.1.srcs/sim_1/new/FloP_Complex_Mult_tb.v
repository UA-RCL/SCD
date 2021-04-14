`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2016 06:54:00 PM
// Design Name: 
// Module Name: FloP_Complex_Mult_tb
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


module FloP_Complex_Mult_tb();

  parameter sig_width = 23;      // RANGE 2 TO 253
  parameter exp_width = 8;       // RANGE 3 TO 31
  parameter ieee_compliance = 0; // RANGE 0 TO 1
  
  reg [exp_width+sig_width:0] Re_a, Re_b, Im_a, Im_b;
  reg clk, reset;
  
  wire [exp_width+sig_width:0] Re_Z, Im_Z;
  
  integer testNum = 0;
  integer clockCycles = 0;
  
  FloP_Complex_Mult #(.sig_width(sig_width), .exp_width(exp_width), .ieee_compliance(ieee_compliance))
        myMult(.clk(clk), .reset(reset), .Re_a(Re_a), .Re_b(Re_b), .Im_a(Im_a), .Im_b(Im_b), .Re_Z(Re_Z), .Im_Z(Im_Z));
  
  always begin
    clk <= 1; #10;
    clk <= 0; clockCycles = clockCycles + 1; #10;
  end
  
  initial begin
    Re_a = 32'd0;
    Re_b = 32'd0;
    Im_a = 32'd0;
    Im_b = 32'd0;
    reset = 1'b1;
    
    repeat(3)@(posedge clk);
    reset = 1'b0;
    
    //First, let's just test 1 * 1 = 1
    testNum = 1;
    Re_a = 32'b00111111100000000000000000000000;
    Im_a = 32'd0;
    Re_b = 32'b00111111100000000000000000000000;
    Im_b = 32'd0;
    
    @(posedge clk);
    //Next, let's test i * i = sqrt(-1) * sqrt(-1) = -1
    testNum = 2;
    Re_a <= 32'd0;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'd0;
    Im_b <= 32'b00111111100000000000000000000000;
    
    @(posedge clk);
    //(1 + i1) * (1 + i1) = 0 + i2 (i.e. sqrt(2) at 45 * sqrt(2) at 45 = 2 at 90 degrees)
    testNum = 3;
    Re_a <= 32'b00111111100000000000000000000000;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'b00111111100000000000000000000000;
    Im_b <= 32'b00111111100000000000000000000000;
    
    @(posedge clk);
    //(1 + i1) * (1 - i1) = 2 + i0 (i.e. sqrt(2) at 45 * sqrt(2) at -45 = 2 at 0 degrees)
    testNum = 4;
    Re_a <= 32'b00111111100000000000000000000000;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'b00111111100000000000000000000000;
    Im_b <= 32'b10111111100000000000000000000000;
    
    @(posedge clk);
    //(5 + i7) * (2 - i3) = 31 - i1
    testNum = 5;
    Re_a <= 32'b01000000101000000000000000000000;
    Im_a <= 32'b01000000111000000000000000000000;
    Re_b <= 32'b01000000000000000000000000000000;
    Im_b <= 32'b11000000010000000000000000000000;
    
    @(posedge clk);
    //(pi - i*e) * (sqrt(2) - i*phi) ~= 0.04461 - 8.9274i
    testNum = 6;
    Re_a <= 32'b01000000010010010000111111011011;
    Im_a <= 32'b11000000001011011111100001010100;
    Re_b <= 32'b00111111101101010000010011110011;
    Im_b <= 32'b10111111110011110001101110111101;
    
    repeat(10)@(posedge clk);
    //Finish things up    
    $display("Simulation finished!");
    //$finish;
    
  end
  
endmodule
