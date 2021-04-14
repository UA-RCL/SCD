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
    
    integer i;
    
    DualPortRAM #(.wordWidth(wordWidth), .addrSize(addrSize)) 
            myRAM(.clk1(clk), .clk2(clk), 
                  .en1(1'b1), .en2(1'b1),
                  .dataIn1(dataIn1), .dataIn2(dataIn2), 
                  .addr1(addr1), .addr2(addr2), 
                  .writeEn1(writeEn1), .writeEn2(writeEn2), 
                  .dataOut1(dataOut1), .dataOut2(dataOut2));

    always begin
        clk <= 1'b0; #10;
        clk <= 1'b1; #10;
    end

    initial begin
        @(posedge clk) begin
            addr1 <= 6'd0;
            addr2 <= (2**addrSize)-1;
        end
        //Begin by filling the memory with values
        for (i = 0; i < 2**(addrSize-1); i = i + 1) begin
            dataIn1 <= i;
            dataIn2 <= (2**(addrSize)-1)-i;
            writeEn1 <= 1'b1;
            writeEn2 <= 1'b1;
            @(posedge clk) begin
                addr1 <= addr1 + 6'd1;
                addr2 <= addr2 - 6'd1;
            end
        end
        writeEn1 <= 1'b0;
        writeEn2 <= 1'b0;
        //Reset the addresses, but reverse the roles because why not
        @(posedge clk) begin
            addr1 <= (2**addrSize)-1;
            addr2 <= 6'd0;
        end
        //Wait for one clock cycle for the first read to occur
        @(posedge clk);
        //Now read them all back
        for (integer i = 0; i < 2**(addrSize-1); i = i + 1) begin
            //Verify output on the negative edge of the clock once it's had time to settle
            @(negedge clk) begin
                if (dataOut1 != (2**(addrSize)-1)-i) begin
                    $error("dataOut1 failed on iteration i = %d", i);
                    $finish;
                end
                if (dataOut2 != i) begin
                    $error("dataOut2 failed on iteration i = %d", i);
                    $finish;
                end
            end
            //Change the address
            @(posedge clk) begin
                addr1 <= addr1 - 6'd1;
                addr2 <= addr2 + 6'd1;
            end
            //Wait for the value to show up at read output
            @(posedge clk);
        end        
        $finish;
    end

endmodule
