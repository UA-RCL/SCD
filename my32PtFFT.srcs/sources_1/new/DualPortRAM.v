`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2016 01:16:02 AM
// Design Name: 
// Module Name: DualPortRAM
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


module DualPortRAM(
    input clk1, 
    input clk2,
    
    input [addrSize-1:0] addr1,
    input [addrSize-1:0] addr2,
    
//    input memEn1,
//    input memEn2,
    
    input writeEn1,
    input writeEn2,
    
    input [wordWidth-1:0] dataIn1,
    input [wordWidth-1:0] dataIn2,
    
    output reg [wordWidth-1:0] dataOut1,
    output reg [wordWidth-1:0] dataOut2
);

    parameter addrSize = 5;
    parameter wordWidth = 32;
    parameter filename = "testFile.txt";

    reg [wordWidth-1:0] myMemory [2**addrSize-1:0];
    integer i;
    
    initial begin
        /*
        for (i = 0; i < 2**addrSize; i = i + 1) begin
            myMemory[i] <= i;
        end
        */
        $readmemh(filename, myMemory);
    end
    
    always @(negedge clk1) begin
//        if (memEn1) begin
            if (writeEn1) begin
                myMemory[addr1] <= dataIn1;
            end
            else begin
                dataOut1 <= myMemory[addr1];
            end
//        end
    end
    
    always @(negedge clk2) begin
//        if (memEn2) begin
            if (writeEn2) begin
                myMemory[addr2] <= dataIn2;
            end
            else begin
                dataOut2 <= myMemory[addr2];
            end
//        end
    end


endmodule
