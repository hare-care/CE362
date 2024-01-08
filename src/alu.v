module ALU (
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output [31:0] ALU_result
);
//Determine output of ALU
assign ALU_result = 
    //arithemetic and logic
    (ALU_Control == `ADD) ? (operand_A + operand_B): //Add (LUI,AUIPC,LW,SW,ADDI,ADD)
    (ALU_Control == `SUB) ? (operand_A - operand_B): //Sub (SUB)
    (ALU_Control ==`OR) ? (operand_A | operand_B): //Or (OR,ORI)
    (ALU_Control == `XOR) ? (operand_A ^ operand_B): //Xor (XORI,XOR)
    (ALU_Control == `AND) ? (operand_A & operand_B): //And (ANDI,AND) 
    (ALU_Control == `SLL) ? (operand_A << operand_B): //Logical Shift Left (SLLI,SLL)
    (ALU_Control == `SRL) ? ($unsigned(operand_A) >> operand_B): //Logical Shift Right (SRLI,SRL)
    (ALU_Control == `SRA) ? ($signed(operand_A) >>> operand_B): //Arithmetic Shift Right (SRAI,SRA)
    (ALU_Control == `JAL || ALU_Control == `JALR) ? (operand_A): //Passthrough (JAL,JALR) rd=pc+4
    //compare
    (ALU_Control == `SLT || ALU_Control == `BLT) ? ({31'b0,$signed(operand_A)<$signed(operand_B)}): // Signed Less Than (SLTI,SLT,BLT)
    (ALU_Control == `SLTU || ALU_Control == `BLTU) ? ({31'b0,$unsigned(operand_A)<$unsigned(operand_B)}): //Unsigned Less Than (BLTU,SLTIU,SLTU)
    (ALU_Control == `BGE) ? ({31'b0,$signed(operand_A)>=$signed(operand_B)}): // Signed Greater Than or Equal To (BGE)
    (ALU_Control == `BGEU) ? ({31'b0,$unsigned(operand_A)>=$unsigned(operand_B)}): //Unsigned Greater Than or Equal To (BGEU)
    (ALU_Control == `BEQ) ? ({31'b0,operand_A == operand_B}): //Equals	(BEQ)
    (ALU_Control == `BNE) ? ({31'b0,operand_A != operand_B}): //Not Equals (BNE)
    32'b0; //Default Case						  
endmodule