`timescale 1ns / 1ps

//Joshua Mack
//Finds the maximum of two floating point numbers and outputs it on "max"
module FloP_Max(
    input [expWidth+fracWidth:0] dataIn1,
    input [expWidth+fracWidth:0] dataIn2,
    output [expWidth+fracWidth:0] max
);

parameter expWidth = 8;
parameter fracWidth = 23;

wire gt;

//Instantiate a FloP comparator
NBitFLoPComparator #(.expWidth(expWidth), .fracWidth(fracWidth)) comparator(
    .a(dataIn1), .b(dataIn2),
    .gt(gt), .eq(), .lt()
);

//Assign the max based on the result of that comparison
assign max = (gt == 1) ? dataIn1 : dataIn2;

endmodule
