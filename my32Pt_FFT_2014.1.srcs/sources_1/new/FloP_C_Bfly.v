`timescale 1ns / 1ps

module FloP_C_Bfly(
    
    input [exp_width+sig_width:0] Re_a,
    input [exp_width+sig_width:0] Re_b,
    input [exp_width+sig_width:0] Re_w,
    input [exp_width+sig_width:0] Im_a,
    input [exp_width+sig_width:0] Im_b,
    input [exp_width+sig_width:0] Im_w,
    input                         clk,
    input                         reset,
    input                         dataValid,
    
    output [exp_width+sig_width:0] Re_Y,
    output [exp_width+sig_width:0] Re_Z,
    output [exp_width+sig_width:0] Im_Y,
    output [exp_width+sig_width:0] Im_Z,
    output                         dataValidOut
    
);
    
    parameter sig_width = 23;      // RANGE 2 TO 253
    parameter exp_width = 8;       // RANGE 3 TO 31
    parameter ieee_compliance = 0; // RANGE 0 TO 1
    
    //Outputs of the top adder headed towards the pipeline registers
    wire [exp_width+sig_width:0] Re_Adder1Reg1, Re_Reg1Reg2, Re_Reg2Reg3, Re_Reg3Reg4, Re_Reg4Reg5, Re_Reg5Reg6, Re_Reg6Reg7, Re_Reg7Reg8, Re_Reg8Reg9;
                                 
    wire [exp_width+sig_width:0] Im_Adder1Reg1, Im_Reg1Reg2, Im_Reg2Reg3, Im_Reg3Reg4, Im_Reg4Reg5, Im_Reg5Reg6, Im_Reg6Reg7, Im_Reg7Reg8, Im_Reg8Reg9;
    
    wire Re_Adder1Valid;
    
    //Outputs of the bottom subtractor headed towards the multiplication unit
    wire [exp_width+sig_width:0] Re_Adder2Mult, Im_Adder2Mult;
    
    //--------------This design using the Xilinx IP Cores & Massive Amounts of Pipelining------------------//
    //--------NOTE: Using the IP doesn't allow for fully parameterized designs without rebuilding the IP---------//
    //Implementation note: result_tvalid is only extracted from one of the cores because dataValid is fed into all four,
    //and they're four instances of the same core, so result_tvalid will always be the same between them.
    floating_point_addsub_ip myAdder1(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Re_b),
        .s_axis_operation_tvalid(dataValid), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Re_Adder1Reg1),
        .m_axis_result_tvalid(Re_Adder1Valid)
    );
    floating_point_addsub_ip myAdder2(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Im_b),
        .s_axis_operation_tvalid(dataValid), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Im_Adder1Reg1),
        .m_axis_result_tvalid()
    );
    floating_point_addsub_ip myAdder3(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Re_b),
        .s_axis_operation_tvalid(dataValid), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Re_Adder2Mult),
        .m_axis_result_tvalid()
    );
    floating_point_addsub_ip myAdder4(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Im_b),
        .s_axis_operation_tvalid(dataValid), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Im_Adder2Mult),
        .m_axis_result_tvalid()
    );
    
    //--------------------Pipeline Registers------------------//
    
    //Exact Number TBD After Determining multiplier latency
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg1(.clk(clk), .dataIn(Re_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg2(.clk(clk), .dataIn(Re_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg2Reg3));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg3(.clk(clk), .dataIn(Re_Reg2Reg3), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg3Reg4));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg4(.clk(clk), .dataIn(Re_Reg3Reg4), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg4Reg5));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg5(.clk(clk), .dataIn(Re_Reg4Reg5), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg5Reg6));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg6(.clk(clk), .dataIn(Re_Reg5Reg6), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg6Reg7));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg7(.clk(clk), .dataIn(Re_Reg6Reg7), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg7Reg8));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg8(.clk(clk), .dataIn(Re_Reg7Reg8), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg8Reg9));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg9(.clk(clk), .dataIn(Re_Reg8Reg9), .reset(reset), .writeEn(1'b1), .dataOut(Re_Y));
    
    
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg1(.clk(clk), .dataIn(Im_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg2(.clk(clk), .dataIn(Im_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg2Reg3));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg3(.clk(clk), .dataIn(Im_Reg2Reg3), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg3Reg4));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg4(.clk(clk), .dataIn(Im_Reg3Reg4), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg4Reg5));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg5(.clk(clk), .dataIn(Im_Reg4Reg5), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg5Reg6));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg6(.clk(clk), .dataIn(Im_Reg5Reg6), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg6Reg7));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg7(.clk(clk), .dataIn(Im_Reg6Reg7), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg7Reg8));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg8(.clk(clk), .dataIn(Im_Reg7Reg8), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg8Reg9));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg9(.clk(clk), .dataIn(Im_Reg8Reg9), .reset(reset), .writeEn(1'b1), .dataOut(Im_Y)); 
    
    //----------------------FLoP Complex Multiplier------------------//
    FloP_Complex_Mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myMult(.clk(clk), .reset(reset), .dataValid(Re_Adder1Valid), .dataValidOut(dataValidOut),
               .Re_a(Re_Adder2Mult), .Im_a(Im_Adder2Mult), .Re_b(Re_w), .Im_b(Im_w), .Re_Z(Re_Z), .Im_Z(Im_Z)
               );
    
    
endmodule