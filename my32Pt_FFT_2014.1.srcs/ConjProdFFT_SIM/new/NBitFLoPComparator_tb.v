module NBitFloPComparator_tb();

    parameter expWidth = 8;
    parameter fracWidth = 23;
    
    reg [expWidth+fracWidth:0] a, b;
    wire gt, eq, lt;
    
    NBitFLoPComparator #(.expWidth(expWidth), .fracWidth(fracWidth)) flopComp(
        .a(a), .b(b), .gt(gt), .eq(eq), .lt(lt)
    );

    initial begin
        // a = +0, b = +0 => a == b
        a <= 32'b00000000000000000000000000000000;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b0 && eq == 1'b1 && lt == 1'b0) begin
            $display("Test 1 passed");
        end
        else begin
            $error("Test 1 failed");
            $finish;
        end
        #10;
        
        // a = +1, b = +0 => a > b
        a <= 32'b00111111100000000000000000000000;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b1 && eq == 1'b0 && lt == 1'b0) begin
            $display("Test 2 passed");
        end
        else begin
            $error("Test 2 failed");
            $finish;
        end
        #10;
        
        // a = -1, b = +0 => a < b
        a <= 32'b10111111100000000000000000000000;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b0 && eq == 1'b0 && lt == 1'b1) begin
            $display("Test 3 passed");
        end
        else begin
            $error("Test 3 failed");
            $finish;
        end
        #10;
        
        // a = +0, b = +1 => a < b
        a <= 32'b00000000000000000000000000000000;
        b <= 32'b00111111100000000000000000000000;
        #10;
        if (gt == 1'b0 && eq == 1'b0 && lt == 1'b1) begin
            $display("Test 4 passed");
        end
        else begin
            $error("Test 4 failed");
            $finish;
        end
        #10;
        
        // a = +0, b = -1 => a > b
        a <= 32'b00000000000000000000000000000000;
        b <= 32'b10111111100000000000000000000000;
        #10;
        if (gt == 1'b1 && eq == 1'b0 && lt == 1'b0) begin
            $display("Test 5 passed");
        end
        else begin
            $error("Test 5 failed");
            $finish;
        end
        #10;
        
        // a = -128.23, b = 0 => a < b
        a <= 32'b11000011000000000011101011100001;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b0 && eq == 1'b0 && lt == 1'b1) begin
            $display("Test 6 passed");
        end
        else begin
            $error("Test 6 failed");
            $finish;
        end
        #10;
        
        // a = -2^(-149), b = 0 => a < b (look, denormal numbers!)
        a <= 32'b10000000000000000000000000000001;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b0 && eq == 1'b0 && lt == 1'b1) begin
            $display("Test 7 passed");
        end
        else begin
            $error("Test 7 failed");
            $finish;
        end
        #10;
        
        // a = 2^(-149), b = 0 => a > b
        a <= 32'b00000000000000000000000000000001;
        b <= 32'b00000000000000000000000000000000;
        #10;
        if (gt == 1'b1 && eq == 1'b0 && lt == 1'b0) begin
            $display("Test 7 passed");
        end
        else begin
            $error("Test 7 failed");
            $finish;
        end
        #10;
        
        $display("All tests passed!");
        $finish;
        
    end

endmodule