module exec_top(
    input [5:0]ALU_Control,
    input branch_op, clk, rstn,
    // data
    input [31:0] operand_A, // operand A
    input [31:0] operand_B,  // operand B
    input [31:0] Rdata1, //Read Data 1
    input [31:0] imm32,
    input [31:0] PC,//PC_Exec_in
    output [31:0] ALU_result,
    output jump_flag,
    output [31:0]jump_target_PC 
);

reg [5:0] ALU_Control_flop;
reg [31:0] operand_A_flop, operand_B_flop, Rdata1_flop, 
           imm32_flop, PC_flop, ALU_result_flop,
           jump_target_PC_flop;
reg branch_op_flop, jump_flag_flop;
wire [31:0] ALU_result_unit, jump_target_PC_unit;
wire jump_flag_unit;

assign ALU_result = ALU_result_flop;
assign jump_flag = jump_flag_flop;
assign jump_target_PC = jump_target_PC_flop;



execution exec_stage (
    .ALU_Control(ALU_Control_flop),
    .branch_op(branch_op_flop),
    .operand_A(operand_A_flop),
    .operand_B(operand_B_flop),
    .Rdata1(Rdata1_flop),
    .imm32(imm32_flop),
    .PC(PC_flop),
    .ALU_result(ALU_result_unit),
    .jump_flag(jump_flag_unit),
    .jump_target_PC(jump_target_PC_unit)
);

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
        operand_A_flop <= 32'b0;
        operand_B_flop <= 32'b0;
        Rdata1_flop <= 32'b0;
        imm32_flop <= 32'b0;
        PC_flop <= 32'b0;
        branch_op_flop <= 1'b0;
        jump_target_PC_flop <= 32'b0;
        ALU_result_flop <= 32'b0;
        jump_flag_flop <= 1'b0;
    end
    else begin
        operand_A_flop <= operand_A;
        operand_B_flop <= operand_B;
        Rdata1_flop <= Rdata1;
        imm32_flop <= imm32;
        PC_flop <= PC;
        branch_op_flop <= branch_op;
        jump_target_PC_flop <= jump_target_PC_unit;
        ALU_result_flop <= ALU_result_unit;
        jump_flag_flop <= jump_flag_unit;
    end

end


endmodule