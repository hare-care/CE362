`timescale 1ns/1ns

module mul_tb;

localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = 1'b1;

logic [31:0] a_in, b_in, c_out;

multiply DUT (
    .clk(clock),
    .rstn(reset),
    .a(a_in),
    .b(b_in),
    .c(c_out)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b0;
    @(posedge clock);
    reset = 1'b1;
end


initial begin
    @(posedge reset);
    @(posedge clock);
    a_in = 32'd10;
    b_in = 32'd10;
    #5
    $finish;


end





endmodule