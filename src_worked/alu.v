module ALU (
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output reg [31:0] ALU_result
);
//Determine output of ALU


always @(*) begin
  case (ALU_Control)
  //arithemetic and logic
    (`ADD)  : ALU_result <= operand_A + operand_B;
    (`SUB)  : ALU_result <= operand_A - operand_B;
    (`OR)   : ALU_result <= operand_A | operand_B;
    (`XOR)  : ALU_result <= operand_A ^ operand_B;
    (`AND)  : ALU_result <= operand_A & operand_B;
    (`SLL)  : ALU_result <= operand_A << operand_B;
    (`SRL)  : ALU_result <= operand_A >> operand_B;
    (`SRA)  : ALU_result <= $signed(operand_A) >>> operand_B;
    (`JAL)  : ALU_result <= operand_A;
    (`JALR) : ALU_result <= operand_A;
    //compare
    (`SLT)  : ALU_result <= ({31'b0,$signed(operand_A)<$signed(operand_B)});
    (`SLTU) : ALU_result <= ({31'b0,$unsigned(operand_A)<$unsigned(operand_B)});
    //remove branch
    (`STORE)  : ALU_result <= operand_A + operand_B;

    default: ALU_result <= 32'b0; 
  endcase

end	  
endmodule