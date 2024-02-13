module branch_unit (
    input [5:0]ALU_Control,
    input [31:0] operand_A,
    input [31:0] operand_B,
    output branch_result
);
always @(*) begin
     case (ALU_Control)
        (`BLTU) : branch_result <=  ($unsigned(operand_A)<$unsigned(operand_B));
        (`BGE)  : branch_result <= ($signed(operand_A)>=$signed(operand_B));
        (`BGEU) : branch_result <= ($unsigned(operand_A)>=$unsigned(operand_B));
        (`BEQ)  : branch_result <= (operand_A == operand_B);
        (`BNE)  : branch_result <= (operand_A != operand_B);
        (`BLT)  : branch_result <= ($signed(operand_A)<$signed(operand_B));
    default: branch_result<= 1'b0;
 endcase  
end
 
endmodule