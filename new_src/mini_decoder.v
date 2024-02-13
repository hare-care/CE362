module mini_decoder (
    input [31:0] instruction,
    input [31:0] PC,
    output reg[31:0]PC_predict
);
 wire [6:0]opcode;
 wire[31:0] u_imm_32;
 wire[19:0] u_imm;
 wire[12:0] sb_imm_orig;
 wire[31:0] sb_imm_32;
 wire jump_flag;
 wire branch_flag;
 reg[31:0] imm;
 reg branch_loop;


//calculate opcode
assign opcode=instruction[6:0]; 
//calculate immediate for branch and jump
assign u_imm = instruction[31:12];
assign u_imm_32 = {u_imm, 12'b000000000000}; 
assign sb_imm_orig = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign sb_imm_32 = { {19{sb_imm_orig[12]}}, sb_imm_orig}; 
//branch or jump operation?
assign jump_flag=(opcode==`J_JAL);
assign branch_flag= (opcode==`B_TYPE);

always @(*) begin
    // calculate jump target PC
    if (jump_flag) begin
      imm=u_imm_32;
    end
    else begin
      imm=sb_imm_32;
    end
    //predict branch true or not
    if (sb_imm_32==1'b1) begin
      branch_loop=1'b1; //go to lower PC,assume loop operation,assume jump
    end
    else begin
    branch_loop=1'b0;  //go to higher PC, assume not jump
    end
    //generate the next PC value
    if (branch_flag && branch_loop || jump_flag) begin
        PC_predict=PC+imm;
    end
    else begin
        PC_predict=PC+4;
    end
end
  
assign 
assign 

endmodule