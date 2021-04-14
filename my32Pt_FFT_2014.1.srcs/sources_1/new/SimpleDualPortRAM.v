`timescale 1ns / 1ps

//Simple Dual Port RAM = Only two ports (one read and one write), *but* the read and write operations can occur independently of each other, at different addresses, etc
//This is opposed to the True Dual Port RAM where you have essentially two independent sets of ports, but the reads and writes need to be coordinated/at the same address
//Port 1: The port that supports writing, Port 2: The port that supports reading
module SimpleDualPortRAM
#(
    parameter addrSize = 9,
    parameter wordWidth = 256
)
(
    input clk,
    input en1, en2, we1,
    input [addrSize-1:0] addr1, addr2,
    input [wordWidth-1:0] dataIn1,
    output reg [wordWidth-1:0] dataOut2
);

reg [wordWidth-1:0] myRAM [0:2**addrSize-1];
integer i;

initial begin
    for (i = 0; i < 2**addrSize; i = i + 1) begin
        myRAM[i] = {{wordWidth}{1'b0}};
    end
end

//TODO: Why is this negedge? It severely restricts timing requirement and the write-before-read operation isn't necessarily that helpful when the addresses are independent
//always @(negedge clk) begin
//Testing it with posedge. Does it work? [Y/N]: 
always @(posedge clk) begin
    if (en1) begin
        if (we1) begin
            myRAM[addr1] <= dataIn1;
        end
    end
end

always @(posedge clk) begin
    if (en2) begin
        dataOut2 <= myRAM[addr2];
    end
end

endmodule
