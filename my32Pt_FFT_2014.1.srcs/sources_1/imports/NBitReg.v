`timescale 1ns / 1ps

module NBitReg
#(
    parameter dataWidth = 32,
    parameter resetVal = 0
)
(
    input clk, 
    input [dataWidth-1:0] dataIn, 
    input writeEn, 
    input reset, 
    output reg [dataWidth-1:0] dataOut
);

initial begin
//	dataOut <= {dataWidth{1'b0}};
    dataOut <= resetVal;
end

always @(posedge(clk)) begin
	if (reset == 1'b1) begin
//		dataOut <= {dataWidth{1'b0}};
        dataOut <= resetVal;
	end
	else if (writeEn == 1'b1) begin
		dataOut <= dataIn;
	end
	else;
end

endmodule
