`timescale 1ns / 1ps

`include "CLOG2_vh.vh"

module ConjProdFFT_32Pt_TopController
#(
    localparam ReImWidth = 32,
    localparam CmplxWidth = 2*ReImWidth,
    localparam FFT_Pts = 32,
    localparam AlphaProfPts = 16,
    localparam numMemories = 4
)
(
    input start,
    input clk,
    input reset,
    
    input [(FFT_Pts/4)*CmplxWidth-1:0] dataIn1,
    input [(`CLOG2(256))-1:0] wrAddr1,
    input [numMemories-1:0] writeEns1,

    output ConjProdDone,     //The first of these is to let whatever module know that the entire state machine is done and all conj prod ffts have been computed
    output ConjProdDataValid,//The second of these is to let the AlphaProfile stage know that the FFT data that it is receiving is valid and should be used to update things
    
    //Output the samples in the format {Re[31], Re[30], ..., Re[24], Re[9], Re[8], ..., Re[0], Im[31], Im[30], ..., Im[24], Im[9], Im[8], ..., Im[0]}
    output [FFT_Pts*CmplxWidth-1:0] ConjProdFFTOut
);

//Define states
localparam 
    init = 0,
    readDataAndCheckConditions = 1,
    waitToFinish = 2,
    doneState = 3;
//State registers
reg [1:0] CS; 
wire [1:0] NS;

//Wires for FFT Outputs
wire [FFT_Pts*ReImWidth-1:0] FFT_Output_Real, FFT_Output_Imag;
//Address to write the FFT results into
//wire [15:0] Wr_Addr;
//Write enable for writing the FFT results
//wire Wr_writeEn;
//Addresses for reading from the input BRAM
wire [7:0] R_addr1, R_addr2;//, R_addr1_dummyOut, R_addr2_dummyOut;
wire [7:0] MuxedAddr1, MuxedAddr2;
//Only allow writing in new data if we're in the idle state -- otherwise, we're computing
wire globalWrEn;
//Whether or not the data is valid
wire dataValid;

//Wires for holding the words that come out of the input BRAM
wire [FFT_Pts*CmplxWidth-1:0] R_word1, R_word2;

//Wires for carrying the clock and the FPGA's done signal
//wire clk; 
wire FFT_Done;

//Mux the read address and write address so that we write when idle and read when not idle
assign MuxedAddr1 = (globalWrEn == 1'b1) ? wrAddr1 : R_addr1;

//Next, instantiate the BRAMs for inputting data
generate
    genvar i;
    for (i = 0; i < numMemories; i = i + 1) begin: generateLoop
        FFT_Input_BRAM myRAM_IP (
            .clka(clk),    // input wire clka
            .wea(writeEns1[3-i] && globalWrEn),      // input wire [0 : 0] wea
            .addra(MuxedAddr1),  // input wire [7 : 0] addra
            .dina(dataIn1),    // input wire [1023 : 0] dina
            .douta(R_word1[FFT_Pts*CmplxWidth - 512*i - 1 -: 512]),  // output wire [1023 : 0] douta
            .clkb(clk),    // input wire clkb
            .web(1'b0),      // input wire [0 : 0] web
            .addrb(R_addr2),  // input wire [7 : 0] addrb
            .dinb(512'b0),    // input wire [1023 : 0] dinb
            .doutb(R_word2[FFT_Pts*CmplxWidth - 512*i - 1 -: 512])  // output wire [1023 : 0] doutb
        );
    end
endgenerate

//Then, instantiate the ConjProdFFT datapath
ConjProdFFT_32Pt_Datapath myIterativeFFT(
    .clk(clk),
    .reset(reset),
    
    .R_word1(R_word1),
    .R_word2(R_word2),
    .dataValid(dataValid),
    
    .FFT_Output_Real(FFT_Output_Real),
    .FFT_Output_Imag(FFT_Output_Imag),
    .FFT_Done(FFT_Done)
);

//And last, but not least, some place to store the newly generated data
//All it really needs to be is a single 1152 bit (18 FFT Points) register

//Output the samples in the format {Re[31], Re[30], ..., Re[24], Re[9], Re[8], ..., Re[0], Im[31], Im[30], ..., Im[24], Im[9], Im[8], ..., Im[0]}
NBitReg #(.dataWidth(FFT_Pts*CmplxWidth)) iterativeFFT_dataOutReg(
    .clk(clk),
    //Top 8 elements, Bottom 10 elements
    //.dataIn({FFT_Output_Real[1023:768], FFT_Output_Real[319:0], FFT_Output_Imag[1023:768], FFT_Output_Imag[319:0]}),
    .dataIn({FFT_Output_Real, FFT_Output_Imag}),
    .writeEn(FFT_Done),
    .reset(reset),
    .dataOut(ConjProdFFTOut)
);

//Add a register for the done signal so that it is in sync with when the FFT Sample data becomes available to the AlphaProfile module
NBit_DelayReg #(.cyclesToDelay(2), .dataWidth(1)) doneReg(
    .clk(clk),
    .dataIn(FFT_Done),
    .writeEn(1'b1),
    .reset(reset),
    .dataOut(ConjProdDataValid)
);

//And do this to hopefully get everything to synthesize nicely
//It performs a reductive xor on all of the bits of this output
//assign FFT_Output_XOR = (^ {FFT_Output_Real, FFT_Output_Imag});

//-----------------------------Controller Logic-----------------------------//
initial begin
    CS <= init;
end

//Signals to be used inside the controller's datapath
wire addr1_ld, addr2_ld, wr_addr_ld, addr1_clr, addr2_clr, wr_addr_clr, doneFeedingData;

//Combinational logic to support the state machine's datapath
//Note: these used to be backwards. Might need to update a diagram or two
assign addr1_ld = (R_addr2 == 255) && (R_addr1 < 255) && (CS == readDataAndCheckConditions);
assign addr2_ld = (R_addr2 < 255) && (CS == readDataAndCheckConditions);

assign wr_addr_ld = (FFT_Done);

assign addr1_clr = (CS != readDataAndCheckConditions);
assign addr2_clr = (CS != readDataAndCheckConditions) | (R_addr2 == 255);
assign wr_addr_clr = (CS == init);

//Turn these into externally accessible ports and act as a passive module that allows for writing in new data when we're idle
assign globalWrEn = (CS == init);

assign dataValid = (CS == readDataAndCheckConditions);
assign doneFeedingData = (R_addr1 == 255 && R_addr2 == 255);
assign ConjProdDone = (CS == doneState);

assign NS = (CS == init && !start) ? init : 
            (CS == init && start) ? readDataAndCheckConditions :
            (CS == readDataAndCheckConditions && !doneFeedingData) ? readDataAndCheckConditions :
            (CS == readDataAndCheckConditions && doneFeedingData) ? waitToFinish :
            (CS == waitToFinish && FFT_Done) ? waitToFinish :
            (CS == waitToFinish && !FFT_Done) ? doneState : init;

//Controller datapath
ConjProdController_Datapath controllerPath(
    .clk(clk),
    .addr1_ld(addr1_ld),    .addr1_clr(addr1_clr),
    .addr2_ld(addr2_ld),    .addr2_clr(addr2_clr),
    .wr_addr_ld(wr_addr_ld),.wr_addr_clr(wr_addr_clr),
    
    .Addr1_Out(R_addr1),
    .Addr2_Out(R_addr2),
    .Wr_Addr_Out(Wr_Addr)
);

//Every rising edge, state transition
always @(posedge clk) begin
    if (reset) begin
        CS <= init;
    end
    else begin 
        CS <= NS;
    end
end

endmodule