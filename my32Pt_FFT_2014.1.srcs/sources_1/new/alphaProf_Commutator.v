`timescale 1ns / 1ps

module alphaProf_Commutator
#(
    parameter dataWidth = 32
)
(
    input [dataWidth-1:0] dataIn1,
    input [dataWidth-1:0] dataIn2,
    input swapInputs,
    output [dataWidth-1:0] dataOut1,
    output [dataWidth-1:0] dataOut2
);

assign dataOut1 = (swapInputs == 1'b0) ? dataIn1 : dataIn2;
assign dataOut2 = (swapInputs == 1'b0) ? dataIn2 : dataIn1;

endmodule
