//pass Rdata2 to memaccess 
//pass Rd to memaccess 
//pass PC, imm32 to memaccess
// See memaccess to construct branch PC using jump_flag and jump_target_PC
module execution(
  //control signal
    input [5:0]ALU_Control,
    input branch_op,
    // data
    input [31:0] operand_A, // read data 1
    input [31:0] operand_B,  // read data 2
    input [31:0] imm32,
    input [31:0] PC,//PC_Exec_in
    output [31:0] ALU_result,
    output reg jump_flag,
    output reg [31:0]jump_target_PC    // PC_exec_out
);



//ALU
ALU ALU_inst (
  .ALU_Control(ALU_Control),  
  .operand_A(operand_A),      
  .operand_B(operand_B),      
  .ALU_result(ALU_result)     
);

// process jump and branch operation
always @(*) begin
  if (ALU_Control == `JAL)begin   // jump operation 
    jump_target_PC=PC + imm32;
    jump_flag=1'b1;
  end
  else if (ALU_Control == `JALR) begin  // jump operation 
    jump_target_PC=Rdata1+imm32;
    jump_flag=1'b1;
  end
  else if (branch_op==1'b1) begin    // branch operation 
    jump_target_PC=PC + imm32;
    jump_flag=1'b0;
  end
  else begin
    jump_target_PC=32'b0;
    jump_flag=1'b0;
  end
end

endmodule