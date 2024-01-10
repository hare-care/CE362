//pass Rdata2 to memaccess 
//pass Rd to memaccess 
//pass PC, imm32 to memaccess
// See memaccess to construct branch PC using jump_flag and jump_target_PC
module execution(
    input [5:0]ALU_Control,
    input [1:0] op_A_sel,                 // select operand A, 00: readdata1, 01: PC, 10: PC+4, 11:0
    input op_B_sel,                     // 0:immediate, 1: readdata2 
    input [31:0] Rdata1, // read data 1
    input [31:0] Rdata2,  // read data 2
    input [31:0] imm32,
    input [31:0] PC,
    output [31:0] ALU_result,
    output jump_flag,
    output [31:0]jump_target_PC
);

wire [31:0]operand_A;
wire [31:0]operand_B;
// operand A MUX,
assign operand_A = (op_A_sel == 2'b00) ? Rdata1:  
            (op_A_sel == 2'b01) ? PC:
            (op_A_sel == 2'b10) ? (PC + 32'd4):
            (32'b0);
// operand B MUX  				 
assign operand_B = op_B_sel ? imm32:Rdata2; 
//ALU
ALU ALU_inst (
  .ALU_Control(ALU_Control),  
  .operand_A(operand_A),      
  .operand_B(operand_B),      
  .ALU_result(ALU_result)     
);

// process jump operation
assign jump_target_PC = (ALU_Control == `JAL)? (PC + imm32)://jal instructions 
                        (ALU_Control == `JALR)? (Rdata1+imm32): //jalr instruction 
                        32'b0;
assign jump_flag= ALU_Control == `JAL||ALU_Control == `JALR;

endmodule