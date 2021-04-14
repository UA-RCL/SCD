`timescale 1ns / 1ps

//Joshua Mack
//Assumes that the numbers are entered as [ReX, Re(X-1), Re(X-2), ..., Re0, ImX, Im(X-1), Im(X-2), ..., Im0]
//Takes advantage of the fact that abs(Z) = sqrt(Z * conj(Z))
module FloP_C_PairwiseAbs(
    input [numNums*64-1:0] complexNums,
    input dataValid,
    input clk,
    input reset,
    output [numNums*32-1:0] absVals,
    output done
);

//Datawidth/wordwidth cannot be parameterized as well because of the sqrt ip
//Thus, it is replaced with "32" everywhere to signify 32-bit single precision floats
parameter numNums = 18;

genvar i;

wire [numNums*32-1:0] realInputs, imagInputs, //Stage 1: Separate the inputs 
                             conjugatedImags,        //Stage 2: Conjugate the inputs
                             realMults;              //Stage 3: Perform Z * conj(Z) (note: we only need the real parts b.c. imag(Z*conj(Z)) = 0)
wire [numNums-1:0] conjMultValid, sqrtValid;

assign realInputs = complexNums[numNums*64-1:numNums*32];
assign imagInputs = complexNums[numNums*32-1:0];

//Instantiate the conjugators
FloP_ComplexConjugate #(.dataWidth(32), .numElements(numNums)) conjugator(
    .dataIn(imagInputs),
    .dataOut(conjugatedImags)
);

//Instantiate the multipliers
generate
    for (i = 0; i < numNums; i = i + 1) begin
        //We really only need one of these multValid signals, but keeping them makes for more readable code.
        //And, who knows, maybe using multiple of them 
        FloP_Complex_Mult mult(
            .clk(clk), .reset(reset), .dataValid(dataValid), .dataValidOut(conjMultValid[i]),
            .Re_a(realInputs[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]), 
            .Re_b(realInputs[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]),
            .Im_a(imagInputs[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]), 
            .Im_b(conjugatedImags[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]),
            
            .Re_Z(realMults[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]), 
            //Since this is conjugate multiplication, the imaginary part is zero
            .Im_Z()
        );
    end
endgenerate

//Instantiate the sqrts
generate
    for (i = 0; i < numNums; i = i + 1) begin
        floating_point_sqrt_ip sqrt(
            .aclk(clk), 
            .s_axis_a_tvalid(conjMultValid[i]),
            .s_axis_a_tdata(realMults[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i]),
            .m_axis_result_tvalid(sqrtValid[i]),
            .m_axis_result_tdata(absVals[(numNums*32-1) - 32*i : ((numNums-1)*32) - 32*i])
        );
    end
endgenerate

//Assign the done signal to the "reductive and" of all of the sqrt done signals
assign done = &sqrtValid;

endmodule
