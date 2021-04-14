module AlphaProf_tb();

localparam FFT_Pts = 32;
localparam ReImWidth = 32;
localparam CmplxWidth = 2*ReImWidth;
//    localparam InputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/AlphaProf_TestFiles/alphaProfDataOrderingVerification.txt";
//    localparam InputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/AlphaProf_TestFiles/MATLAB_Expected_FFTs_Testcase.txt";
localparam InputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/AlphaProf_TestFiles/OFDM_SCD_ConjProdFFTs_NewAlphaProfPipeline.txt";
localparam readFromFile = "Yes";
//    localparam OutputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/alphaProfDataOrderingVerification_OUTPUT.txt";
//    localparam OutputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/MATLAB_Expected_FFTs_Testcase_OUTPUT.txt";
localparam OutputFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/OFDM_SCD_ConjProdFFTs_NewAlphaProfPipeline_OUTPUT.txt";
localparam writeToFile = "Yes";

localparam alphaProfFilename_databusMethod = "C:/Users/jmack2545.ENGR-RCL08G/Documents/MATLAB/Josh/FullSCD_Results/OFDM/OFDM_SCD_AlphaProf_databusMethod.txt";
integer alphaProfHandle_databusMethod = 0;

reg [FFT_Pts*CmplxWidth-1:0] FFT_Result_In;
reg clk = 0, reset = 0, FFT_DataValid = 0, EOF = 0;

wire AlphaProfile_Done; 
wire [FFT_Pts/4*ReImWidth - 1 : 0] alphaProfBRAMOut1Output, alphaProfBRAMOut2Output;

wire [FFT_Pts/4*ReImWidth - 1 : 0] AlphaProf_EightSamples, AlphaProf_FinalEightSamples;
wire AlphaProf_EightSamplesValid;

integer inputFile = 0, outputFile = 0, i = 0, scanResults = 0, cycleCounter = 0;

AlphaProfile myProf(
    .FFT_Result_In(FFT_Result_In),
    .clk(clk),
    .reset(reset),
    .FFT_DataValid(FFT_DataValid),
    
    .AlphaProfile_Done(AlphaProfile_Done),
    .alphaProfBRAMOut1Output(alphaProfBRAMOut1Output),
    .alphaProfBRAMOut2Output(alphaProfBRAMOut2Output),
    
    .AlphaProf_EightSamples(AlphaProf_EightSamples),
    .AlphaProf_FinalEightSamples(AlphaProf_FinalEightSamples),
    .AlphaProf_EightSamplesValid(AlphaProf_EightSamplesValid)
);

always begin
    #10; clk <= 0;
    #10; clk <= 1;
    cycleCounter = cycleCounter + 1;
end

//Initial block that handles feeding data into the system
initial begin
    if (readFromFile == "Yes") begin
        inputFile = $fopen(InputFilename, "r");
        if (inputFile == 0) begin
            $error("Failed to open input file for reading!");
            $finish;
        end
        else begin
            $display("Opened inputFile for reading!");
        end
//            @(posedge clk) reset <= 1'b1;
//            @(posedge clk) reset <= 1'b0;
        
        EOF = $feof(inputFile);
        while (!EOF) begin
            scanResults = $fscanf(inputFile, "%b\n", FFT_Result_In);
            FFT_DataValid = 1'b1;
            @(posedge clk);
            EOF = $feof(inputFile);
        end
        FFT_DataValid = 1'b0;
        $fclose(inputFile);
    end
    else begin
        @(posedge clk) reset <= 1'b1;
        @(posedge clk) begin 
            reset <= 1'b0;
            FFT_DataValid = 1'b1;
            FFT_Result_In <= {{FFT_Pts*ReImWidth}{1'b0}};
        end
        wait(AlphaProfile_Done);
    end
end

//Initial block that handles waiting for the computation to be done and writing the results to an output file (if necessary)
/*
initial begin
    if (writeToFile == "Yes") begin
        outputFile = $fopen(OutputFilename, "w");
        if (outputFile == 0) begin
            $error("Failed to open output file for writing!");
            $finish;
        end
        else begin
            $display("Opened outputFile for writing!");
        end
        //Wait for the computation to be complete       
        wait(AlphaProfile_Done);
        repeat(3) @(posedge clk);
        @(negedge clk);
        
        //Write the results  
        for (i = 0; i < 256; i = i + 1) begin
            $fwrite(outputFile, "%b\n", myProf.topAddrsAlphaProfBRAM.myRAM[i]);
            $fwrite(outputFile, "%b\n", myProf.bottomAddrsAlphaProfBRAM.myRAM[i]);
        end
        
        //Be done with it
        $fclose(outputFile);
    end
    else begin
        wait(AlphaProfile_Done);
        @(posedge clk);
        @(negedge clk);
    end
    $finish;
end
*/


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
        @(negedge clk);
        if (AlphaProf_EightSamplesValid == 1'b1) begin
            //Write the upper half of the data bus to the file
            $fwrite(alphaProfHandle_databusMethod, "%b\n", AlphaProf_EightSamples);
        end
        if (AlphaProfile_Done == 1'b1) begin
            //Write the lower half of the data bus to the file
            $fwrite(alphaProfHandle_databusMethod, "%b\n", AlphaProf_FinalEightSamples);
            //Also, if this happens, we're done
            $display("Finished writing databus alpha profile to output file");
            $fclose(alphaProfHandle_databusMethod);
            //Since Verilog has no break command, just sit in an infinite loop while the other alphaProfHandle piece writes the comparison data to a file
            //It will handle $finish-ing the simulation for us
            while (1 == 1) begin
                @(negedge clk);
            end
        end
        $fflush(alphaProfHandle_databusMethod);
    end
end

endmodule