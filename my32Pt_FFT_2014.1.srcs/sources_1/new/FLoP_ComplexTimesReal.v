`timescale 1ns / 1ps

module FLoP_ComplexTimesReal
#(
    localparam ReImWidth = 32,
    localparam dataWidth = 2*ReImWidth
)
(
    input clk, reset, dataValid,
    input [ReImWidth-1:0] dataInRe, dataInIm, coeffIn,
    output [ReImWidth-1:0] dataOutRe, dataOutIm,
    output dataValidOut
);

wire dataValidRe_Out, dataValidIm_Out;

floating_point_mult_ip Re_mult(
    .aclk(clk),
    .s_axis_a_tvalid(dataValid),     .s_axis_a_tdata(dataInRe),
    .s_axis_b_tvalid(dataValid),     .s_axis_b_tdata(coeffIn),
    .m_axis_result_tdata(dataOutRe),
    .m_axis_result_tvalid(dataValidRe_Out)
);

floating_point_mult_ip Im_mult(
    .aclk(clk),
    .s_axis_a_tvalid(dataValid),     .s_axis_a_tdata(dataInIm),
    .s_axis_b_tvalid(dataValid),     .s_axis_b_tdata(coeffIn),
    .m_axis_result_tdata(dataOutIm),
    .m_axis_result_tvalid(dataValidIm_Out)
);

assign dataValidOut = dataValidRe_Out && dataValidIm_Out;

endmodule
