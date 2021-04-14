`timescale 1ns / 1ps

module SCD_AlphaProf_Top_tb();

`include "CLOG2_vh.vh"

localparam numLanes = 8;
localparam WindowingFuncFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/hamming_rom_file.txt";
localparam DownConvFilenames = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k0.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k1.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k2.txtC:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/downconv_rom_k3.txt";
localparam DownConvFilenameLength = 105;

//Don't actually change these, they're just meant to connect with terms from the paper
//Decides Initial FFT Pts & Windowing/DownConv ROM sizes
localparam Np = 256;
//Decides ConjProd FFT Pts
localparam P = 32;

localparam ReImWidth = 32;
localparam CmplxWidth = 2*ReImWidth;
//More intuitive way of recognizing what Np influences
localparam numWords = Np;

//The size of the FFT used in the ConjProd Iterative FFT section
localparam FFT_Pts = 32;

//Assuming the data is coming in the form {(Re, Im), (Re, Im), (Re, Im), ...}
//Complex Sample 0 is at the MSB (leftmost) and proceeds forward through Sample 1, 2, ...
reg [numLanes*CmplxWidth - 1 : 0] signalData = {{numLanes*CmplxWidth}{1'b0}};
reg dataValid = 1'b0;
reg clk_P = 1'b0;
reg reset = 1'b0;

wire clk_N;
wire ConjProd_Done;
wire AlphaProf_Done;
wire AlphaProf_EightSamplesValid;
//wire [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfBRAMOut1Output, alphaProfBRAMOut2Output;
wire [numLanes*CmplxWidth - 1 : 0] commonDataBus;

assign commonDataBus = (dataValid == 1'b1) ? signalData : {{numLanes*CmplxWidth}{1'bz}};

SCD_AlphaProf_Top #(.numLanes(numLanes), .WindowingFuncFilename(WindowingFuncFilename), .DownConvFilenames(DownConvFilenames), .DownConvFilenameLength(DownConvFilenameLength))
    theFullDesign(
        .commonDataBus(commonDataBus), .dataValid(dataValid), .clk_P(clk_P), .clk_N(clk_N), .reset(reset), 
        .ConjProd_Done(ConjProd_Done), .AlphaProf_Done(AlphaProf_Done), .AlphaProf_EightSamplesValid(AlphaProf_EightSamplesValid)
    );

localparam inputFilenames = {"C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_0.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_1.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_2.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_3.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_4.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_5.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_6.txt",
                             "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Testcases/QPSK/QPSK_SCD_Testcase_7.txt"};
localparam inputFilenameLength = 99;
integer fileHandles [0:numLanes-1];
integer i = 0, j = 0;
reg EOF = 0;

localparam alphaProfFilename_databusMethod = "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Results/QPSK/QPSK_SCD_tempDeleteMe.txt";
integer alphaProfHandle_databusMethod = 0;

integer cycleCounter = 0;

assign clk_N = ~clk_P;
always begin
    #5; clk_P <= 1'b1;
    #5; clk_P <= 1'b0;
    cycleCounter = cycleCounter + 1;
end

//Handles feeding data into the system
initial begin
    for (i = 0; i < numLanes; i = i + 1) begin
        fileHandles[i] = $fopen(inputFilenames[(numLanes-i)*8*inputFilenameLength - 1 -: 8*inputFilenameLength], "r");
        if (fileHandles[i] == 0) begin
            $error("Failed to open file %d", i);
            $finish;
        end
        else begin
            $display("Opened file %d for reading", i);
        end
    end
    
    @(posedge clk_P);
    //There are 8 lanes and 32*256 "points" to compute, so 32*256/8 = 1024 cycles in all should do it.
    for (i = 0; i < 1024; i = i + 1) begin
        for (j = 0; j < numLanes; j = j + 1) begin
            EOF = $fscanf(fileHandles[j], "%b\n", signalData[(numLanes-j)*CmplxWidth - 1 -: CmplxWidth]);
        end
        dataValid <= 1'b1;
        @(posedge clk_P);
    end
    dataValid <= 1'b0;
    for (j = 0; j < numLanes; j = j + 1) begin
        $fclose(fileHandles[j]);
    end
    @(posedge clk_P);
end

//Handles the new and improved(TM) version of writing the alpha profile results to a file. This one should be compatible with post-implementation simulations!
initial begin
    alphaProfHandle_databusMethod = $fopen(alphaProfFilename_databusMethod, "w");
    if (alphaProfHandle_databusMethod == 0) begin
        $error("Failed to open databus method alpha profile output file for writing");
        $finish;
    end
    else begin
        $display("Opened databus method alpha profile output file for writing");
    end
    
    while (1 == 1) begin
        @(negedge clk_P);
        if (AlphaProf_EightSamplesValid == 1'b1) begin
            //Write the upper half of the data bus to the file
            $fwrite(alphaProfHandle_databusMethod, "%b\n", commonDataBus[FFT_Pts/2*ReImWidth - 1 -: FFT_Pts/4*ReImWidth]);
        end
        if (AlphaProf_Done == 1'b1) begin
            //Write the lower half of the data bus to the file
            $fwrite(alphaProfHandle_databusMethod, "%b\n", commonDataBus[FFT_Pts/4*ReImWidth - 1 -: FFT_Pts/4*ReImWidth]);
            //Also, if this happens, we're done
            $display("Finished writing databus alpha profile to output file");
            $fclose(alphaProfHandle_databusMethod);
            //Since Verilog has no break command, just sit in an infinite loop while the other alphaProfHandle piece writes the comparison data to a file
            //It will handle $finish-ing the simulation for us
            $finish;
			//while (1 == 1) begin
            //    @(negedge clk_P);
            //end
        end
        $fflush(alphaProfHandle_databusMethod);
    end
end

endmodule
