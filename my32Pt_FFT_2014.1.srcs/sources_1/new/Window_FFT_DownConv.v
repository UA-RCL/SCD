`timescale 1ns / 1ps

`include "CLOG2_vh.vh"

module Window_FFT_DownConv
#(
    parameter numLanes = 8,
    //TODO: build the actual windowing function ROM
    parameter WindowingFuncFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_rom_file.txt",
    //TODO: build the actual down conversion ROM
    parameter DownConvFilenames = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_complex_rom_file.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_complex_rom_file.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_complex_rom_file.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_complex_rom_file.txt",
    parameter DownConvFilenameLength = 122,
    
    //Don't actually change these, they're just meant to connect with terms from the paper
    //Decides Initial FFT Pts & Windowing/DownConv ROM sizes
    localparam Np = 256,
    //Decides ConjProd FFT Pts
    localparam P = 32,
    
    localparam ReImWidth = 32,
    localparam CmplxWidth = 2*ReImWidth,
    //More intuitive way of recognizing what Np influences
    localparam numWords = Np
)
(
    //Assuming the data is coming in the form {(Re, Im), (Re, Im), (Re, Im), ...}
    //Complex Sample 0 is at the MSB (leftmost) and proceeds forward through Sample 1, 2, ...
    input [numLanes*CmplxWidth - 1 : 0] signalData,
    input dataValid,
    input clk,
    input reset,
    output [numLanes*CmplxWidth - 1 : 0] downConvData,
    output downConv_dataValidOut
);

wire [numLanes*CmplxWidth - 1 : 0] windowedData;
wire [numLanes - 1 : 0] windowedData_dataValidOut;

wire [numLanes*CmplxWidth - 1 : 0] FFT_Data;
wire [numLanes - 1 : 0] FFT_dataValidOut;

genvar i;
generate

//First, do the windowing multipliers
//Generate numLanes Re/Im coeff mult pairs
for (i = 0; i < numLanes; i = i + 1) begin: windowingBlock
    CoeffMult #(.numWords(numWords), .ROMFilename(WindowingFuncFilename), .ROMFiletype("b")) ReMult(
        .currentSample(
            signalData[(numLanes-i)*CmplxWidth - ReImWidth*0 - 1 -: ReImWidth]
         ),
        .dataValid(dataValid), .start(dataValid), .stop(~dataValid), .clk(clk),
        .product(
            windowedData[(numLanes-i)*CmplxWidth - ReImWidth*0 - 1 -: ReImWidth]
         ),
        .dataValid_out(windowedData_dataValidOut[numLanes - i - 1])  
    );
    CoeffMult #(.numWords(numWords), .ROMFilename(WindowingFuncFilename), .ROMFiletype("b")) ImMult(
        .currentSample(
            signalData[(numLanes-i)*CmplxWidth - ReImWidth*1 - 1 -: ReImWidth]
         ),
        .dataValid(dataValid), .start(dataValid), .stop(~dataValid), .clk(clk),
        .product(
            windowedData[(numLanes-i)*CmplxWidth - ReImWidth*1 - 1 -: ReImWidth]
         ),
        .dataValid_out()
    );
end

//Take the output from those and pass through FFTs
//Generate numLanes Initial256PtFFTs
for (i = 0; i < numLanes; i = i + 1) begin: FFTsBlock
    Initial256PtFFT my256PtFFT (
      .aclk(clk),
      //This could totally make the FFT not function properly, but oh well, let's see what it does
      .s_axis_config_tdata(16'd0),
      .s_axis_config_tvalid(1'b1),
      .s_axis_config_tready(),
      
      //This is the actual piece we care about -- how to send data into the FFT
      .s_axis_data_tdata(windowedData[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]),
      //Me telling the core my incoming data is valid
      .s_axis_data_tvalid(windowedData_dataValidOut[numLanes - i - 1]),
      //The core telling me that it's ready to accept data
      .s_axis_data_tready(),
      //Something about signaling the end of a frame. I'll wire it to 0 THE FRAME NEVER ENDS
      .s_axis_data_tlast(1'b0),
      
      //The output data, all ready to continue processing
      .m_axis_data_tdata(FFT_Data[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]),
      //The core telling me it's got valid data
      .m_axis_data_tvalid(FFT_dataValidOut[numLanes - i - 1]),
      //Me telling the core I'm ready to accept data
      .m_axis_data_tready(1'b1),
      .m_axis_data_tlast(),
      
      .event_frame_started(),
      .event_tlast_unexpected(),
      .event_tlast_missing(),
      .event_status_channel_halt(),
      .event_data_in_channel_halt(),
      .event_data_out_channel_halt()
    );  
end


//And pass that output through the downconverters
//Generate numLanes coeffMults
for (i = 0; i < numLanes; i = i + 1) begin: DownConvBlock
    if (i == 0) begin
        CoeffMult_C #(.numWords(numWords), .ROMFilename(DownConvFilenames[(4 - (i % 4))*8*DownConvFilenameLength - 1 -: 8*DownConvFilenameLength]), .ROMFiletype("b")) DownConvMult_0(
            .currentSample(
                FFT_Data[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]
            ),
            .dataValid(FFT_dataValidOut[numLanes - i - 1]), .start(FFT_dataValidOut[numLanes - i - 1]), .stop(~FFT_dataValidOut[numLanes - i - 1]), .clk(clk),
            .product(
                downConvData[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]
            ),
            .dataValid_out(downConv_dataValidOut)
        );
    end
    else begin
        CoeffMult_C #(.numWords(numWords), .ROMFilename(DownConvFilenames[(4 - (i % 4))*8*DownConvFilenameLength - 1 -: 8*DownConvFilenameLength]), .ROMFiletype("b")) DownConvMult_N(
            .currentSample(
                FFT_Data[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]
            ),
            .dataValid(FFT_dataValidOut[numLanes - i - 1]), .start(FFT_dataValidOut[numLanes - i - 1]), .stop(~FFT_dataValidOut[numLanes - i - 1]), .clk(clk),
            .product(
                downConvData[(numLanes-i)*CmplxWidth - 1 -: CmplxWidth]
            ),
            .dataValid_out()
        );
    end
end
endgenerate

endmodule