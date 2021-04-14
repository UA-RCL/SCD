`timescale 1ns / 1ps

module FloP_Max_tb();

    parameter expWidth = 8;
    parameter fracWidth = 23;
    
    reg [expWidth+fracWidth:0] dataIn1, dataIn2;
    wire [expWidth+fracWidth:0] max;
    
    //Instantiate max module
    FloP_Max #(.expWidth(expWidth), .fracWidth(fracWidth)) maxxer(
        .dataIn1(dataIn1), .dataIn2(dataIn2), .max(max)
    );

    //Perform tests
    initial begin
        //dataIn1 = 1, dataIn2 = 1, expected = 1
        dataIn1 <= 32'h3f800000;
        dataIn2 <= 32'h3f800000;
        #5;
        if (max == 32'h3f800000) begin
            $display("Test 1 passed!");
        end
        else begin
            $error("Test 1 failed!");
            $finish;
        end
        #5;
        
        //dataIn1 = 1, dataIn2 = 2, expected = 2
        dataIn1 <= 32'h3f800000;
        dataIn2 <= 32'h40000000;
        #5;
        if (max == 32'h40000000) begin
            $display("Test 2 passed!");
        end
        else begin
            $error("Test 2 failed!");
            $finish;
        end
        #5;
        
        //dataIn1 = -1, dataIn2 = -2, expected = -1
        dataIn1 <= 32'hbf800000;
        dataIn2 <= 32'hc0000000;
        #5;
        if (max == 32'hbf800000) begin
            $display("Test 3 passed!");
        end
        else begin
            $error("Test 3 failed!");
            $finish;
        end
        #5;
        
        //dataIn1 = 1.00001, dataIn2 = 1, expected = 1.00001
        dataIn1 <= 32'h3f800054;
        dataIn2 <= 32'h3f800000;
        #5;
        if (max == 32'h3f800054) begin
            $display("Test 4 passed!");
        end
        else begin
            $error("Test 4 failed!");
            $finish;
        end
        #5;
        
        //dataIn1 = 2.321, dataIn2 = -3.253, expected = 2.321
        dataIn1 <= 32'h40148b44;
        dataIn2 <= 32'hc0503127;
        #5;
        if (max == 32'h40148b44) begin
            $display("Test 5 passed!");
        end
        else begin
            $error("Test 5 failed!");
            $finish;
        end
        
        $display("All tests passed!");
        $finish;
    end

endmodule
