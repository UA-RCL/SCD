`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2016 08:02:09 PM
// Design Name: 
// Module Name: FloP_C_Bfly
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


module FloP_C_Bfly(
    
    input [exp_width+sig_width:0] Re_a,
    input [exp_width+sig_width:0] Re_b,
    input [exp_width+sig_width:0] Re_w,
    input [exp_width+sig_width:0] Im_a,
    input [exp_width+sig_width:0] Im_b,
    input [exp_width+sig_width:0] Im_w,
    input                         clk,
    input                         reset,
    
    output [exp_width+sig_width:0] Re_Y,
    output [exp_width+sig_width:0] Re_Z,
    output [exp_width+sig_width:0] Im_Y,
    output [exp_width+sig_width:0] Im_Z
    
);
    /*
    parameter sig_width = 23;      // RANGE 2 TO 253
    parameter exp_width = 8;       // RANGE 3 TO 31
    parameter ieee_compliance = 0; // RANGE 0 TO 1
    
    //Outputs of the Pipeline registers for Re_a and Im_a
    wire [exp_width+sig_width:0] Re_a_Reg1Reg2, Re_a_Reg2Adder, Im_a_Reg1Reg2, Im_a_Reg2Adder;
    
    //TEST WIRES FOR PIPELINE REGISTERS THAT DELAY THE B-INPUT
    wire [exp_width+sig_width:0] Re_b_Reg1Reg2, Re_b_Reg2Adder, Im_b_Reg1Reg2, Im_b_Reg2Adder;
    //END TEST WIRES DECLARATION
    
    //WIRES TESTING TO SEE IF I NEED TO BE SHIFTING THESE OUTPUTS BY 2
    wire [exp_width+sig_width:0] Re_Adder1_Out, Im_Adder1_Out, Re_Adder2_Out, Im_Adder2_Out;
    //END
    
    //Outputs of the multiplier unit
    wire [exp_width+sig_width:0] Re_MultOut, Im_MultOut;
    
    //Instantiating the complex multiplier that will be used to feed the rest of the adders
    FloP_Complex_Mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myMult(.clk(clk), .reset(reset), .Re_a(Re_b), .Im_a(Im_b), .Re_b(Re_w), .Im_b(Im_w), .Re_Z(Re_MultOut), .Im_Z(Im_MultOut));
    
    //Pipeline registers that will keep the incoming data aligned with the data after the two cycles spent multiplying
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_a_Reg1(.clk(clk), .dataIn(Re_a), .writeEn(1'b1), .reset(reset), .dataOut(Re_a_Reg1Reg2));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_a_Reg2(.clk(clk), .dataIn(Re_a_Reg1Reg2), .writeEn(1'b1), .reset(reset), .dataOut(Re_a_Reg2Adder));
    
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_a_Reg1(.clk(clk), .dataIn(Im_a), .writeEn(1'b1), .reset(reset), .dataOut(Im_a_Reg1Reg2));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_a_Reg2(.clk(clk), .dataIn(Im_a_Reg1Reg2), .writeEn(1'b1), .reset(reset), .dataOut(Im_a_Reg2Adder));
    
    //TEST PIPELINE REGISTERS TO SEE IF THE UPPER HALF OF THE BUTTERFLY NEEDS TO NOT BE MULTIPLIED BY W_N
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_b_Reg1(.clk(clk), .dataIn(Re_b), .writeEn(1'b1), .reset(reset), .dataOut(Re_b_Reg1Reg2));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Re_b_Reg2(.clk(clk), .dataIn(Re_b_Reg1Reg2), .writeEn(1'b1), .reset(reset), .dataOut(Re_b_Reg2Adder));
    
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_b_Reg1(.clk(clk), .dataIn(Im_b), .writeEn(1'b1), .reset(reset), .dataOut(Im_b_Reg1Reg2));
    NBitReg #(.dataWidth(sig_width+exp_width+1)) Im_b_Reg2(.clk(clk), .dataIn(Im_b_Reg1Reg2), .writeEn(1'b1), .reset(reset), .dataOut(Im_b_Reg2Adder));
    //END OF TEST PIPELINE REGISTERS
    
    //Instantiating the other four adders that will compose the butterfly unit
    //An op of 0 indicates addition, 1 indicates subtraction
//    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
//        myAdder1(.a(Re_a_Reg2Adder), .b(Re_MultOut), .rnd(3'b000), .op(1'b0), .z(Re_Y));
        
//    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
//        myAdder2(.a(Im_a_Reg2Adder), .b(Im_MultOut), .rnd(3'b000), .op(1'b0), .z(Im_Y));


    //The Four Adders used with FFT where top output is not multiplied by the twiddle factor, but no shifting occurs
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder1(.a(Re_a_Reg2Adder), .b(Re_b_Reg2Adder), .rnd(3'b000), .op(1'b0), .z(Re_Y));
        
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder2(.a(Im_a_Reg2Adder), .b(Im_b_Reg2Adder), .rnd(3'b000), .op(1'b0), .z(Im_Y));
                
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder3(.a(Re_a_Reg2Adder), .b(Re_MultOut), .rnd(3'b000), .op(1'b1), .z(Re_Z));
      
    /*  
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder4(.a(Im_a_Reg2Adder), .b(Im_MultOut), .rnd(3'b000), .op(1'b1), .z(Im_Z));
    
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder1(.a(Re_a_Reg2Adder), .b(Re_b_Reg2Adder), .rnd(3'b000), .op(1'b0), .z(Re_Adder1_Out));
        
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder2(.a(Im_a_Reg2Adder), .b(Im_b_Reg2Adder), .rnd(3'b000), .op(1'b0), .z(Im_Adder1_Out));
                
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder3(.a(Re_a_Reg2Adder), .b(Re_MultOut), .rnd(3'b000), .op(1'b1), .z(Re_Adder2_Out));
        
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder4(.a(Im_a_Reg2Adder), .b(Im_MultOut), .rnd(3'b000), .op(1'b1), .z(Im_Adder2_Out));
        
    assign Re_Y = {Re_Adder1_Out[sig_width+exp_width], Re_Adder1_Out[sig_width+exp_width-1:sig_width] - 1, 1'b0, Re_Adder1_Out[sig_width-1:1]};
    assign Im_Y = {Im_Adder1_Out[sig_width+exp_width], Im_Adder1_Out[sig_width+exp_width-1:sig_width] - 1, 1'b0, Im_Adder1_Out[sig_width-1:1]};
    
    assign Re_Z = {Re_Adder2_Out[sig_width+exp_width], Re_Adder2_Out[sig_width+exp_width-1:sig_width] - 1, 1'b0, Re_Adder2_Out[sig_width-1:1]};
    assign Im_Z = {Im_Adder2_Out[sig_width+exp_width], Im_Adder2_Out[sig_width+exp_width-1:sig_width] - 1, 1'b0, Im_Adder2_Out[sig_width-1:1]};
    */
    
    //TEST TO SEE IF MOVING THE MULTIPLICATION TO AFTER THE SUBTRACTION DOES ANYTHING//
    
    parameter sig_width = 23;      // RANGE 2 TO 253
    parameter exp_width = 8;       // RANGE 3 TO 31
    parameter ieee_compliance = 0; // RANGE 0 TO 1
    
    //Outputs of the top adder headed towards the pipeline registers
    wire [exp_width+sig_width:0] Re_Adder1Reg1, Re_Reg1Reg2, Re_Reg2Reg3, Re_Reg3Reg4, Re_Reg4Reg5, Re_Reg5Reg6, Re_Reg6Reg7, Re_Reg7Reg8,
                                 Re_Reg8Reg9, Re_Reg9Reg10, Re_Reg10Reg11, Re_Reg11Reg12, Re_Reg12Reg13, Re_Reg13Reg14, Re_Reg14Reg15, Re_Reg15Reg16,
                                 Re_Reg16Reg17, Re_Reg17Reg18;
    wire [exp_width+sig_width:0] Im_Adder1Reg1, Im_Reg1Reg2, Im_Reg2Reg3, Im_Reg3Reg4, Im_Reg4Reg5, Im_Reg5Reg6, Im_Reg6Reg7, Im_Reg7Reg8,
                                 Im_Reg8Reg9, Im_Reg9Reg10, Im_Reg10Reg11, Im_Reg11Reg12, Im_Reg12Reg13, Im_Reg13Reg14, Im_Reg14Reg15, Im_Reg15Reg16,
                                 Im_Reg16Reg17, Im_Reg17Reg18;
    
    //Outputs of the bottom subtractor headed towards the multiplication unit
    wire [exp_width+sig_width:0] Re_Adder2Mult, Im_Adder2Mult;
    
    //Instantiating the Adders First
    //-------This design (contained in this block comment) is the original working Butterfly code.----------//
    //FP_AddSub adders only used in behavioral simulation
    /*
    //The top of the butterfly: the addition
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder1(.a(Re_a), .b(Re_b), .rnd(3'b000), .op(1'b0), .z(Re_Adder1Reg1));     
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder2(.a(Im_a), .b(Im_b), .rnd(3'b000), .op(1'b0), .z(Im_Adder1Reg1));
    //The bottom of the butterfly: the subtraction
    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder3(.a(Re_a), .b(Re_b), .rnd(3'b000), .op(1'b1), .z(Re_Adder2Mult));

    DW_fp_addsub #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myAdder4(.a(Im_a), .b(Im_b), .rnd(3'b000), .op(1'b1), .z(Im_Adder2Mult));
    
    
    //Pipeline registers for the results of the top addition while it waits for the bottom multiplication to finish
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg1(.clk(clk), .dataIn(Re_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg2(.clk(clk), .dataIn(Re_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Re_Y));
    
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg1(.clk(clk), .dataIn(Im_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg2(.clk(clk), .dataIn(Im_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Im_Y));
    
    //Instantiating the complex multiplier
    FloP_Complex_Mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myMult(.clk(clk), .reset(reset), .Re_a(Re_Adder2Mult), .Im_a(Im_Adder2Mult), .Re_b(Re_w), .Im_b(Im_w), .Re_Z(Re_Z), .Im_Z(Im_Z));
    */
    
    //--------------This design using the Xilinx IP Cores & Massive Amounts of Pipelining------------------//
    //--------NOTE: Using the IP doesn't allow for parameterized designs without rebuilding the IP---------//
    
    floating_point_addsub_ip myAdder1(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Re_b),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Re_Adder1Reg1)
    );
    floating_point_addsub_ip myAdder2(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Im_b),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000000),
        .m_axis_result_tdata(Im_Adder1Reg1)
    );
    floating_point_addsub_ip myAdder3(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Re_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Re_b),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Re_Adder2Mult)
    );
    floating_point_addsub_ip myAdder4(
        .aclk(clk),
        .s_axis_a_tvalid(1'b1),         .s_axis_a_tdata(Im_a),
        .s_axis_b_tvalid(1'b1),         .s_axis_b_tdata(Im_b),
        .s_axis_operation_tvalid(1'b1), .s_axis_operation_tdata(8'b00000001),
        .m_axis_result_tdata(Im_Adder2Mult)
    );
    
    //--------------------Pipeline Registers------------------//
    
    //TBD After Determining multiplier latency -- Currently it's 18 clock cycles
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg1(.clk(clk), .dataIn(Re_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg2(.clk(clk), .dataIn(Re_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg2Reg3));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg3(.clk(clk), .dataIn(Re_Reg2Reg3), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg3Reg4));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg4(.clk(clk), .dataIn(Re_Reg3Reg4), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg4Reg5));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg5(.clk(clk), .dataIn(Re_Reg4Reg5), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg5Reg6));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg6(.clk(clk), .dataIn(Re_Reg5Reg6), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg6Reg7));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg7(.clk(clk), .dataIn(Re_Reg6Reg7), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg7Reg8));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg8(.clk(clk), .dataIn(Re_Reg7Reg8), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg8Reg9));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg9(.clk(clk), .dataIn(Re_Reg8Reg9), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg9Reg10));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg10(.clk(clk), .dataIn(Re_Reg9Reg10), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg10Reg11));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg11(.clk(clk), .dataIn(Re_Reg10Reg11), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg11Reg12));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg12(.clk(clk), .dataIn(Re_Reg11Reg12), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg12Reg13));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg13(.clk(clk), .dataIn(Re_Reg12Reg13), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg13Reg14));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg14(.clk(clk), .dataIn(Re_Reg13Reg14), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg14Reg15));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg15(.clk(clk), .dataIn(Re_Reg14Reg15), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg15Reg16));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg16(.clk(clk), .dataIn(Re_Reg15Reg16), .reset(reset), .writeEn(1'b1), .dataOut(Re_Reg16Reg17));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Re_Reg17(.clk(clk), .dataIn(Re_Reg16Reg17), .reset(reset), .writeEn(1'b1), .dataOut(Re_Y));
    
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg1(.clk(clk), .dataIn(Im_Adder1Reg1), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg1Reg2));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg2(.clk(clk), .dataIn(Im_Reg1Reg2), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg2Reg3));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg3(.clk(clk), .dataIn(Im_Reg2Reg3), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg3Reg4));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg4(.clk(clk), .dataIn(Im_Reg3Reg4), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg4Reg5));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg5(.clk(clk), .dataIn(Im_Reg4Reg5), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg5Reg6));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg6(.clk(clk), .dataIn(Im_Reg5Reg6), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg6Reg7));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg7(.clk(clk), .dataIn(Im_Reg6Reg7), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg7Reg8));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg8(.clk(clk), .dataIn(Im_Reg7Reg8), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg8Reg9));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg9(.clk(clk), .dataIn(Im_Reg8Reg9), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg9Reg10));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg10(.clk(clk), .dataIn(Im_Reg9Reg10), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg10Reg11));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg11(.clk(clk), .dataIn(Im_Reg10Reg11), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg11Reg12));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg12(.clk(clk), .dataIn(Im_Reg11Reg12), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg12Reg13));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg13(.clk(clk), .dataIn(Im_Reg12Reg13), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg13Reg14));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg14(.clk(clk), .dataIn(Im_Reg13Reg14), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg14Reg15));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg15(.clk(clk), .dataIn(Im_Reg14Reg15), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg15Reg16));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg16(.clk(clk), .dataIn(Im_Reg15Reg16), .reset(reset), .writeEn(1'b1), .dataOut(Im_Reg16Reg17));
    NBitReg #(.dataWidth(exp_width+sig_width+1)) Im_Reg17(.clk(clk), .dataIn(Im_Reg16Reg17), .reset(reset), .writeEn(1'b1), .dataOut(Im_Y));  
    
    //----------------------FLoP Complex Multiplier------------------//
    //Turns out the Xilinx "complex multiplier" isn't FLoP, so back to just modifying the FloP_Complex_Mult design
    FloP_Complex_Mult #(.exp_width(exp_width), .sig_width(sig_width), .ieee_compliance(ieee_compliance))
        myMult(.clk(clk), .reset(reset), .Re_a(Re_Adder2Mult), .Im_a(Im_Adder2Mult), .Re_b(Re_w), .Im_b(Im_w), .Re_Z(Re_Z), .Im_Z(Im_Z));
    
    
endmodule
