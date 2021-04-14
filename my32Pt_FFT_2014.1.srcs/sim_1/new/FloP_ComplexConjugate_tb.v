`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2016 05:39:43 PM
// Design Name: 
// Module Name: FloP_ComplexConjugate_tb
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


module FloP_ComplexConjugate_tb();

parameter dataWidth = 32;
parameter numElements = 3;

reg [numElements*dataWidth-1:0] inputData;
wire [numElements*dataWidth-1:0] outputData;
wire [dataWidth-1:0] data1, data2, data3;

FloP_ComplexConjugate #(.dataWidth(32), .numElements(3)) myConj(
    .dataIn(inputData), .dataOut(outputData)
);

assign data3 = outputData[dataWidth-1:0];
assign data2 = outputData[2*dataWidth-1:dataWidth];
assign data1 = outputData[3*dataWidth-1:2*dataWidth];

initial begin
    inputData <= 96'd0;
    #10;
    //Input data <= {1, 0, -1}
    inputData <= {32'b00111111100000000000000000000000, 32'b00000000000000000000000000000000, 32'b10111111100000000000000000000000};
    #10;
    //Input data <= {-1, -2, -3}
    inputData <= {32'b10111111100000000000000000000000, 32'b11000000000000000000000000000000, 32'b11000000010000000000000000000000};
    #10;
    //Input data <= {2, 3, 10}
    inputData <= {32'b01000000000000000000000000000000, 32'b01000000010000000000000000000000, 32'b01000001001000000000000000000000};
    #10;
end

endmodule
