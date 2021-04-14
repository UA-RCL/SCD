`timescale 1ns / 1ps

module AlphaProfileController_Datapath(
    input dataValid,
    input reset,
    input clk,
    output [8:0] Addr1,
    output [8:0] Addr2,
    output AlphaProfDone,
    output BRAM_WriteEn,
    output EightSamplesReady,
    output isLastStage
);

wire [8:0] AddrReg_RegOut, AddrMinus1, AddrPlus256, AddrMuxToReg;
wire [15:0] IterReg_RegOut, IterRegPlus1;
wire LSB_iterEq256;

//Mux for selecting input into address register's dataIn
Mux2To1 #(.dataWidth(9)) addrMux(
    .input1(AddrMinus1),
    .input2(AddrPlus256),
    .sel(LSB_iterEq256),
    .out(AddrMuxToReg)
);
//Register for holding the current address
NBitReg #(.dataWidth(9), .resetVal(256)) addrReg(
    .clk(clk),
    .reset(reset),
    .dataIn(AddrMuxToReg),
    .writeEn(dataValid),
    .dataOut(AddrReg_RegOut)
);
//Register for holding the iteration count
NBitReg #(.dataWidth(16)) iterReg(
    .clk(clk),
    .reset(reset),
    .dataIn(IterRegPlus1),
    .writeEn(dataValid),
    .dataOut(IterReg_RegOut)
);
//Comparators for comparing the iteration count to the goals (255 for each iteration and 65535 iterations in all)
NBitComparator #(.dataWidth(8)) subAddrComparator(
    .a(IterReg_RegOut[7:0]),
    .b(8'd255),
    .lt(), .eq(LSB_iterEq256), .gt()
);
NBitComparator #(.dataWidth(16)) doneComparator(
    .a(IterReg_RegOut),
    .b(16'd65535),
    .lt(), .eq(AlphaProfDone), .gt()
);

//Simple assignments to handle arithmetic operations
assign AddrMinus1 = AddrReg_RegOut - 1;
assign AddrPlus256 = AddrReg_RegOut + 256;
assign IterRegPlus1 = IterReg_RegOut + 1;

//And assign outputs
assign Addr2 = AddrReg_RegOut;
assign Addr1 = AddrMinus1;
assign BRAM_WriteEn = dataValid;
assign EightSamplesReady = LSB_iterEq256;

//65536 - 256 = 65280 => iterations 65280 through 65535 are the 256 "last stage" iterations during which we should record every output
assign isLastStage = (IterReg_RegOut > 16'd65279);

endmodule
