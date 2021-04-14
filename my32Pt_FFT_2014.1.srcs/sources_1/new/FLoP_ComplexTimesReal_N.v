`timescale 1ns / 1ps

module FLoP_ComplexTimesReal_N
#(
    parameter numMults = 16,
    localparam ReImWidth = 32,
    localparam dataWidth = 2*ReImWidth
)
(
    input clk, reset, dataValid,
    input [numMults*ReImWidth-1:0] dataInsRe, dataInsIm, coeffIns,
    output [numMults*ReImWidth-1:0] dataOutsRe, dataOutsIm,
    output dataValidOut
);

wire [numMults-1:0] dataValidOuts;

generate
    genvar i;
    for (i = 0; i < numMults; i = i + 1) begin
        FLoP_ComplexTimesReal multInst_i(
            .clk(clk), .reset(reset), .dataValid(dataValid),
            .dataInRe(dataInsRe[(numMults-i)*ReImWidth - 1 -: ReImWidth]), .dataInIm(dataInsIm[(numMults-i)*ReImWidth - 1 -: ReImWidth]),
            .coeffIn(coeffIns[(numMults-i)*ReImWidth - 1 -: ReImWidth]),
            .dataOutRe(dataOutsRe[(numMults-i)*ReImWidth - 1 -: ReImWidth]), .dataOutIm(dataOutsIm[(numMults-i)*ReImWidth - 1 -: ReImWidth]),
            .dataValidOut(dataValidOuts[i])
        );
    end
endgenerate

assign dataValidOut = &dataValidOuts;

endmodule
