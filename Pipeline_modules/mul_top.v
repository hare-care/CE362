module mul_top(
    input clock, rstn,
    input [31:0] a, b,
    output [31:0] c
);

reg [31:0] a_flop, b_flop, c_flop;
wire [31:0] c_mul;
assign c = c_flop;

multiply mul_unit (
    .clk(clock),
    .rstn(rstn),
    .a(a_flop),
    .b(b_flop),
    .c(c_mul)
);

always @(posedge clock or negedge rstn) begin
    if (rstn == 1'b0) begin
        a_flop <= 32'b0;
        b_flop <= 32'b0;
        c_flop <= 32'b0;
    end
    else begin
        a_flop <= a;
        b_flop <= b;
        c_flop <= c_mul;
    end
end


endmodule
