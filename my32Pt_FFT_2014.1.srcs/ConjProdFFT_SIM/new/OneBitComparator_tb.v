module OneBitComparator_tb();

    reg a, b;
    wire gt, eq;
    
    OneBitComparator myComp(.a(a), .b(b), .gt(gt), .eq(eq));
    
    initial begin
        a <= 1'b0;
        b <= 1'b0;
        #10;
        if (gt == 1'b0 && eq == 1'b1) begin
            $display("Test 1 passed!");
        end
        else begin
            $display("Test 1 failed!");
        end
        
        #10;
        a <= 1'b0;
        b <= 1'b1;
        #10;
        if (gt == 1'b0 && eq == 1'b0) begin
            $display("Test 2 passed!");
        end
        else begin
            $display("Test 2 failed!");
        end
        
        #10;
        a <= 1'b1;
        b <= 1'b0;
        #10;
        if (gt == 1'b1 && eq == 1'b0) begin
            $display("Test 3 passed!");
        end
        else begin
            $display("Test 3 failed!");
        end
        
        #10;
        a <= 1'b1;
        b <= 1'b1;
        #10;
        if (gt == 1'b0 && eq == 1'b1) begin
            $display("Test 4 passed!");
        end
        else begin
            $display("Test 4 failed!");
        end
        
        $finish;
    end

endmodule