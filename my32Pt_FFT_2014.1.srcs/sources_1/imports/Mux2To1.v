`timescale 1ns / 1ps

module Mux2To1 (input1, input2, sel, out);

parameter dataWidth = 32;

input [dataWidth-1:0] input1, input2;
input sel;
output [dataWidth-1:0] out;

assign out = (sel == 1'b0) ? input1 : input2;

endmodule
