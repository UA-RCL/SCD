`timescale 1ns / 1ps
`include "CLOG2_vh.vh"

/*
    A coeffMult_C is a Complex FLoP Multiplier paired with a ROM that allows the user to, say, stream in data
    one sample at a time and have a down conversion (complex exponential shift) function applied to it.
    
    The basic operation is a sample comes in, it is multiplied by the current memory element, the memory index increments,
    the next sample comes in, and it is multiplied by the following memory element.
    
    x1 * coeff1, x2 * coeff2, x3 * coeff3, ...

    It is built for working with single precision FLoP, complex data. If you want plain real multiplications, just use a CoeffMult (more efficient at it)
*/

module CoeffMult_C
#(
    //The number of words in the memory before it loops
    parameter numWords = 256,
    parameter ROMFilename = "C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/my32Pt_FFT_2014.1.srcs/sources_1/new/default_complex_rom_file.txt",
    parameter ROMFiletype = "b",
    
    localparam expWidth = 8,
    localparam sigWidth = 23,
    localparam ReImWidth = 1+expWidth+sigWidth, //i.e. 32-bits
    localparam CmplxWidth = 2*ReImWidth
)
(
    //Data is stored {Re, Im}
    input [CmplxWidth-1:0] currentSample,
    input dataValid,
    input start,
    input stop,
    input clk,
    output [CmplxWidth-1:0] product,
    output dataValid_out
);

//Latch the data for two cycles to allow (i) the ROM FSM to start and (ii) the ROM to read its first element
reg [CmplxWidth-1:0] currentSample_d = 0, currentSample_dd = 0;
reg dataValid_d = 0, dataValid_dd = 0;

//Regs and wires for the ROM
reg [(`CLOG2(numWords))-1:0] rdAddress = 0;
wire [CmplxWidth-1:0] rdData;

wire [(`CLOG2(numWords))-1:0] rdAddress_ns;
wire rdEn;

//We have two states: reading and not reading
reg cs = 0;
wire ns;

/*****************************
    Multiplication nonsense
 *****************************/

always @(posedge clk) begin
    currentSample_d <= currentSample;
    currentSample_dd <= currentSample_d;
    
    dataValid_d <= dataValid;
    dataValid_dd <= dataValid_d;
end

FloP_Complex_Mult #(.sig_width(sigWidth), .exp_width(expWidth)) daCMult(
    .Re_a(currentSample_dd[CmplxWidth-1 -: ReImWidth]), .Im_a(currentSample_dd[ReImWidth-1 -: ReImWidth]), 
    .Re_b(rdData[CmplxWidth-1 -: ReImWidth]), .Im_b(rdData[ReImWidth-1 -: ReImWidth]), 
    .clk(clk), .reset(1'b0), .dataValid(dataValid_dd),
    .Re_Z(product[CmplxWidth-1 -: ReImWidth]), .Im_Z(product[ReImWidth-1 -: ReImWidth]),
    .dataValidOut(dataValid_out)
);

/*****************************
 State machine & ROM nonsense
 *****************************/

SinglePort_ROM #(.wordWidth(CmplxWidth), .numWords(numWords), .filename(ROMFilename), .filetype(ROMFiletype)) daROM(
    .clk(clk), .rdEn(rdEn), .rdAddr(rdAddress), .rdData(rdData)
);

always @(posedge clk) begin
    cs <= ns;
    rdAddress <= rdAddress_ns;
end

assign ns = (cs == 1'b0 && start == 1'b0) ? 1'b0 :
            (cs == 1'b0 && start == 1'b1) ? 1'b1 :
            (cs == 1'b1 && stop == 1'b0) ? 1'b1 : 
            (cs == 1'b1 && stop == 1'b1 && start == 1'b1) ? 1'b1 : 1'b0;

assign rdEn = (cs == 1'b1);          
assign rdAddress_ns = (cs == 1'b1) ? rdAddress + {{{{`CLOG2(numWords)}-1}{1'b0}}, 1'b1} : rdAddress;

endmodule