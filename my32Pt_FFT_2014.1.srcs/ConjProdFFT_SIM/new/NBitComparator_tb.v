module NBitComparator_tb();

    //1-bit comparator test regs/wires
    reg a_1, b_1; wire gt_1, eq_1, lt_1;
    //2-bit comparator test regs/wires
    reg [1:0] a_2, b_2; wire gt_2, eq_2, lt_2;
    //4-bit comparator test regs/wires
    reg [3:0] a_4, b_4; wire gt_4, eq_4, lt_4;
    //8-bit comparator test regs/wires
    reg [7:0] a_8, b_8; wire gt_8, eq_8, lt_8;
    
    //Instantiate the comparators
    //One bit comparator
    NBitComparator #(.dataWidth(1)) oneBitComp(
        .a(a_1), .b(b_1), .gt(gt_1), .eq(eq_1), .lt(lt_1)
    );
    //Two bit comparator
    NBitComparator #(.dataWidth(2)) twoBitComp(
        .a(a_2), .b(b_2), .gt(gt_2), .eq(eq_2), .lt(lt_2)
    );
    //Four bit comparator
    NBitComparator #(.dataWidth(4)) fourBitComp(
        .a(a_4), .b(b_4), .gt(gt_4), .eq(eq_4), .lt(lt_4)
    );
    //Eight bit comparator
    NBitComparator #(.dataWidth(8)) eightBitComp(
        .a(a_8), .b(b_8), .gt(gt_8), .eq(eq_8), .lt(lt_8)
    );
    
    integer i;
    initial begin
        a_1 <= 1'b0; b_1 <= 1'b0;
        a_2 <= 2'b00; b_2 <= 2'b00;
        a_4 <= 4'b0000; b_4 <= 4'b0000;
        a_8 <= 8'b00000000; b_8 <= 8'b00000000;
        
        //First, test the one bit comparator
        for (i = 0; i < 2**2; i = i + 1) begin
            #10;
            if (gt_1 == (a_1 > b_1) && eq_1 == (a_1 == b_1) && lt_1 == (a_1 < b_1)) begin
                $display("Test %d passed", i);
            end
            else begin
                $error("Test %d failed", i);
                $finish;
            end
            {a_1, b_1} <= {a_1, b_1} + 2'd1;
        end
        //Next, test the two bit comparator
        for (i = 0; i < 2**4; i = i + 1) begin
            #10;
            if (gt_2 == (a_2 > b_2) && eq_2 == (a_2 == b_2) && lt_2 == (a_2 < b_2)) begin
                $display("Two-Bit Comparator Test %d passed", i);
            end
            else begin
                $error("Two-Bit Comparator Test %d failed", i);
                $finish;
            end
            {a_2, b_2} <= {a_2, b_2} + 4'd1;
        end
        //Next, test the four bit comparator
        for (i = 0; i < 2**8; i = i + 1) begin
            #10;
            if (gt_4 == (a_4 > b_4) && eq_4 == (a_4 == b_4) && lt_4 == (a_4 < b_4)) begin
                $display("Four-Bit Comparator Test %d passed", i);
            end
            else begin
                $error("Four-Bit Comparator Test %d failed", i);
                $finish;
            end
            {a_4, b_4} <= {a_4, b_4} + 8'd1;
        end
        //Finally, test the eight bit comparator
        for (i = 0; i < 2**16; i = i + 1) begin
            #10;
            if (gt_8 == (a_8 > b_8) && eq_8 == (a_8 == b_8) && lt_8 == (a_8 < b_8)) begin
                $display("Eight-Bit Comparator Test %d passed", i);
            end
            else begin
                $error("Eight-Bit Comparator Test %d failed", i);
                $finish;
            end
            {a_8, b_8} <= {a_8, b_8} + 16'd1;
        end
        $finish;
    end

endmodule