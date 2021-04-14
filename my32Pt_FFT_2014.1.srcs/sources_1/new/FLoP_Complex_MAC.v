`timescale 1ns / 1ps

//Delay: FLoP_Mult_IP = 4 cycles, FLoP_AddSum = 5 cycles => Delay = (4 + 5) + 1 + (5) + 1
//                                                                  C_Mult + Reg + Accumulate + Reg
module FLoP_Complex_MAC
#(
    parameter exp_width = 8,
    parameter sig_width = 23,
    parameter ieee_compliance = 0
)
(
    input clk, input reset, input dataValid,
    input [dataWidth-1:0] multiplicand_Re, multiplicand_Im,
    input [dataWidth-1:0] coefficient_Re, coefficient_Im,
    input [dataWidth-1:0] summand_Re, summand_Im,
    //Result = A*x + B = multiplicand * coefficient + summand
    output [dataWidth-1:0] result_Re,
    output [dataWidth-1:0] result_Im,
    output resultValid
);
    
    localparam dataWidth = exp_width + sig_width + 1;
    
    wire [dataWidth-1:0] multOut_Re, multOut_Im;
    wire [2*dataWidth:0] multOut_D;
    wire multDataValid;
    
    wire [dataWidth-1:0] adderOut_Re, adderOut_Im;
    wire [2*dataWidth:0] adderOut_D;
    wire adderDataValid_Re;
    
    //Steps to performing a Multiply-Accumulate Operation:
    //1. Multiply the multiplicand with the coefficient
    FloP_Complex_Mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance)) myMult(
        .clk(clk), .reset(reset), .dataValid(dataValid), .dataValidOut(multDataValid),
        .Re_a(multiplicand_Re), .Im_a(multiplicand_Im), .Re_b(coefficient_Re), .Im_b(coefficient_Im), .Re_Z(multOut_Re), .Im_Z(multOut_Im)
    );
    
    //1.5 Intermediate pipelining
    NBitReg #(.dataWidth(2*dataWidth+1), .resetVal(0)) multResult_Reg(
        .clk(clk), .reset(reset), .writeEn(1'b1), .dataIn({multOut_Re, multOut_Im, multDataValid}), .dataOut(multOut_D)
    );
    
    //2. Accumulate
    floating_point_addsub_ip realAdder(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(multOut_D[2*dataWidth -: dataWidth]),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(summand_Re),
        .s_axis_operation_tvalid(multOut_D[0]), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(adderOut_Re),
        .m_axis_result_tvalid(adderDataValid_Re)
    );
    
    floating_point_addsub_ip imagAdder(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(multOut_D[1*dataWidth -: dataWidth]),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(summand_Im),
        .s_axis_operation_tvalid(multOut_D[0]), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(adderOut_Im),
        .m_axis_result_tvalid()
    );
    
    //2.5 Final output pipeline registering
    NBitReg #(.dataWidth(2*dataWidth+1), .resetVal(0)) accumulateResult_Reg(
        .clk(clk), .reset(reset), .writeEn(1'b1), .dataIn({adderOut_Re, adderOut_Im, adderDataValid_Re}), .dataOut(adderOut_D)
    );
    
    assign result_Re = adderOut_D[2*dataWidth -: dataWidth];
    assign result_Im = adderOut_D[1*dataWidth -: dataWidth];
    assign resultValid = adderOut_D[0];
    
    
endmodule
