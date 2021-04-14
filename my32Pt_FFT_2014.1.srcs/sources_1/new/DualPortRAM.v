`timescale 1ns / 1ps

module DualPortRAM
#(
    parameter addrSize = 9,
    parameter wordWidth = 256
)
(
    input clk1, 
    input clk2,
    
    input [addrSize-1:0] addr1,
    input [addrSize-1:0] addr2,
    
    input en1,
    input en2,
    
    input writeEn1,
    input writeEn2,
    
    input [wordWidth-1:0] dataIn1,
    input [wordWidth-1:0] dataIn2,
    
    output [wordWidth-1:0] dataOut1,
    output [wordWidth-1:0] dataOut2
);

//    parameter filename = "";
    reg [wordWidth-1:0] myMemory [2**addrSize-1:0];
    reg [wordWidth-1:0] Rd1, Rd2;
    integer i;
    
    initial begin
        for (i = 0; i < 2**addrSize; i = i + 1) begin
            myMemory[i] <= {{wordWidth}{1'b0}};
        end
//        if (filename != "") begin
//            $readmemh(filename, myMemory);
//        end
    end
    
    always @(posedge clk1) begin
        if (en1 == 1'b1) begin
            Rd1 <= myMemory[addr1];
            if (writeEn1 == 1'b1) begin
                myMemory[addr1] <= dataIn1;
            end
        end
    end
    
    always @(posedge clk2) begin
        if (en2 == 1'b1) begin
            Rd2 <= myMemory[addr2];
            if (writeEn2 == 1'b1) begin
                myMemory[addr2] <= dataIn2;
            end
        end
    end
    
    assign dataOut1 = Rd1;
    assign dataOut2 = Rd2;

endmodule
