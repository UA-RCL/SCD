`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:01:18 10/12/2015 
// Design Name: 
// Module Name:    NBitReg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module NBitReg(clk, dataIn, writeEn, reset, dataOut);

parameter dataWidth = 32;

input [dataWidth-1:0] dataIn;
input writeEn, reset, clk;
output reg [dataWidth-1:0] dataOut;

initial begin
	dataOut <= {dataWidth{1'b0}};
end

always @(posedge(clk)) begin
	if (reset == 1'b1) begin
		dataOut <= {dataWidth{1'b0}};
	end
	else if (writeEn == 1'b1) begin
		dataOut <= dataIn;
	end
	else;
end

endmodule
