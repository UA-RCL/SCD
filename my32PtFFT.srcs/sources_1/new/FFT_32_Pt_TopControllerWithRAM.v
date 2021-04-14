`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2016 09:19:48 PM
// Design Name: 
// Module Name: FFT_32_Pt_TopControllerWithRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFT_32_Pt_TopControllerWithRAM(
    input clk,
    input reset,

    output [1023:0] Re_Out, 
    output [1023:0] Im_Out
);

parameter filename = "C:/Data/VivadoProjects/my32PtFFT/testFile";

reg [7:0] addr, addr2;
//reg [1023:0] Re_Reg, Im_Reg;

wire [1023:0] Re_Mem, Im_Mem;//, Re_Out, Im_Out;
reg writeEn1, writeEn2;

/*
DualPortRAM #(.wordWidth(1024), .addrSize(8), .filename(filename)) myRam(
    .clk1(clk), .clk2(clk), .addr1(addr), .addr2(addr2), .writeEn1(writeEn1), .writeEn2(writeEn2),
    .dataIn1(1024'd0), .dataIn2(1024'd0), .dataOut1(Re_Mem), .dataOut2(Im_Mem)
);
*/

blk_mem_ip myRAM_IP (
  .clka(clk),    // input wire clka
  .wea(writeEn1),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [7 : 0] addra
  .dina(1024'd0),    // input wire [1023 : 0] dina
  .douta(Re_Mem),  // output wire [1023 : 0] douta
  .clkb(clk),    // input wire clkb
  .web(writeEn2),      // input wire [0 : 0] web
  .addrb(addr2),  // input wire [7 : 0] addrb
  .dinb(1024'd0),    // input wire [1023 : 0] dinb
  .doutb(Im_Mem)  // output wire [1023 : 0] doutb
);


FFT_32_Pt_Datapath myFFT(
    .clk(clk), .reset(reset), .dataValid(1'b1), .Re_x(Re_Mem), .Im_x(Im_Mem),
    .Re_Out(Re_Out), .Im_Out(Im_Out)
);

initial begin
    addr <= 8'd0;
    addr2 <= 8'd0;
    writeEn1 <= 1'b0;
    writeEn2 <= 1'b0;
end

always @(posedge clk) begin
    //Re_Reg <= Re_Out;
    //Im_Reg <= Im_Out;
    addr <= addr + 1;
end
    
endmodule
