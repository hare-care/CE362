module multiply(
    input clk, rstn,
    input [31:0] a, b,
    output [31:0] c
);

    assign c = a *b;


endmodule