`timescale 1ns / 1ps

`define DEBUG

module AlphaProfile
#(
    localparam ReImWidth = 32, //Single precision floats, 1 + 8 + 23 bits
    localparam CmplxWidth = 2*ReImWidth,
    localparam FFT_Pts = 32
)
(
    input [FFT_Pts*CmplxWidth-1:0] FFT_Result_In,
    input FFT_DataValid,
    input clk,
    input reset,
    
    output AlphaProfile_Done,
    output [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfBRAMOut1Output, alphaProfBRAMOut2Output,
    
    output [FFT_Pts/4*ReImWidth - 1 : 0] AlphaProf_EightSamples, AlphaProf_FinalEightSamples,
    output AlphaProf_EightSamplesValid
);

genvar i;

//Wire declarations
//Selects the 16 samples we need from the incoming 32 Pts of FFT data
wire [FFT_Pts/2*CmplxWidth-1:0] FFT_Result_In_Reduced;

//Holds the absolute values of those 16 samples we've been given
wire [FFT_Pts/2*ReImWidth-1:0] absValNums;
wire absValDone;

//Registers the absolute value numbers and reverses their order to change them from decreasing (24 23 22 ...) to increasing (7 8 9 ...) order
wire [FFT_Pts/2*ReImWidth-1:0] absValNums_RegOut, absValNums_RegOut_rev;
wire absValDone_RegOut;

//Old wire that used to be where the 16 samples we need were chopped off from absValNums_RegOut. Now, they're just identical
wire [FFT_Pts/2*ReImWidth-1:0] mergedFFTSamples;

//Add another layer of registers and commute the data to align it with the correct memory
wire [FFT_Pts/2*ReImWidth-1:0] mergedFFTSamples_RegOut, mergedFFTSamples_RegOut_Commuted, mergedFFTSamples_RegOut_Commuted_RegOut;
wire mergedFFTValid_RegOut;

//Multiplex the data for the max operation between the memory data and the previous cycle's data as a use of "forwarding"
wire [FFT_Pts/4*ReImWidth-1:0] alphaProf_BRAM_PrevCycle_MuxOut1, alphaProf_BRAM_PrevCycle_MuxOut2;

wire prevCycleDataBitTop, prevCycleDataBitBot;

//Holds the output words from the alphaProf BRAM that we're comparing against
wire [FFT_Pts/2*ReImWidth-1:0] alphaProfMaxOut, alphaProfMaxOut_RegOut, alphaProfBRAMOut, alphaProfBRAMOut_RegOut;
wire [FFT_Pts/4*ReImWidth-1:0] alphaProfBRAMOut1, alphaProfBRAMOut2;

//Signals for the write and read addresses of each memory
wire [8:0] Controller_wrAddr1, Controller_wrAddr2, Controller_wrAddr1_RegOut, Controller_wrAddr2_RegOut, Controller_wrAddr1_RegOut2, Controller_wrAddr2_RegOut2, Controller_rdAddr1, Controller_rdAddr2;
wire Controller_writeEn, Controller_writeEn_RegOut;

wire EightSamplesReady, EightSamplesReady_RegOut;
wire AlphaProfileDone, AlphaProfileDone_RegOut;
wire isLastStage, isLastStage_RegOut;
reg EightSamples_SelectionBit = 1'b1;

`ifdef DEBUG
//Useful signals to have in the simulation window that group all the data into individual words so you don't need to manually
wire [ReImWidth-1:0] TopBRAM_DataInReindexed [0:FFT_Pts/4-1];
wire [ReImWidth-1:0] BotBRAM_DataInReindexed [0:FFT_Pts/4-1];
wire [ReImWidth-1:0] TopBRAM_CommutatedSamples [0:FFT_Pts/4-1];
wire [ReImWidth-1:0] BotBRAM_CommutatedSamples [0:FFT_Pts/4-1];
generate
    for (i = 0; i < FFT_Pts/4; i = i + 1) begin
        assign TopBRAM_DataInReindexed[i] = alphaProfMaxOut_RegOut[(FFT_Pts/2 - i)*ReImWidth - 1 -: ReImWidth];
        assign BotBRAM_DataInReindexed[i] = alphaProfMaxOut_RegOut[(FFT_Pts/4 - i)*ReImWidth - 1 -: ReImWidth];
        
        assign TopBRAM_CommutatedSamples[i] = mergedFFTSamples_RegOut_Commuted[(FFT_Pts/2 - i)*ReImWidth - 1 -: ReImWidth];
        assign BotBRAM_CommutatedSamples[i] = mergedFFTSamples_RegOut_Commuted[(FFT_Pts/4 - i)*ReImWidth - 1 -: ReImWidth];
    end
endgenerate;
`endif


//------------ 1. Select the samples we need from the incoming FFT_Result_In data--------------//

//Just grab the middle 16 FFT samples. The matlab script only takes the outer 8 from each side because of fftshift, but we don't have that
//We end up using samples 7, 8, 9, 10, 11, 12, 13, 14, 15, 18, 19, 20, 21, 22, 23, 24
//Real components
assign FFT_Result_In_Reduced[FFT_Pts/2*ReImWidth + 1*FFT_Pts/2*ReImWidth - 1 -: FFT_Pts/2*ReImWidth] = 
    {FFT_Result_In[(FFT_Pts - 7)*ReImWidth + 1*FFT_Pts*ReImWidth - 1 -: 7*ReImWidth], FFT_Result_In[(FFT_Pts - 16)*ReImWidth + 1*FFT_Pts*ReImWidth - 1 -: 9*ReImWidth]};

//Imaginary components
assign FFT_Result_In_Reduced[FFT_Pts/2*ReImWidth + 0*FFT_Pts/2*ReImWidth - 1 -: FFT_Pts/2*ReImWidth] =
    {FFT_Result_In[(FFT_Pts - 7)*ReImWidth + 0*FFT_Pts*ReImWidth - 1 -: 7*ReImWidth], FFT_Result_In[(FFT_Pts - 16)*ReImWidth + 0*FFT_Pts*ReImWidth - 1 -: 9*ReImWidth]};

//------------- 2. Calculate the pairwise absolute values of each of those elements -------------//
FloP_C_PairwiseAbs 
#(
    .numNums(FFT_Pts/2)
) pairwiseAbs(
    .complexNums(FFT_Result_In_Reduced),
    //.complexNums(FFT_Reduced_Result_In),
    .dataValid(FFT_DataValid),
    .clk(clk),
    .reset(reset),
    .absVals(absValNums),
    .done(absValDone)
);

//-------------- 3. Register those absolute value values --------------//

//Put pipeline registers for good measure
NBitReg #(.dataWidth(FFT_Pts/2*ReImWidth)) absValReg(
    .clk(clk),
    .reset(reset),
    .dataIn(absValNums),
    .writeEn(1'b1),
    .dataOut(absValNums_RegOut)
);
//Need to pass along the data valid signal as well
NBitReg #(.dataWidth(1)) absValDataValidReg(
    .clk(clk),
    .reset(reset),
    .dataIn(absValDone),
    .writeEn(1'b1),
    .dataOut(absValDone_RegOut)
);

//------------- 4. Flip the ordering of those absolute value values ----------------//
//Flip the absValDone_RegOut values so that instead of being {24, 23, 22, 21, ..., 8, 7}, it's {7, 8, 9, 10, ..., 23, 24}
generate
    for (i = 0; i < FFT_Pts/2; i = i + 1) begin
        assign absValNums_RegOut_rev[ReImWidth*(i+1) - 1 -: ReImWidth] = absValNums_RegOut[ReImWidth*(FFT_Pts/2-i) - 1 -: ReImWidth];
    end
endgenerate

//------------- 5. Pass those values onto another wire and set of registers --------------//
//Update: absValNums_RegOut_rev already contains the selected samples
assign mergedFFTSamples = absValNums_RegOut_rev;

//We need to read from the memory in chunks of 8 samples, but the alpha profile is updated in chunks of 16 samples
//Port1 of the BRAM is "lower" addresses, but we're using a Matrix style notation where "lower" addresses are "higher" in the matrix (i.e. lower rows are in the top of a matrix)
assign alphaProfBRAMOut = {alphaProfBRAMOut1, alphaProfBRAMOut2};
//These two are listed as "1+1" because they originally already had a one cycle delay when wrAddr1, etc, had none, so since they're needed in the next stage
//And thus by the notation listed below, they would have a delay of 1 cycle, they actually need 2 cycles to maintain the original alignment
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(FFT_Pts/2*ReImWidth)) mergedFFTReg(
    .clk(clk), .reset(reset), .dataIn(mergedFFTSamples), .writeEn(1'b1), .dataOut(mergedFFTSamples_RegOut)
);
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(1)) mergedFFTValidReg(
    .clk(clk), .reset(reset), .dataIn(absValDone_RegOut), .writeEn(1'b1), .dataOut(mergedFFTValid_RegOut)
);
NBit_DelayReg #(.cyclesToDelay(2), .dataWidth(1)) EightSamplesReadyReg(
    .clk(clk), .reset(reset), .dataIn(EightSamplesReady), .writeEn(1'b1), .dataOut(EightSamplesReady_RegOut)
);
NBit_DelayReg #(.cyclesToDelay(2), .dataWidth(1)) AlphaProfDoneReg(
    .clk(clk), .reset(reset), .dataIn(AlphaProfileDone), .writeEn(1'b1), .dataOut(AlphaProfileDone_RegOut)
);
NBit_DelayReg #(.cyclesToDelay(2), .dataWidth(1)) isLastStageReg(
    .clk(clk), .reset(reset), .dataIn(isLastStage), .writeEn(1'b1), .dataOut(isLastStage_RegOut)
);


//------------------ 6. Commute the data to align it with its correct memory, etc, for the given iteration -------------------//
//Swap the data if necessary *before* the comparisons
alphaProf_Commutator #(.dataWidth(FFT_Pts/4*ReImWidth)) dataSwapper(
    .dataIn1(mergedFFTSamples_RegOut[(FFT_Pts/2)*ReImWidth - 1 -: (FFT_Pts/4)*ReImWidth]),
    .dataIn2(mergedFFTSamples_RegOut[(FFT_Pts/4)*ReImWidth - 1 -: (FFT_Pts/4)*ReImWidth]),
    .swapInputs(Controller_wrAddr1[0]),
    .dataOut1(mergedFFTSamples_RegOut_Commuted[(FFT_Pts/2)*ReImWidth - 1 -: (FFT_Pts/4)*ReImWidth]),
    .dataOut2(mergedFFTSamples_RegOut_Commuted[(FFT_Pts/4)*ReImWidth - 1 -: (FFT_Pts/4)*ReImWidth])
);

//-------------Data Needed in Next Cycle------------//
//Needed in maxes: Yes; Needed in write to memory: No => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(FFT_Pts/2*ReImWidth)) commutedSamplesReg(
    .clk(clk), .reset(reset), .dataIn(mergedFFTSamples_RegOut_Commuted), .writeEn(1'b1), .dataOut(mergedFFTSamples_RegOut_Commuted_RegOut)
);
//Needed in commutator: No; Needed in maxes: Yes; Needed in write to memory: No => 1 cycles
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(FFT_Pts/2*ReImWidth)) alphaProfBRAMOutReg(
    .clk(clk), .reset(reset), .dataIn(alphaProfBRAMOut), .writeEn(1'b1), .dataOut(alphaProfBRAMOut_RegOut)
);

//Needed in maxes: Yes; Needed in write to memory: Yes => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(9)) wrAddr1Reg2(
    .clk(clk), .reset(reset), .dataIn(Controller_wrAddr1), .writeEn(1'b1), .dataOut(Controller_wrAddr1_RegOut)
);
//Needed in commutator: No; Needed in maxes: Yes; Needed in write to memory: Yes => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(9)) wrAddr2Reg(
    .clk(clk), .reset(reset), .dataIn(Controller_wrAddr2), .writeEn(1'b1), .dataOut(Controller_wrAddr2_RegOut)
);
//Needed in commutator: No; Needed in maxes: No; Needed in write to memory: Yes => 2 cycles
NBit_DelayReg #(.cyclesToDelay(2), .dataWidth(1)) wrEnReg(
    .clk(clk), .reset(reset), .dataIn(Controller_writeEn), .writeEn(1'b1), .dataOut(Controller_writeEn_RegOut)
);

//------------------- 7. Perform the max comparisons between the alpha profile data and the incoming FFT data ----------------------//

//Mux between the previous cycle's output and the BRAM data
//If the current write address is less than the current read address, then we started a new SCD matrix "staircase"
//And thus we shouldn't perform data "forwarding"

//assign prevCycleDataBitTop = (Controller_wrAddr2_RegOut[0] == 0 && Controller_wrAddr2_RegOut[8:1] == Controller_wrAddr2_RegOut2[8:1]);
//assign prevCycleDataBitBot = (Controller_wrAddr1_RegOut[0] == 0 && Controller_wrAddr1_RegOut[8:1] == Controller_wrAddr1_RegOut2[8:1]);
assign prevCycleDataBitTop = (Controller_wrAddr2_RegOut[8:1] == Controller_wrAddr2_RegOut2[8:1] && Controller_wrAddr2_RegOut > Controller_rdAddr2);
assign prevCycleDataBitBot = (Controller_wrAddr1_RegOut[8:1] == Controller_wrAddr1_RegOut2[8:1] && Controller_wrAddr1_RegOut > Controller_rdAddr1);


assign alphaProf_BRAM_PrevCycle_MuxOut1 = prevCycleDataBitTop ? 
    alphaProfMaxOut_RegOut[FFT_Pts/2*ReImWidth - 1 -: FFT_Pts/4*ReImWidth] : alphaProfBRAMOut_RegOut[FFT_Pts/2*ReImWidth - 1 -: FFT_Pts/4*ReImWidth];
assign alphaProf_BRAM_PrevCycle_MuxOut2 = prevCycleDataBitBot ? 
    alphaProfMaxOut_RegOut[FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth] : alphaProfBRAMOut_RegOut[FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth];

//Generate the comparators/max modules (which are just comparators with a mux)
generate
    for (i = 0; i < FFT_Pts/4; i = i + 1) begin
        FloP_Max #(.expWidth(8), .fracWidth(23)) alphaMaxer(
//            .dataIn1(alphaProfBRAMOut_RegOut[(FFT_Pts/2-i)*ReImWidth - 1 -: ReImWidth]), 
            .dataIn1(alphaProf_BRAM_PrevCycle_MuxOut1[(FFT_Pts/4-i)*ReImWidth - 1 -: ReImWidth]),
            .dataIn2(mergedFFTSamples_RegOut_Commuted_RegOut[(FFT_Pts/2-i)*ReImWidth - 0*FFT_Pts/4*ReImWidth - 1 -: ReImWidth]), //mergedFFTSamples_RegOut[FFT_Pts/2*ReImWidth - ReImWidth*i - 1 -: ReImWidth]
            .max(alphaProfMaxOut[(FFT_Pts/2-i)*ReImWidth - 0*FFT_Pts/4*ReImWidth - 1 -: ReImWidth])//alphaProfMaxOut[FFT_Pts/2*ReImWidth - ReImWidth*i - 1 -: ReImWidth
        );
    end
    
    for (i = 0; i < FFT_Pts/4; i = i + 1) begin
        FloP_Max #(.expWidth(8), .fracWidth(23)) alphaMaxer(
//            .dataIn1(alphaProfBRAMOut_RegOut[(FFT_Pts/2-i)*ReImWidth - 1 -: ReImWidth]), 
            .dataIn1(alphaProf_BRAM_PrevCycle_MuxOut2[(FFT_Pts/4-i)*ReImWidth - 1 -: ReImWidth]),
            .dataIn2(mergedFFTSamples_RegOut_Commuted_RegOut[(FFT_Pts/2-i)*ReImWidth - 1*FFT_Pts/4*ReImWidth - 1 -: ReImWidth]), //mergedFFTSamples_RegOut[FFT_Pts/2*ReImWidth - ReImWidth*i - 1 -: ReImWidth]
            .max(alphaProfMaxOut[(FFT_Pts/2-i)*ReImWidth - 1*FFT_Pts/4*ReImWidth - 1 -: ReImWidth])//alphaProfMaxOut[FFT_Pts/2*ReImWidth - ReImWidth*i - 1 -: ReImWidth
        );
    end
endgenerate

//Needed in write to memory: Yes => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(FFT_Pts/2*ReImWidth)) alphaProfMaxOutReg(
    .clk(clk), .reset(reset), .dataIn(alphaProfMaxOut), .writeEn(1'b1), .dataOut(alphaProfMaxOut_RegOut)
);
//Needed in write to memory: Yes => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(9)) wrAddr1Reg3(
    .clk(clk), .reset(reset), .dataIn(Controller_wrAddr1_RegOut), .writeEn(1'b1), .dataOut(Controller_wrAddr1_RegOut2)
);
//Needed in write to memory: Yes => 1 cycle
NBit_DelayReg #(.cyclesToDelay(1), .dataWidth(9)) wrAddr2Reg2(
    .clk(clk), .reset(reset), .dataIn(Controller_wrAddr2_RegOut), .writeEn(1'b1), .dataOut(Controller_wrAddr2_RegOut2)
);

//-------------------- 8. Merge those results into the two alpha profile BRAMs -----------------------//

// NEWEST CODE: USES TWO SimpleDualPortRAM components to allow for independent read and write operations (read one cycle ahead of where the write will occur)

//"Top" and "Bottom" are oriented relative to matrix indexing, so they may be upside down from expected

//Memory that handles the top 8 elements in each 16 element block. Port "1" (i.e. addr1) is for writing, port "2" (i.e. addr2) is for reading
//"Odd" addresses I think
SimpleDualPortRAM #(.wordWidth(256), .addrSize(8)) topAddrsAlphaProfBRAM
(
    .clk(clk),
    .en1(1'b1), 
    .en2(1'b1), 
    .we1(Controller_writeEn_RegOut),
    //WrAddr
    .addr1(Controller_wrAddr2_RegOut2[8:1]),
    //RdAddr 
    .addr2(Controller_rdAddr2[8:1]),
    .dataIn1(alphaProfMaxOut_RegOut[FFT_Pts/2*ReImWidth - 0*FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth]),
    .dataOut2(alphaProfBRAMOut1)
);

//Memory that handles the bottom 8 elements in each 16 element block. Port "1" is for writing, port "2" is for reading
//"Even" addresses I think
SimpleDualPortRAM #(.wordWidth(256), .addrSize(8)) bottomAddrsAlphaProfBRAM
(
    .clk(clk),
    .en1(1'b1), 
    .en2(1'b1), 
    .we1(Controller_writeEn_RegOut),
    //WrAddr
    .addr1(Controller_wrAddr1_RegOut2[8:1]),
    //RdAddr 
    .addr2(Controller_rdAddr1[8:1]),
    .dataIn1(alphaProfMaxOut_RegOut[FFT_Pts/2*ReImWidth - 1*FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth]),
    .dataOut2(alphaProfBRAMOut2)
);

//And create two controllers (write & read) to deal with it all
//Two identical controllers, but the second one (for reads) starts one cycle earlier and is thus always one step ahead
AlphaProfileController_Datapath writeController_datapath(
    //dataValid is an input that tells the state machine to start
    .dataValid(mergedFFTValid_RegOut),
    .reset(reset),
    .clk(clk),
    .Addr1(Controller_wrAddr1),
    .Addr2(Controller_wrAddr2),
    .AlphaProfDone(AlphaProfileDone),
    .BRAM_WriteEn(Controller_writeEn),
    .EightSamplesReady(EightSamplesReady),
    .isLastStage(isLastStage)
);

//absValDone_RegOut will trigger one cycle before mergedFFTValid_RegOut does, so this state machine starts one cycle earlier
AlphaProfileController_Datapath readController_datapath(
    //dataValid is an input that tells the state machine to start
    .dataValid(absValDone_RegOut),
    .reset(reset),
    .clk(clk),
    .Addr1(Controller_rdAddr1),
    .Addr2(Controller_rdAddr2),
    //Don't need either of these on this controller as it only controls reading
    .AlphaProfDone(),
    .BRAM_WriteEn(),
    .EightSamplesReady(),
    .isLastStage()
);

assign alphaProfBRAMOut1Output = alphaProfBRAMOut1;
assign alphaProfBRAMOut2Output = alphaProfBRAMOut2;

//If selectionBit is 0, then choose the ones from the "even" memory, since those will be the first 8 samples to finish computation at the top of the first "staircase"
//Then, flip this bit every time 8 samples finish so that after the next staircase finishes, it will pick the samples going into the "odd" memory, etc.
assign AlphaProf_EightSamples = (EightSamples_SelectionBit == 1'b0) ? alphaProfMaxOut_RegOut[FFT_Pts/2*ReImWidth - 1*FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth] :
                                                                      alphaProfMaxOut_RegOut[FFT_Pts/2*ReImWidth - 0*FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth];

//We know that the final eight samples will be going into the "odd" memory by the structure of the alpha profile vector/SCD matrix
//The alpha profile memory has a structure of 0 to 4095 with 0 to 2047 as the "first half" and 2048 to 4097 as the "second half".
//In our case, it's 0 to 511 8-sample words with 0 to 255 as the "first half" and 256 to 511 as the "second half".
//The AlphaProf_EightSamples vector should grab the piece going into address 256 (which is address 128 of the "even memory")
//So the AlphaProf_FinalEightSamples vector should grab the other 8 samples -- going into address 255 (which is address 127 of the "odd" memory)
assign AlphaProf_FinalEightSamples = alphaProfMaxOut_RegOut[FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth];

assign AlphaProf_EightSamplesValid = EightSamplesReady_RegOut || isLastStage_RegOut;
//When AlphaProf_Done fires, record the full 16 samples on the commonDataBus -- not just the upper 8
assign AlphaProfile_Done = AlphaProfileDone_RegOut;

always @(posedge(clk)) begin
    if (EightSamplesReady_RegOut || isLastStage_RegOut) begin
        EightSamples_SelectionBit <= ~EightSamples_SelectionBit;
    end
end

endmodule