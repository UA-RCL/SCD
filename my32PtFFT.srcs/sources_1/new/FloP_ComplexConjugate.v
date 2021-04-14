module FloP_ComplexConjugate(
	input [dataWidth-1:0] dataIn,
	output [dataWidth-1:0] dataOut
);

parameter dataWidth = 32;

assign dataOut = {~dataIn[dataWidth-1], dataIn[dataWidth-2:0]};