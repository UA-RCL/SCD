`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2016 05:29:39 PM
// Design Name: 
// Module Name: FFT_32Pt_TopController
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


module FFT_32Pt_TopController(

    input start,
    input clk_P,
    input clk_N,
    input reset,

//    output reg done
    output done,
    output FFT_XOR_Output

    );

//Define states
localparam 
    init = 0,
    readDataAndCheckConditions = 1,
    waitToFinish = 2,
    doneState = 3;
//State registers
reg [1:0] CS, NS;


//Temp regs and wires for FFT Outputs
reg [1023:0] FFT_Out_Re, FFT_Out_Im;
wire [1023:0] FFT_Output_Real, FFT_Output_Imag;
//Address to write the FFT results into
reg [15:0] Wr_addr, Wr_addr_REG;
//Write enable for writing the FFT results
reg Wr_writeEn, Wr_writeEn_REG;
//Address for reading from the input BRAM
reg [7:0] R_addr, R_addr_REG;
//Write enables for writing in the input BRAM (out of the current scope)
reg R_writeEn, R_writeEn_REG;
//Whether or not the data is valid
//reg dataValid;
wire dataValid;

//Wires for holding the words that come out of the input BRAM
wire [2047:0] R_word;

//Wires for carrying the clock and the FPGA's done signal
wire clk, FFT_Done;

//First step, make the differential clock single ended so that it's easier to use
IBUFDS myBuf(
.I(clk_P), .IB(clk_N), .O(clk)
);

//Next, instantiate the BRAM for inputting data
Single_Port_FFT_BRAM myRAM_IP (
    .clka(clk),    // input wire clka
    .wea(R_writeEn),      // input wire [0 : 0] wea
    .addra(R_addr),  // input wire [7 : 0] addra
    .dina(2048'd0),    // input wire [1023 : 0] dina
    .douta(R_word)  // output wire [1023 : 0] douta
);

//Then, instantiate the FFT datapath
FFT_32_Pt_Datapath myFFT(
    .clk(clk),
    .reset(reset),
    
    .Re_x(R_word[2047:1024]),
    .Im_x(R_word[1023:0]),
    .dataValid(dataValid),
    
    .Re_Out(FFT_Output_Real),
    .Im_Out(FFT_Output_Imag),
    .done(FFT_Done)
);

//Just xor all of the output bits of the FFT and pass them out so that opt_design doesn't go crazy trimming everything
assign FFT_XOR_Output = (^ {FFT_Output_Real, FFT_Output_Imag});
//Set the done signal if the FFT is done
assign done = FFT_Done;
//Instantiate an xor gate, output to dataValid the xor of R_addr[8] and 1'b1
xor bitComparator(dataValid, R_addr[0], 1'b1);

initial begin
    R_addr <= 8'd0;
    R_addr_REG <= 8'd0;
    R_writeEn <= 1'b0;
    R_writeEn_REG <= 1'b0;
end

//Just use a simple state machine here
always @(posedge clk) begin
    R_addr <= R_addr + 1;
end

endmodule