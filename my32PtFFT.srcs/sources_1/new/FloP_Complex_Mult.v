`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2016 06:10:03 PM
// Design Name: 
// Module Name: FloP_Complex_Mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FloP_Complex_Mult(

    input [exp_width+sig_width:0] Re_a,
    input [exp_width+sig_width:0] Re_b,
    input [exp_width+sig_width:0] Im_a,
    input [exp_width+sig_width:0] Im_b,
    input                         clk,
    input                         reset,
    
    output [exp_width+sig_width:0] Re_Z,
    output [exp_width+sig_width:0] Im_Z
    
);

    parameter sig_width = 23;      // RANGE 2 TO 253
    parameter exp_width = 8;       // RANGE 3 TO 31
    parameter ieee_compliance = 0; // RANGE 0 TO 1
  
    wire [exp_width+sig_width:0] Re_mult1_out, Re_mult2_out, Im_mult1_out, Im_mult2_out,
                                 Re_mult1_RegOut, Re_mult2_RegOut, Im_mult1_RegOut, Im_mult2_RegOut,
                                 Re_Z_ToReg, Im_Z_ToReg;

    //-----Computing the real part of the product: Re_a * Re_b - Im_a * Im_b------//
    //------------V1: Original Code that works in Behavioral Simulation------------//
    /*
    DW_fp_mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance)) 
            Re_mult1(.a(Re_a), .b(Re_b), .rnd(3'b000), .z(Re_mult1_out));
    
    DW_fp_mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance)) 
            Re_mult2(.a(Im_a), .b(Im_b), .rnd(3'b000), .z(Re_mult2_out));
    */
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_mult_ip Re_mult1(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),     .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),     .s_axis_b_tdata(Re_b),
        .m_axis_result_tdata(Re_mult1_out)
    );
    floating_point_mult_ip Re_mult2(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),     .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),     .s_axis_b_tdata(Im_b),
        .m_axis_result_tdata(Re_mult2_out)
    );
            
    //------(My) First stage of Pipeline Registers-----//
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_mult1_Reg(.clk(clk), .dataIn(Re_mult1_out), .writeEn(1'b1), .reset(reset), .dataOut(Re_mult1_RegOut));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_mult2_Reg(.clk(clk), .dataIn(Re_mult2_out), .writeEn(1'b1), .reset(reset), .dataOut(Re_mult2_RegOut));
            
    //-----Moving on to the Subtraction piece-----//
    //------------V1: Original Code that works in Behavioral Simulation------------//
    /*
    //An op of 1 indicates subtraction
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
            Re_sub(.a(Re_mult1_RegOut), .b(Re_mult2_RegOut), .rnd(3'b000), .op(1'b1), .z(Re_Z_ToReg));
    */
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_addsub_ip Re_sub(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Re_mult1_RegOut),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Re_mult2_RegOut),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Re_Z_ToReg)
    );
    
    //-----------(My) Second stage of Pipeline---------//
    //Pushes the real component of the answer out of the multiplication unit
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_sub_Reg(.clk(clk), .dataIn(Re_Z_ToReg), .writeEn(1'b1), .reset(reset), .dataOut(Re_Z));

    //----------------------------------------------------//
    //----------------------------------------------------//
    //Now repeat all of the above with the imaginary part.//
    //----------------------------------------------------//
    //----------------------------------------------------//

    //-----Computing the imaginary part of the product: Re_a * Im_b + Im_a * Re_b------//
    //-------V1: Original Version of the Code that works in Behavioral Simulation------//
    /*
    DW_fp_mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance)) 
            Im_mult1(.a(Re_a), .b(Im_b), .rnd(3'b000), .z(Im_mult1_out));
            
    DW_fp_mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance)) 
            Im_mult2(.a(Im_a), .b(Re_b), .rnd(3'b000), .z(Im_mult2_out));
    */
    //------------V2: Updated Code to use the Xilinx IP Cores------------//
    floating_point_mult_ip Im_mult1(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),     .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),     .s_axis_b_tdata(Im_b),
        .m_axis_result_tdata(Im_mult1_out)
    );
    floating_point_mult_ip Im_mult2(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),     .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),     .s_axis_b_tdata(Re_b),
        .m_axis_result_tdata(Im_mult2_out)
    );
    
    
    //------First stage of Pipeline Registers-----//
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_mult1_Reg(.clk(clk), .dataIn(Im_mult1_out), .writeEn(1'b1), .reset(reset), .dataOut(Im_mult1_RegOut));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_mult2_Reg(.clk(clk), .dataIn(Im_mult2_out), .writeEn(1'b1), .reset(reset), .dataOut(Im_mult2_RegOut));    
    
    //-------Moving on to the Addition piece------//
    //An op of 0 indicates addition
    //------------V1: Original Code that works in Behavioral Simulation------------//
    /*
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
            Im_add(.a(Im_mult1_RegOut), .b(Im_mult2_RegOut), .rnd(3'b000), .op(1'b0), .z(Im_Z_ToReg));
    */
    //------------V2: Code updated to use Xilinx IP Cores to be Synthesizable------------//
    floating_point_addsub_ip Im_add(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Im_mult1_RegOut),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Im_mult2_RegOut),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Im_Z_ToReg)
    );


    //-----------Second stage of Pipeline---------//
    //Pushes the real component of the answer out of the multiplication unit
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_add_Reg(.clk(clk), .dataIn(Im_Z_ToReg), .writeEn(1'b1), .reset(reset), .dataOut(Im_Z));

endmodule
