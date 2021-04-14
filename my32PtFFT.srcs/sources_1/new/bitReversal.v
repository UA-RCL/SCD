`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2016 09:41:51 PM
// Design Name: 
// Module Name: bitReversal
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


module bitReversal(
    input [dataWidth-1:0] dataIn,
    output reg [dataWidth-1:0] dataOut
);

    parameter dataWidth = 32;
    integer i;
    
    always @(dataIn) begin
        for (i = 0; i < dataWidth; i = i + 1) begin
            dataOut[i] = dataIn[dataWidth-i-1];
        end
    end

endmodule
