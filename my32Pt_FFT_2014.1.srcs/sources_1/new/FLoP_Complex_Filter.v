`timescale 1ns / 1ps

module FLoP_Complex_Filter
#(
    parameter numTaps = 8,
    localparam ReImWidth = 32,
    localparam dataWidth = 2*ReImWidth,
    //Delay: FLoP_Mult_IP = 4 cycles, FLoP_AddSum = 5 cycles => Delay = (4 + 5) + 1 + (5) + 1
    //                                                                  C_Mult + Reg + Accumulate + Reg
    localparam delayOfMAC = 16
)
(
    input clk, reset, dataValid,
    //Assuming (MSB to LSB) data is (0 1 2 3 ...) with each index a (Re||Im) (|| = concatenation) complex number
    input [numTaps*dataWidth-1:0] dataIns, coeffIns, 
    output [dataWidth-1:0] dataOut
);

wire [dataWidth-1:0] dataInsReindexed [0:numTaps-1];
wire [dataWidth-1:0] coeffsReindexed [0:numTaps-1];


wire [dataWidth-1:0] dataDelayOuts [1:numberTaps-1];
wire [dataWidth-1:0] coeffDelayOuts [1:numberTaps-1];
wire [0:0] dataValidCascades [0:numTaps-1];

assign dataOut = cascOuts[numTaps-1];

generate
    genvar i;
    
    for (i = 0; i < numTaps; i = i + 1) begin
        assign coeffsReindexed[i] = coeffIns[(numTaps-i)*dataWidth - 1 -: dataWidth];
        assign dataInsReindexed[i] = dataIns[(numTaps-i)*dataWidth - 1 -: dataWidth];
        
        assign dataValidCascades[0] = dataValid;
        
        
        //NOT FINISHED
        if (i == 0) begin
            FLoP_Complex_MAC First_MAC(
                .clk(clk), .reset(reset), .dataValid(dataValidCascades[i]),
                .multiplicand_Re(dataInsReindexed[dataWidth - 1 -: ReImWidth]), .multiplicand_Im(dataInsReindexed[dataWidth - ReImWidth - 1 -: ReImWidth]),
                .coefficient_Re(coeffsReindexed[dataWidth - 1 -: ReImWidth]), .coefficient_Im(coeffsReindexed[dataWidth - ReImWidth - 1 -: ReImWidth]),
                .summand_Re({{ReImWidth}{1'b0}}), .summand_Im({{ReImWidth}{1'b0}}),
                .result_Re(), .result_Im(),
                .resultValid(dataValidCascades[i+1])
            );
        end
        else begin
            FLoP_Complex_MAC ith_MAC(
                .clk(clk), .reset(reset), .dataValid(dataValidCascades[i]),
                .multiplicand_Re(), .multiplicand_Im(),
                .coefficient_Re(), .coefficient_Im(),
                .summand_Re(), .summand_Im(),
                .result_Re(), .result_Im(),
                .resultValid(dataValidCascades[i+1])
            );
        end
    end
    
endgenerate;

endmodule
