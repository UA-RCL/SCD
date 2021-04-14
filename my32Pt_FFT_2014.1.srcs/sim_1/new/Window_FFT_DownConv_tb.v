`timescale 1ns / 1ps

module Window_FFT_DownConv_tb();

//Let's just test a single lane of 256-Pt FFT-ing, no coeffs or anything
localparam numLanes = 1;
localparam WindowingFuncFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/default_rom_file.txt";
localparam DownConvFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/Windowing_DownConv_ROM_Files/default_complex_rom_file.txt";

localparam ReImWidth = 32;
localparam CmplxWidth = 2*ReImWidth;
    
reg [numLanes*CmplxWidth - 1 : 0] signalData = 0;
reg dataValid = 0, clk = 0;

wire [numLanes*CmplxWidth - 1 : 0] downConvData;
wire downConv_dataValidOut;

Window_FFT_DownConv #(.numLanes(numLanes), .WindowingFuncFilename(WindowingFuncFilename), .DownConvFilename(DownConvFilename)) w_fft_dc(
    .signalData(signalData), .dataValid(dataValid), .clk(clk), .downConvData(downConvData), .downConv_dataValidOut(downConv_dataValidOut)
);

always begin
    clk <= ~clk; #10;
end

initial begin
    repeat(4) @(posedge clk);
    
    //Begin testing
    //Just send in a bunch of 1+1js
    signalData <= {{numLanes}{64'b0011111110000000000000000000000000111111100000000000000000000000}};
    dataValid <= 1'b1;
    
    wait(downConv_dataValidOut);
    repeat(100) @(posedge clk);
    $stop;
end


endmodule
