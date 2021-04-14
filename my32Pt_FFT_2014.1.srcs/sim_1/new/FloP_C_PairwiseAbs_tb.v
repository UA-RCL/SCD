`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2016 07:10:41 PM
// Design Name: 
// Module Name: FloP_C_Abs_tb
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


module FloP_C_PairwiseAbs_tb();

//Inputs
reg [63:0] oneNum;
reg [1151:0] eighteenNums;
reg clk, reset, dataValid;
//Outputs
wire [31:0] absOneNum;
wire [575:0] absEighteenNums;
wire doneOne, doneEighteen;

//Abs instantiations
FloP_C_PairwiseAbs #(.numNums(1)) oneAbs(
    .complexNums(oneNum),
    .dataValid(dataValid),
    .clk(clk),
    .reset(reset),
    .absVals(absOneNum),
    .done(doneOne)
);

FloP_C_PairwiseAbs #(.numNums(18)) eighteenAbs(
    .complexNums(eighteenNums),
    .dataValid(dataValid),
    .clk(clk),
    .reset(reset),
    .absVals(absEighteenNums),
    .done(doneEighteen)
);

//Start up the clock
always begin
    clk <= 1'b0; #10;
    clk <= 1'b1; #10;
end

//Begin testing
initial begin
    reset <= 1'b1; dataValid <= 1'b0;
    @(posedge clk);
    reset <= 1'b0; 
    @(posedge clk);
    dataValid <= 1'b1;
    //Testing just individual numbers
    //1 + j1, expected = sqrt(2)
    oneNum <= 64'h3f8000003f800000;
    @(posedge clk);
    //3 + j4, expected = 5
    oneNum <= 64'h4040000040800000;
    @(posedge clk);
    //-1 - j1, expected = sqrt(2)
    oneNum <= 64'hbf800000bf800000;
    @(posedge clk);
    //20*e - j*17*pi, expected = 76.2098294938854
    oneNum <= 64'h42597669c255a0d8;
    @(posedge clk);
    //Data is no longer valid anymore
    dataValid <= 1'b0;
    //Wait for things to be done
    wait(doneOne);
    //Let the results come out
    repeat(5)@(posedge clk);
    
    //Clear out the done reg
    wait(~doneOne);
    
    //Now test 18 numbers at once
    //{18{1 + j1}}, expected = {18{sqrt(2)}}
    dataValid <= 1'b1;
    eighteenNums <= 1152'h3f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f8000003f800000;
    @(posedge clk);
    //{18{3 + j4}}, expected = {18{5}}
    eighteenNums <= 1152'h404000004040000040400000404000004040000040400000404000004040000040400000404000004040000040400000404000004040000040400000404000004040000040400000408000004080000040800000408000004080000040800000408000004080000040800000408000004080000040800000408000004080000040800000408000004080000040800000;
    @(posedge clk);
    //{18{-1 - j1}}, expected = {18{sqrt(2)}}
    eighteenNums <= 1152'hbf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000bf800000;
    @(posedge clk);
    //{18{20*e - j*17*pi}}, expected = {18{76.2098294938854}}
    eighteenNums <= 1152'h425976694259766942597669425976694259766942597669425976694259766942597669425976694259766942597669425976694259766942597669425976694259766942597669c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8c255a0d8;
    @(posedge clk);
    wait(doneEighteen);
    repeat(5)@(posedge clk);
end


endmodule
