`timescale 1ns / 1ps

module NBitFLoPComparator
#(
    parameter expWidth = 8,
    parameter fracWidth = 23
)
(
    input [expWidth+fracWidth:0] a,
    input [expWidth+fracWidth:0] b,
    output gt,
    output eq,
    output lt
);

//Split the signal into pieces for ease of design

wire sign1, sign2, expGt, expEq, expLt, fracGt, fracEq, fracLt, flop_gt, flop_eq;
wire [expWidth-1:0] exp1, exp2;
wire [fracWidth-1:0] frac1, frac2;

assign sign1 = a[expWidth+fracWidth];
assign exp1 = a[expWidth+fracWidth-1:fracWidth];
assign frac1 = a[fracWidth-1:0];

assign sign2 = b[expWidth+fracWidth];
assign exp2 = b[expWidth+fracWidth-1:fracWidth];
assign frac2 = b[fracWidth-1:0];

//Instantiate the comparators to be used in this comparison

NBitComparator #(.dataWidth(expWidth)) expComparator(
    .a(exp1), .b(exp2), .gt(expGt), .eq(expEq), .lt(expLt)
);

NBitComparator #(.dataWidth(fracWidth)) fracComparator(
    .a(frac1), .b(frac2), .gt(fracGt), .eq(fracEq), .lt(fracLt)
);

//Assign the outputs
assign flop_gt = (expEq && ((~sign1 && ~sign2 && fracGt) || (sign1 && sign2 && fracLt))) || (~sign1 && ~sign2 && expGt) || (sign1 && sign2 && expLt) || (~sign1 && sign2);
assign flop_eq = (sign1 ~^ sign2) && expEq && fracEq;

assign gt = flop_gt;
assign eq = flop_eq;
assign lt = ~flop_gt && ~flop_eq;

endmodule
