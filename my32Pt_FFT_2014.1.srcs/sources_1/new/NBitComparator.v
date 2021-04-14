`timescale 1ns / 1ps

module NBitComparator
#(
    parameter dataWidth = 32
)
(
    input [dataWidth-1:0] a,
    input [dataWidth-1:0] b,
    output gt,
    output eq,
    output lt
);

assign gt = (a > b);
assign eq = (a == b);
assign lt = (a < b);

/*
wire [dataWidth-1:0] gt_wire, eq_wire;
wire [dataWidth-2:1] or_wires;

wire gt_reduced, eq_reduced;

genvar i;
generate
//First, generate all of the comparators
for (i = dataWidth-1; i >= 0; i = i - 1) begin
    OneBitComparator aComp(
        .a(a[i]), .b(b[i]), .gt(gt_wire[i]), .eq(eq_wire[i])
    );
end

//Next, generate all of the reduction logic
//First, do the logic for or-ing all of the gt results
for (i = dataWidth-2; i > 0; i = i - 1) begin
    //Instantiate the first in the chain
    if (i == (dataWidth-2)) begin
        //The first one is or_wires[i] = 1 if ((gt_wire[i] == 1) or (gt_wire[i] == 0 && gt_wire[i-1] == 1))
        assign or_wires[i] = (| {gt_wire[i+1], (& {eq_wire[i+1], gt_wire[i]})});
    end
    //Next, carry that result through the rest of the chain
    else begin
        //All subsequent ones are or_wires[i] = 1 if ((or_wires[i+1] == 1) or (or_wires[i+1] == 0 && gt_wire[i] == 1))
        assign or_wires[i] = (| {or_wires[i+1], (& {eq_wire[i+1], gt_wire[i]})});
    end
end
//Finally, assign gt_reduced, the last element of that chain
if (dataWidth > 2) begin
    assign gt_reduced = (| {or_wires[1], (& {eq_wire[1], gt_wire[0]})});
end
else if (dataWidth == 2) begin
    assign gt_reduced = (| {gt_wire[1], (& {eq_wire[1], gt_wire[0]})});
end
else begin
    assign gt_reduced = gt_wire[0];
end

//Now, reduce the eq_wire
assign eq_reduced = (& eq_wire);

//Finally, assign the outputs
assign gt = gt_reduced;
assign eq = eq_reduced;
assign lt = (& {~gt_reduced, ~eq_reduced});
endgenerate
*/
endmodule