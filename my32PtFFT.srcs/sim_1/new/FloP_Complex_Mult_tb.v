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
    
    /*
    @(negedge clk); //Put a delay here to make this work even in timing-accurate simulations
    //The first test case results should be here
    if (Re_Z != 32'b00111111100000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 1");
        $finish;
    end
    else begin
        $display("Test Case 1 Passed!");
    end
    */
    
    @(posedge clk);
    //(1 + i1) * (1 - i1) = 2 + i0 (i.e. sqrt(2) at 45 * sqrt(2) at -45 = 2 at 0 degrees)
    testNum = 4;
    Re_a <= 32'b00111111100000000000000000000000;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'b00111111100000000000000000000000;
    Im_b <= 32'b10111111100000000000000000000000;
    
    /*
    @(negedge clk);
    //The second test case results should be here
    if (Re_Z != 32'b10111111100000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 2");
        $finish;
    end
    else begin
        $display("Test Case 2 Passed!");
    end
    */
    
    @(posedge clk);
    //(5 + i7) * (2 - i3) = 31 - i1
    testNum = 5;
    Re_a <= 32'b01000000101000000000000000000000;
    Im_a <= 32'b01000000111000000000000000000000;
    Re_b <= 32'b01000000000000000000000000000000;
    Im_b <= 32'b11000000010000000000000000000000;
    
    /*
    @(negedge clk);
    //The third test case results should be here
    if (Re_Z != 32'd0 || Im_Z != 32'b01000000000000000000000000000000) begin
        $display("Simulation failed at test case 3");
        $finish;
    end
    else begin
        $display("Test Case 3 Passed!");
    end
    */
    
    @(posedge clk);
    //(pi - i*e) * (sqrt(2) - i*phi) ~= 0.04461 - 8.9274i
    testNum = 6;
    Re_a <= 32'b01000000010010010000111111011011;
    Im_a <= 32'b11000000001011011111100001010100;
    Re_b <= 32'b00111111101101010000010011110011;
    Im_b <= 32'b10111111110011110001101110111101;
    
    /*
    @(negedge clk);
    //The fourth test case results should be here
    if (Re_Z != 32'b01000000000000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 4");
        $finish;
    end
    else begin
        $display("Test Case 4 Passed!");
    end
    */
    
    @(posedge clk);
    //Filler space
    /*
    @(negedge clk);
    //The fifth test case results should be here
    if (Re_Z != 32'b01000001111110000000000000000000 || Im_Z != 32'b10111111100000000000000000000000) begin
        $display("Simulation failed at test case 5");
        $finish;
    end
    else begin
        $display("Test Case 5 Passed!");
    end
    */
    @(posedge clk);
    //Filler space
    @(negedge clk);
    //The last test case results should be here, but checking them doesn't quite work
    //Because of slight accuracy differences
    $display("Check waveform window to see if Test Case 6 passed");
    @(posedge clk);
    //Finish things up    
    $display("Simulation finished!");
    //$finish;
    
  end
  
  //Non pipelined version of the testbench.
  /*
  initial begin
    
    reset = 1'b1;
    repeat(3)@(posedge clk);
    reset = 1'b0;
    //First, let's just test 1 * 1 = 1
    testNum = 1;
    Re_a = 32'b00111111100000000000000000000000;
    Im_a = 32'd0;
    Re_b = 32'b00111111100000000000000000000000;
    Im_b = 32'd0;
    repeat(3)@(posedge clk);
    if (Re_Z != 32'b00111111100000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 1");
        $finish;
    end
    
    //Next, let's test i * i = sqrt(-1) * sqrt(-1) = -1
    testNum = 2;
    Re_a <= 32'd0;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'd0;
    Im_b <= 32'b00111111100000000000000000000000;
    repeat(3)@(posedge clk);
    if (Re_Z != 32'b10111111100000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 2");
        $finish;
    end
    
    //(1 + i1) * (1 + i1) = 0 + i2 (i.e. sqrt(2) at 45 * sqrt(2) at 45 = 2 at 90 degrees)
    testNum = 3;
    Re_a <= 32'b00111111100000000000000000000000;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'b00111111100000000000000000000000;
    Im_b <= 32'b00111111100000000000000000000000;
    repeat(3)@(posedge clk);
    if (Re_Z != 32'd0 || Im_Z != 32'b01000000000000000000000000000000) begin
        $display("Simulation failed at test case 3");
        $finish;
    end
    
    //(1 + i1) * (1 - i1) = 2 + i0 (i.e. sqrt(2) at 45 * sqrt(2) at -45 = 2 at 0 degrees)
    testNum = 4;
    Re_a <= 32'b00111111100000000000000000000000;
    Im_a <= 32'b00111111100000000000000000000000;
    Re_b <= 32'b00111111100000000000000000000000;
    Im_b <= 32'b10111111100000000000000000000000;
    repeat(3)@(posedge clk);
    if (Re_Z != 32'b01000000000000000000000000000000 || Im_Z != 32'd0) begin
        $display("Simulation failed at test case 4");
        $finish;
    end
    
    //(5 + i7) * (2 - i3) = 31 - i1
    testNum = 5;
    Re_a <= 32'b01000000101000000000000000000000;
    Im_a <= 32'b01000000111000000000000000000000;
    Re_b <= 32'b01000000000000000000000000000000;
    Im_b <= 32'b11000000010000000000000000000000;
    repeat(3)@(posedge clk);
    if (Re_Z != 32'b01000001111110000000000000000000 || Im_Z != 32'b10111111100000000000000000000000) begin
        $display("Simulation failed at test case 5");
        $finish;
    end
    
    //(pi - i*e) * (sqrt(2) - i*phi) ~= 0.04461 - 8.9274i
    testNum = 6;
    Re_a <= 32'b01000000010010010000111111011011;
    Im_a <= 32'b11000000001011011111100001010100;
    Re_b <= 32'b00111111101101010000010011110011;
    Im_b <= 32'b10111111110011110001101110111101;
    repeat(3)@(posedge clk);
    //This "check the answer" scenario doesn't really work due to 
    //subtle differences in rounding, precision, etc.
    //Just look at the numbers and see if they're approximately right.
//    if (Re_Z != 32'b00111101001101101011100110001101 || Im_Z != 32'b11000001000011101101011011000110) begin
//        $display("Simulation failed at test case 6");
//        $finish;
//    end
    
    $display("Simulation finished!");
    $finish;
    
  end
  */
  
endmodule
