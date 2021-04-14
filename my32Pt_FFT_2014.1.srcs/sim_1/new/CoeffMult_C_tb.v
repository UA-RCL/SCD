`timescale 1ns / 1ps

module CoeffMult_C_tb();

localparam numWords = 256;
localparam ROMFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/incrementing_complex_rom_file.txt";
localparam ROMFiletype = "b";
localparam ReImWidth = 32;
localparam CmplxWidth = 2*ReImWidth;

reg [CmplxWidth-1:0] currentSample = 0;
reg dataValid = 0, start = 0, stop = 0, clk = 0;

wire [CmplxWidth-1:0] product; 
wire dataValid_out;

CoeffMult_C #(.numWords(numWords), .ROMFilename(ROMFilename), .ROMFiletype(ROMFiletype)) myMult(
    .currentSample(currentSample), .dataValid(dataValid), .start(start), .stop(stop), .clk(clk),
    .product(product), .dataValid_out(dataValid_out)
);

always begin
    #10; clk <= ~clk;
end

initial begin
    @(posedge clk);
    currentSample <= 64'b0011111110000000000000000000000000111111100000000000000000000000;
    start <= 1'b1;
    dataValid <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    currentSample <= 64'b0100000000000000000000000000000000111111100000000000000000000000;
    @(posedge clk);
    currentSample <= 64'b0100000010000000000000000000000000111111100000000000000000000000;
    @(posedge clk);
    currentSample <= 64'b0100000100000000000000000000000000111111100000000000000000000000;
    @(posedge clk);
    currentSample <= 64'b0100000110000000000000000000000000111111100000000000000000000000;
    @(posedge clk);
    currentSample <= 64'b0100001000000000000000000000000000111111100000000000000000000000;
    @(posedge clk);
    currentSample <= 64'b0100001010000000000000000000000000111111100000000000000000000000;
    dataValid <= 1'b0;
    
    wait(dataValid_out);
    
    @(negedge clk);
    if (product != 64'b0000000000000000000000000000000001000000000000000000000000000000) begin
        $display("Failed (1+i) * (1+i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100000000000000000000000000000001000000110000000000000000000000) begin
        $display("Failed (2+i) * (2+2i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100000100010000000000000000000001000001011100000000000000000000) begin
        $display("Failed (4+i) * (3+3i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100000111100000000000000000000001000010000100000000000000000000) begin
        $display("Failed (8+i) * (4+4i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100001010010110000000000000000001000010101010100000000000000000) begin
        $display("Failed (16+i) * (5+5i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100001100111010000000000000000001000011010001100000000000000000) begin
        $display("Failed (32+i) * (6+6i)");
        $finish;
    end
    
    @(negedge clk);
    if (product != 64'b0100001111011100100000000000000001000011111000111000000000000000) begin
        $display("Failed (64+i) * (7+7i)");
        $finish;
    end
    
    $display("Finished all tests!");
    $finish;
end

endmodule
