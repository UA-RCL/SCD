`timescale 1ns / 1ps

module Incrementor(
    input [dataWidth-1:0] dataIn,
    output [dataWidth-1:0] dataOut
);

parameter dataWidth = 16;

//If there are any problems later, I suppose I can structurally design this,
//But for now, since this only plays a role in the state machine, it should be fine
//To let the synthesis tool decide how to map it to a physical adder
assign dataOut = dataIn + 1;

endmodule
