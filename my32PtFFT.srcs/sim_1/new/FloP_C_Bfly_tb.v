`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2016 08:23:24 PM
// Design Name: 
// Module Name: FloP_C_Bfly_tb
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


module FloP_C_Bfly_tb(
);

    parameter expWidth = 8;
    parameter sigWidth = 23;
    parameter dataWidth = expWidth + sigWidth + 1;
    
    reg [dataWidth-1:0] Re_a, Re_b, Re_w, Im_a, Im_b, Im_w;
    reg clk, reset;
    
    wire [dataWidth-1:0] Re_Y, Re_Z, Im_Y, Im_Z;
    
    FloP_C_Bfly #(.exp_width(expWidth), .sig_width(sigWidth)) myBfly(
        .Re_a(Re_a), .Re_b(Re_b), .Re_w(Re_w), .Im_a(Im_a), .Im_b(Im_b), .Im_w(Im_w),
        .clk(clk), .reset(reset),
        .Re_Y(Re_Y), .Re_Z(Re_Z), .Im_Y(Im_Y), .Im_Z(Im_Z)
    );
    // BFLY(A, B, W^K) = {A + B*W^K, A - B*W^K}
    
    always begin
        clk <= 1'b0; #10;
        clk <= 1'b1; #10;
    end
    
    initial begin
        reset <= 1'b1;
        Re_a <= {dataWidth{1'b0}};
        Re_b <= {dataWidth{1'b0}};
        Re_w <= {dataWidth{1'b0}};
        Im_a <= {dataWidth{1'b0}};
        Im_b <= {dataWidth{1'b0}};
        Im_w <= {dataWidth{1'b0}};
        @(posedge clk);
        reset <= 1'b0;
    
    /*    
        //Let's just pass in some kind of number then to test it.
        //BFLY(1, 1, 2) = {1 + 1*2, 1 - 1*2} = {3, -1}
        Re_a <= 32'b00111111100000000000000000000000;
        Re_b <= 32'b00111111100000000000000000000000;
        Im_a <= 32'd0;
        Im_b <= 32'd0;
        Re_w <= 32'b01000000000000000000000000000000;
        Im_w <= 32'd0;
        //Delay 3 cycles to allow for processing through the pipeline
        repeat(3) @(posedge clk);
        if (Re_Y != 32'b01000000010000000000000000000000 || Im_Y != 32'd0) 
            $display("Test Case 1 Failed for Y");
        else
            $display("Test Case 1 Passed for Y!");
        if (Re_Z != 32'b10111111100000000000000000000000 || Im_Z != 32'd0)
            $display("Test Case 1 Failed for Z");
        else
            $display("Test Case 1 Passed for Z!");
        
        //Okay, now let's try it with something imaginary.
        //BFLY(i, i, 2*i) = {i + i*2*i, i - i*2*i} = {-2 + i, 2 + i}
        Re_a <= 32'd0;
        Re_b <= 32'd0;
        Im_a <= 32'b00111111100000000000000000000000;
        Im_b <= 32'b00111111100000000000000000000000;
        Re_w <= 32'd0;
        Im_w <= 32'b01000000000000000000000000000000;
        repeat(3) @(posedge clk);
        if (Re_Y != 32'b11000000000000000000000000000000 || Im_Y != 32'b00111111100000000000000000000000)
            $display("Test Case 2 Failed for Y");
        else
            $display("Test Case 2 Passed for Y!");
        if (Re_Z != 32'b01000000000000000000000000000000 || Im_Z != 32'b00111111100000000000000000000000)
            $display("Test Case 2 Failed for Z");
        else
            $display("Test Case 2 Passed for Z!");
        
        //Okay, now let's try it with full complex numbers and an actual root of unity
        //BFLY(2 - 3*i, 8 + 2*i, exp(-1i*2*pi*4/32)) 
        //  = {(2-3*i) + (8+2*i)*exp(1i*2*pi*4/32), (2-3*i) - (8+2*i)*exp(1i*2*pi*4/32)}
        //  = {9.07106781186548 - 7.24264049530029i, -5.07106781005859 + 1.24264073371887i}
        Re_a <= 32'b01000000000000000000000000000000;
        Re_b <= 32'b01000001000000000000000000000000;
        Im_a <= 32'b11000000010000000000000000000000;
        Im_b <= 32'b01000000000000000000000000000000;
        Re_w <= 32'b00111111001101010000010011110011;
        Im_w <= 32'b10111111001101010000010011110011;
        repeat(3) @(posedge clk);
        $display("Check that Test Case 3 Passed");
        $display("Expected Re_Y: 9.07106781186548");
        $display("Expected Im_Y: -7.24264049530029");
        $display("Expected Re_Z: -5.07106781005859");
        $display("Expected Im_Z: 1.24264073371887");
        
        
        Re_a <= 32'b00111111100000000000000000000000;
        Re_b <= 32'b00000000000000000000000000000000;
        Im_a <= 32'b00111111100000000000000000000000;
        Im_b <= 32'b00000000000000000000000000000000;
        Re_w <= 32'b00000000000000000000000000000000;
        Im_w <= 32'b00000000000000000000000000000000;
        repeat(3) @(posedge clk);
        if (Re_Y != 32'b00111111100000000000000000000000 || Im_Y != 32'b00111111100000000000000000000000)
            $display("Test Case 4 Failed for Y");
        else
            $display("Test Case 4 Passed for Y!");
        if (Re_Z != 32'b00111111100000000000000000000000 || Im_Z != 32'b00111111100000000000000000000000)
            $display("Test Case 4 Failed for Z");
        else
            $display("Test Case 4 Passed for Z!");

        @(posedge clk);
        $finish;
    */
        
        // 1+j1 BFLY 3-j7 with W_N = exp(-j*2*pi*3/8)
        Re_w <= 32'hbf3504f3;
        Im_w <= 32'hbf3504f3;
        Re_a <= 32'h3f800000;
        Im_a <= 32'h3f800000;
        Re_b <= 32'h40400000;
        Im_b <= 32'hc0e00000;
        repeat(3) @(posedge clk);
    
    end

endmodule
