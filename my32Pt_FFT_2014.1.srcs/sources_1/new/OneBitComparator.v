`timescale 1ns / 1ps

//Note: Only outputs gt and eq because in what will be this module's parent module, lt is decided by "lt = and(~gt, ~eq)"
module OneBitComparator(
    input a,
    input b,
    output gt,
    output eq
);

//Reduction "and" operator performed on the concatenation of a and not(b)
assign gt = (& {a, ~b});
//Reduction "xnor" operator performed on the contatenation of a and b
assign eq = (~^ {a, b});

endmodule
