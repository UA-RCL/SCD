`timescale 1ns / 1ps

module ConjProdController_Datapath(
    input clk,
    input addr1_ld, input addr1_clr,
    input addr2_ld, input addr2_clr,
    input wr_addr_ld, input wr_addr_clr,
    
    output [7:0] Addr1_Out,
    output [7:0] Addr2_Out,
    output [15:0] Wr_Addr_Out
);

    wire [7:0] Addr1_To_Inc1, Addr2_To_Inc2, Inc1_To_Addr1, Inc2_To_Addr2;
    wire [15:0] Wr_Addr_To_Inc3, Inc3_To_Wr_Addr;

    //Register for storing read address 1
    NBitReg #(.dataWidth(8)) Addr1_Register (.clk(clk), .reset(addr1_clr), .dataIn(Inc1_To_Addr1), .writeEn(addr1_ld), .dataOut(Addr1_To_Inc1));
    //Incrementor for incrementing address 1
    Incrementor #(.dataWidth(8)) Addr1_Inc (.dataIn(Addr1_To_Inc1), .dataOut(Inc1_To_Addr1));
    
    //Register for storing read address 2
    NBitReg #(.dataWidth(8)) Addr2_Register (.clk(clk), .reset(addr2_clr), .dataIn(Inc2_To_Addr2), .writeEn(addr2_ld), .dataOut(Addr2_To_Inc2));
    //Incrementor for incrementing address 2
    Incrementor #(.dataWidth(8)) Addr2_Inc (.dataIn(Addr2_To_Inc2), .dataOut(Inc2_To_Addr2));

    //Register for storing write address
    NBitReg #(.dataWidth(16)) Addr3_Register (.clk(clk), .reset(wr_addr_clr), .dataIn(Inc3_To_Wr_Addr), .writeEn(wr_addr_ld), .dataOut(Wr_Addr_To_Inc3));
    //Incrementor for incrementing write address
    Incrementor #(.dataWidth(16)) Wr_Addr_Inc (.dataIn(Wr_Addr_To_Inc3), .dataOut(Inc3_To_Wr_Addr));

    assign Addr1_Out = Addr1_To_Inc1;
    assign Addr2_Out = Addr2_To_Inc2;
    assign Wr_Addr_Out = Wr_Addr_To_Inc3;

endmodule
