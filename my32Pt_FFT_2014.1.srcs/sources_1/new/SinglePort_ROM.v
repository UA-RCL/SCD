`timescale 1ns / 1ps

`include "CLOG2_vh.vh"

module SinglePort_ROM
#(
    parameter wordWidth = 32,
    parameter numWords = 256,
    parameter filename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_rom_file.txt",
    parameter filetype = "b"
)
(
    input clk,
    input rdEn,
    input [(`CLOG2(numWords))-1:0] rdAddr,
    output reg [wordWidth-1:0] rdData = 0
);

(* rom_style = "block" *) reg [wordWidth-1:0] myROM [numWords-1:0];

initial begin
    if (filetype == "b") begin
        $readmemb(filename, myROM);
    end
    else begin
        $readmemh(filename, myROM);
    end
end

always @(posedge clk) begin
    if (rdEn) begin
        rdData <= myROM[rdAddr];
    end
    else begin
        rdData <= {{wordWidth}{1'b0}};
    end
end

endmodule
