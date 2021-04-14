`timescale 1ns / 1ps

module CoeffMult_tb();

localparam numWords = 256;
localparam ROMFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/incrementing_rom_file.txt";
localparam ROMFiletype = "b";
localparam ReImWidth = 32;

reg [ReImWidth-1:0] currentSample = 0;
reg dataValid = 0, start = 0, stop = 0, clk = 0;

wire [ReImWidth-1:0] product; 
wire dataValid_out;

CoeffMult #(.numWords(numWords), .ROMFilename(ROMFilename), .ROMFiletype(ROMFiletype)) myMult(
    .currentSample(currentSample), .dataValid(dataValid), .start(start), .stop(stop), .clk(clk),
    .product(product), .dataValid_out(dataValid_out)
);

always begin
    #10; clk <= ~clk;
end

initial begin
    @(posedge clk);
    currentSample <= 32'b00111111100000000000000000000000;
    start <= 1'b1;
    dataValid <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    currentSample <= 32'b01000000000000000000000000000000;
    @(posedge clk);
    currentSample <= 32'b01000000100000000000000000000000;
    @(posedge clk);
    currentSample <= 32'b01000001000000000000000000000000;
    @(posedge clk);
    currentSample <= 32'b01000001100000000000000000000000;
    @(posedge clk);
    currentSample <= 32'b01000010000000000000000000000000;
    @(posedge clk);
    currentSample <= 32'b01000010100000000000000000000000;
    dataValid <= 1'b0;
        
    @(negedge clk);
    if (product != 32'b00111111100000000000000000000000) begin
        $display("Failed 1 * 1");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000000100000000000000000000000) begin
        $display("Failed 2 * 2");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000001010000000000000000000000) begin
        $display("Failed 4 * 3");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000010000000000000000000000000) begin
        $display("Failed 8 * 4");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000010101000000000000000000000) begin
        $display("Failed 16 * 5");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000011010000000000000000000000) begin
        $display("Failed 32 * 6");
        $finish;
    end
    
    @(negedge clk);
    if (product != 32'b01000011111000000000000000000000) begin
        $display("Failed 64 * 7");
        $finish;
    end
    
    $display("Finished all tests!");
    $finish;
end


endmodule
