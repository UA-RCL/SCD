`timescale 1ns / 1ps

`include "CLOG2_vh.vh"

module SCD_AlphaProf_Top
#(
    parameter numLanes = 8,
    //TODO: build the actual windowing function ROM
    parameter WindowingFuncFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/hamming_rom_file.txt",
    //TODO: build the actual down conversion ROM
    parameter DownConvFilenames = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k0.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k1.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k2.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k3.txt",
    parameter DownConvFilenameLength = 105,
    
    //Don't actually change these, they're just meant to connect with terms from the paper
    //Decides Initial FFT Pts & Windowing/DownConv ROM sizes
    localparam Np = 256,
    //Decides ConjProd FFT Pts
    localparam P = 32,
    
    localparam ReImWidth = 32,
    localparam CmplxWidth = 2*ReImWidth,
    //More intuitive way of recognizing what Np influences
    localparam numWords = Np,
    
    //The size of the FFT used in the ConjProd Iterative FFT section
    localparam FFT_Pts = 32
)
(
    //Assuming the data is coming in the form {(Re, Im), (Re, Im), (Re, Im), ...}
    //Complex Sample 0 is at the MSB (leftmost) and proceeds forward through Sample 1, 2, ...
    //input [numLanes*CmplxWidth - 1 : 0] signalData,
    inout [numLanes*CmplxWidth - 1 : 0] commonDataBus,
    input dataValid,
    input clk_P,
    input clk_N,
    input reset,
    
    output ConjProd_Done,
    output AlphaProf_Done,
    //This signal is 1 for a single cycle every 256 cycles. It indicates that the next 8 values of the alpha profile can be saved during *that cycle*
    //They will consist of the first half of the common data bus
    output AlphaProf_EightSamplesValid
);

//Wire to hold the non-differential clock that's been converted from the differential pair
wire clk;

//Wires to hold the input and output datas that come from the common iobuf tristate buffer
wire [numLanes*CmplxWidth - 1 : 0] signalData;
wire [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfBRAMOut1Output, alphaProfBRAMOut2Output;
wire [FFT_Pts/2*ReImWidth - 1 : 0] alphaProfBRAMOutput;

wire [FFT_Pts/2*ReImWidth - 1 : 0] alphaProfOutput;
wire [FFT_Pts/4*ReImWidth - 1 : 0] AlphaProf_EightSamples, AlphaProf_FinalEightSamples;
wire [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfOutput_LSB_EightSamples;

wire AlphaProfDone;

assign alphaProfBRAMOutput = {alphaProfBRAMOut1Output, alphaProfBRAMOut2Output};

assign alphaProfOutput_LSB_EightSamples = (AlphaProfDone == 1'b1) ? AlphaProf_FinalEightSamples : {{FFT_Pts/4*ReImWidth}{1'b0}};
assign alphaProfOutput = {AlphaProf_EightSamples, alphaProfOutput_LSB_EightSamples};

assign AlphaProf_Done = AlphaProfDone;

IBUFGDS myIBUFGDS(
    .I(clk_P),
    .IB(clk_N),
    .O(clk)
);

generate
genvar i;
for (i = 0; i < numLanes*CmplxWidth; i = i + 1) begin: IOBUF_Loop
    IOBUF myIOBUF(
        //Old version: took what was from the read data of the memories. Reading data is time wasted when we could be computing!
        //.I(alphaProfBRAMOutput[i]),
        //Therefore, just "catch" all the data as it is finished being computed by the alpha profile as it does it! (it gets a bit crazy in the last 256 iterations though...)
        .I(alphaProfOutput[i]),
        .O(signalData[i]),
        .T(dataValid),
        .IO(commonDataBus[i])
    );
end
endgenerate

wire [numLanes*CmplxWidth - 1 : 0] downConvData;
wire downConv_dataValidOut;

reg [(`CLOG2(Np*(P/numLanes)))-1:0] ConjProdAddress = 0;
wire [3:0] ConjProdWrEns;
wire startConjProdFFT;

Window_FFT_DownConv #(
    .numLanes(numLanes), .WindowingFuncFilename(WindowingFuncFilename), .DownConvFilenames(DownConvFilenames), .DownConvFilenameLength(DownConvFilenameLength)
) w_fft_dc (
    .signalData(signalData),
    .dataValid(dataValid),
    .clk(clk),
    .reset(reset),
    
    .downConvData(downConvData),
    .downConv_dataValidOut(downConv_dataValidOut)
);

ConjProdAlphaProf_Top alphaProfiler(
    .start(startConjProdFFT),
    .clk(clk),
    .reset(reset),
    
    .dataIn1(downConvData),
    //Old version, ignored FFT Shifting
    //.wrAddr1(ConjProdAddress[7:0]),
    //New version, equivalent to FFT Shifting
    .wrAddr1(ConjProdAddress[7:0] + 8'b10000000),
    .writeEns1(ConjProdWrEns),
    
    .ConjProd_Done(ConjProd_Done),
    .AlphaProf_Done(AlphaProfDone),
    .alphaProfBRAMOut1Output(alphaProfBRAMOut1Output), .alphaProfBRAMOut2Output(alphaProfBRAMOut2Output),
    .AlphaProf_EightSamples(AlphaProf_EightSamples),
    .AlphaProf_FinalEightSamples(AlphaProf_FinalEightSamples),
    .AlphaProf_EightSamplesValid(AlphaProf_EightSamplesValid)
);

//Small state machine that controls writing the data into Conjugate Product FFT
always @(posedge clk) begin
    if (reset) begin
        ConjProdAddress <= 0;
    end
    if (downConv_dataValidOut) begin
        ConjProdAddress <= ConjProdAddress + 1;
    end
end

assign startConjProdFFT = ConjProdAddress == 1023;

//Lazy Demultiplexer
assign ConjProdWrEns = (downConv_dataValidOut == 1'b0) ? 4'b0000 : 
                       (downConv_dataValidOut == 1'b1 && ConjProdAddress[9:8] == 2'b00) ? 4'b1000 :
                       (downConv_dataValidOut == 1'b1 && ConjProdAddress[9:8] == 2'b01) ? 4'b0100 :
                       (downConv_dataValidOut == 1'b1 && ConjProdAddress[9:8] == 2'b10) ? 4'b0010 :
                       (downConv_dataValidOut == 1'b1 && ConjProdAddress[9:8] == 2'b11) ? 4'b0001 : 4'b0000;


endmodule
