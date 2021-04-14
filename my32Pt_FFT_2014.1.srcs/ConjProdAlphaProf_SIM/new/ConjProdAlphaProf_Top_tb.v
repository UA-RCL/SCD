module ConjProdAlphaProf_Top_tb();

    reg clk_P, clk_N, start, reset;
    wire clk, ConjProd_Done, AlphaProf_Done, ReductionXOR_AlphaProfile;
    
    integer f, f2, f3;
    integer i;
    
    integer cycleCounter = 0;
    
    ConjProdAlphaProf_Top topModule(
        .clk_P(clk_P),
        .clk_N(clk_N),
        .start(start),
        .reset(reset),
        .ConjProd_Done(ConjProd_Done),
        .AlphaProf_Done(AlphaProf_Done)
        //.ReductionXOR_AlphaProfile(ReductionXOR_AlphaProfile)
    );
    
    //Start up the clocks
    always begin
        clk_P <= 1'b0; clk_N <= 1'b1; #10;
        clk_P <= 1'b1; clk_N <= 1'b0; #10;
        cycleCounter = cycleCounter + 1;
    end

    IBUFDS myBuf(
        .I(clk_P), .IB(clk_N), .O(clk)
    );

    localparam AlphaProfFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/AlphaProfileMaximums.txt";
    localparam ConjProdFFTs_Filename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/RawConjProdFFTs.txt";
    localparam ElementwiseFFTAbsVals = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/ConjProdFFTAlphaProf_Results/ElementwiseFFTAbsVals.txt";

    //Perform test (basically just tell it to start)
    initial begin
        //Open file for writing results
        f = $fopen(AlphaProfFilename, "w");
        if (f == 0) begin
            $error("Failed to open AlphaProf file for writing");
            $finish;
        end
        //Begin testing
        reset <= 1'b1; start <= 1'b0;
        @(posedge clk);
        reset <= 1'b0;
        @(posedge clk);
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;
        //Wait for the AlphaProfile section to be done
        wait(AlphaProf_Done);
        //Save the BRAM to disk for comparison with MATLAB -- there are 512 entries
        @(negedge clk);
        for (i = 0; i < 512; i = i + 1) begin
            $fwrite(f, "%b\n", topModule.alphaProf.alphaProfBRAM.myMemory[i]);
        end
        //Close the file
        $fclose(f);
        //And now we should be done
        $finish;
    end
    
    //Additional blocks responsible for recording other nifty data
    //Write the raw conjProd FFTs to an output file
    //Note: This current setup stops one cycle early and has a duplicate of the 1st FFT
    initial begin
        f2 = $fopen(ConjProdFFTs_Filename, "w");
        if (f2 == 0) begin
            $error("Failed to open ConjProdFFTs file for writing");
            $finish;
        end
        //Wait for the signal
        wait(topModule.ConjProd_DataValid_to_AlphaProfile == 1);
        //NOW!
        $display("Beginning to write ConjProdFFTs!");
        @(negedge clk);
        while(topModule.ConjProd_DataValid_to_AlphaProfile == 1) begin
            $fwrite(f2, "%b\n", topModule.ConjProd_FFT_to_AlphaProfile);
            @(negedge clk);
        end
        //We did it
        $fclose(f2);
    end
    
    initial begin
        f3 = $fopen(ElementwiseFFTAbsVals, "w");
        if (f3 == 0) begin
            $error("Failed to open ElementwiseFFTAbsVals for writing");
            $finish;
        end
        //Wait for the signal
        wait(topModule.alphaProf.absValDone_RegOut == 1);
        //NOW!
        $display("Beginning to write ElementwiseFFTAbsVals!");
        @(negedge clk);
        while(topModule.alphaProf.absValDone_RegOut == 1) begin
            $fwrite(f3, "%b\n", topModule.alphaProf.absValNums_RegOut);
            @(negedge clk);
        end
        //We did it
        $fclose(f3);
    end

endmodule