`timescale 1ns / 1ps

module FloP_Complex_Mult
#(
    //Ideally, these should actually be localparams, since changing them would only break things (thanks, IP cores)
    //But, I was young and naive then...
    parameter sig_width = 23,     // RANGE 2 TO 253
    parameter exp_width = 8,      // RANGE 3 TO 31
    parameter ieee_compliance = 0 // RANGE 0 TO 1
)
(

    input [exp_width+sig_width:0] Re_a,
    input [exp_width+sig_width:0] Re_b,
    input [exp_width+sig_width:0] Im_a,
    input [exp_width+sig_width:0] Im_b,
    input                         clk,
    input                         reset,
    input                         dataValid,
    
    output [exp_width+sig_width:0] Re_Z,
    output [exp_width+sig_width:0] Im_Z,
    output                        dataValidOut
    
);

    wire [exp_width+sig_width:0] Re_mult1_out, Re_mult2_out, Im_mult1_out, Im_mult2_out;
    
    wire multToAdder_Valid;

    //-----Computing the real part of the product: Re_a * Re_b - Im_a * Im_b------//
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_mult_ip Re_mult1(
        .aclk(clk),
        .s_axis_a_tvalid(dataValid),     .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(dataValid),     .s_axis_b_tdata(Re_b),
        .m_axis_result_tdata(Re_mult1_out),
        .m_axis_result_tvalid(multToAdder_Valid)
    );
    floating_point_mult_ip Re_mult2(
        .aclk(clk),
        .s_axis_a_tvalid(dataValid),     .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(dataValid),     .s_axis_b_tdata(Im_b),
        .m_axis_result_tdata(Re_mult2_out),
        .m_axis_result_tvalid()
    );
                        
    //-----Moving on to the Subtraction piece-----//
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_addsub_ip Re_sub(
        .aclk(clk),
        .s_axis_a_tvalid(multToAdder_Valid),         .s_axis_a_tdata(Re_mult1_out),
        .s_axis_b_tvalid(multToAdder_Valid),         .s_axis_b_tdata(Re_mult2_out),
        .s_axis_operation_tvalid(multToAdder_Valid), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Re_Z),
        .m_axis_result_tvalid(dataValidOut)
    );
    
    //----------------------------------------------------//
    //----------------------------------------------------//
    //Now repeat all of the above with the imaginary part.//
    //----------------------------------------------------//
    //----------------------------------------------------//

    //-----Computing the imaginary part of the product: Re_a * Im_b + Im_a * Re_b------//
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_mult_ip Im_mult1(
        .aclk(clk),
        .s_axis_a_tvalid(~reset),     .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(~reset),     .s_axis_b_tdata(Im_b),
        .m_axis_result_tdata(Im_mult1_out),
        .m_axis_result_tvalid()
    );
    floating_point_mult_ip Im_mult2(
        .aclk(clk),
        .s_axis_a_tvalid(~reset),     .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(~reset),     .s_axis_b_tdata(Re_b),
        .m_axis_result_tdata(Im_mult2_out),
        .m_axis_result_tvalid()
    );
    
    
    //-------Moving on to the Addition piece------//
    //An op of 0 indicates addition
    //------------V2: Code updated to use Xilinx IP Cores to be Synthesizable------------//
    floating_point_addsub_ip Im_add(
        .aclk(clk),
        .s_axis_a_tvalid(~reset),         .s_axis_a_tdata(Im_mult1_out),
        .s_axis_b_tvalid(~reset),         .s_axis_b_tdata(Im_mult2_out),
        .s_axis_operation_tvalid(~reset), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Im_Z),
        .m_axis_result_tvalid()
    );

endmodule
