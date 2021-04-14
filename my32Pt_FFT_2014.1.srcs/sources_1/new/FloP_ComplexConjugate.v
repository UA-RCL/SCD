module FloP_ComplexConjugate(
	input [numElements*dataWidth-1:0] dataIn,
	output [numElements*dataWidth-1:0] dataOut
);

parameter dataWidth = 32;
parameter numElements = 32;

genvar i;
generate
    for (i = 0; i < numElements; i = i + 1) begin
        assign dataOut[dataWidth*i + dataWidth-1:dataWidth*i] = {~dataIn[dataWidth*i+dataWidth-1], dataIn[dataWidth*i+dataWidth-2:dataWidth*i]};
    end
endgenerate

endmodule