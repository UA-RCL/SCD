`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2016 09:43:44 PM
// Design Name: 
// Module Name: bitReversal_tb
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


module bitReversal_tb();

    reg [63:0] aValue;
    wire [63:0] anOutput;
    
    bitReversal #(.dataWidth(64)) reverser(.dataIn(aValue), .dataOut(anOutput));
    
    initial begin
        aValue = 64'd0;
        #100;
        aValue = 64'h00000000ffffffff;
        #100;
        if (anOutput != 64'hffffffff00000000) 
            $display("Failed test 1");
        else
            $display("Passed test 1");
        #100;
        aValue = 64'hffffffff00000000;
        #100;
        if (anOutput != 64'h00000000ffffffff)
            $display("Failed test 2");
        else
            $display("Passed test 2");
    end

endmodule
