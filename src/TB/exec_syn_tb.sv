module exec_syn_tb();

localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = 1'b1;
logic start = '0;
logic done = '0;

// DUT IO signals
logic [5:0]     ALU_Control_in = '0;  
logic           branch_op_in = '0;
logic [31:0]    operand_A_in = 32'b1; 
logic [31:0]    operand_B_in = 32'b10;
logic [31:0]    Rdata1_in = '0;
logic [31:0]    imm32_in = 32'b101;
logic [31:0]    PC_in = '0;
logic [31:0]    ALU_result_out;
logic           jump_flag_out;
logic [31:0]    jump_target_PC_out;


// Setting DUT
exec_top DUT (
    .ALU_Control(ALU_Control_in),
    .branch_op(branch_op_in),
    .clk(clock),
    .rstn(reset),
    .operand_A(operand_A_in),
    .operand_B(operand_B_in),
    .Rdata1(Rdata1_in),
    .imm32(imm32_in),
    .PC(PC_in),
    .ALU_result(ALU_result_out),
    .jump_flag(jump_flag_out),
    .jump_target_PC(jump_target_PC_out)
);


// Creating Clock
always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

// Reset for one clock cycle
initial begin
    @(posedge clock);
    reset = 1'b0;
    @(posedge clock);
    reset = 1'b1;
end

initial begin
    @(posedge reset);
    @(posedge clock);
    #10
    ALU_Control_in = 5'b10;
    operand_B_in = 32'd10;
    #60


    $finish;

end


endmodule