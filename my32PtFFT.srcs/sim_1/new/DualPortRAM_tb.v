`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2016 04:07:29 PM
// Design Name: 
// Module Name: DualPortRAM_tb
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


module DualPortRAM_tb();

    parameter wordWidth = 32;
    parameter addrSize = 6;

    reg [wordWidth-1:0] dataIn1, dataIn2;
    reg [addrSize-1:0] addr1, addr2;
    reg clk, writeEn1, writeEn2;
    
    wire [wordWidth-1:0] dataOut1, dataOut2;
    
    DualPortRAM #(.wordWidth(wordWidth), .addrSize(addrSize)) 
            myRAM(.clk1(clk), .clk2(clk), .dataIn1(dataIn1), .dataIn2(dataIn2), .addr1(addr1), .addr2(addr2), .writeEn1(writeEn1), .writeEn2(writeEn2), .dataOut1(dataOut1), .dataOut2(dataOut2));

    always begin
        clk <= 1'b0; #10;
        clk <= 1'b1; #10;
    end

    initial begin
        dataIn1 <= 32'd0;
        dataIn2 <= 32'd0;
        addr1 <= 6'd0;
        addr2 <= 6'd1;
        writeEn1 <= 1'b0;
        writeEn2 <= 1'b0;
        repeat(2)@(posedge clk);
        //Attempt to read from every location
        for (integer i = 0; i < 2**addrSize; i = i + 1) begin
            addr1 <= i;
            addr2 <= 2**addrSize-i-1;
            @(posedge clk);
        end
        //Then, write to every location
        writeEn1 <= 1'b1;
        writeEn2 <= 1'b1;
        for (integer i = 0; i < 2**addrSize; i = i + 1) begin
            addr1 <= i;
            addr2 <= 2**addrSize-i-1;
            dataIn1 <= 2**addrSize-i-1;
            dataIn2 <= i;
            @(posedge clk);
        end
        //Disable writing again
        writeEn1 <= 1'b0;
        writeEn2 <= 1'b0;
        //And then reread off all of the values, they should be switched
        for (integer i = 0; i < 2**addrSize; i = i + 1) begin
            addr1 <= i;
            addr2 <= 2**addrSize-1-i;
            @(posedge clk);
        end
        repeat(5)@(posedge clk);        
        $finish;
    end

endmodule
