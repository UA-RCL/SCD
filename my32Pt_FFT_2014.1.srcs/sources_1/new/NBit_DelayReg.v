`timescale 1ns / 1ps

module NBit_DelayReg
#(
    parameter dataWidth = 32,
    parameter cyclesToDelay = 1
)
(
    input clk, 
    input [dataWidth-1:0] dataIn, 
    input writeEn, 
    input reset, 
    output [dataWidth-1:0] dataOut
);

wire [dataWidth-1:0] regCarries [0:cyclesToDelay-1];

genvar i;
generate
    for (i = 0; i < cyclesToDelay; i = i + 1) begin: RegisterLoop
        if (i == 0) begin
            NBitReg #(.dataWidth(dataWidth)) initialReg(
                .clk(clk), .dataIn(dataIn), .writeEn(writeEn), .reset(reset), .dataOut(regCarries[i])
            );
        end
        else begin
            NBitReg #(.dataWidth(dataWidth)) reg_inst(
                .clk(clk), .dataIn(regCarries[i-1]), .writeEn(writeEn), .reset(reset), .dataOut(regCarries[i])
            );    
        end
    end
endgenerate

assign dataOut = regCarries[cyclesToDelay-1];

endmodule
