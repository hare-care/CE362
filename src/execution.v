//pass Rdata2 to memaccess 
//pass Rd to memaccess 
//pass PC, imm32 to memaccess
// See memaccess to construct branch PC using jump_flag and jump_target_PC
module execution(
  //control signal
  input [1:0] op_A_sel,
  input op_B_sel,
  input [5:0]ALU_Control,
    // data

  //from decode
  input [31:0] Rdata1, //Read Data 1
  input [31:0] Rdata2, //Read Data 1
  input [31:0] imm32,
  input [31:0] PC,//PC_Exec_in
  input [4:0] Rsrc1_Exec,
  input [4:0] Rsrc2_Exec,
  // fromWB
  input [4:0] Rd_WB,
  input wrEn_WB,
  input [31:0]RWrdata_WB,
  //from Mem
  input [4:0] Rd_Mem,
  input mem_wEn_Mem,
  input [31:0]Data_mem_Mem,
  output [31:0] ALU_result

);
reg [31:0] operand_A; // operand A
reg [31:0] operand_B;  // operand B
//ALU
ALU ALU_inst (
  .ALU_Control(ALU_Control),  
  .operand_A(operand_A),      
  .operand_B(operand_B),      
  .ALU_result(ALU_result)     
);


/*adding data path in operand a and b mux to fix data hazard*/

// process operand A B
always @(*) begin
  //data forward operand-A
  if(Rd_WB!=5'b0 && Rd_WB==Rsrc1_Exec&& wrEN_WB ==1'b0) begin
    operand_A=RWrdata_WB;  //forward from WB to exec
  end
  else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc1_Exec && mem_wEn_Mem==1'b0) begin
    operand_A=Data_mem_Mem;   //from mem to exec
  end
  else begin
    //normal selection
    case (op_A_sel)
      2'b00: operand_A=Rdata1;
      2'b01: operand_A=PC;  //AUIPC 
      2'b10:  operand_A=PC + 32'd4; // jump(can be moved to IF)
      default: operand_A=32'b0;//LUI
    endcase
  end
  // data forward operand_B
  if(Rd_WB!=5'b0 && Rd_WB==Rsrc2&& wrEN_WB ==1'b0) begin
    operand_B=RWrdata_WB;  //forward from WB to exec
  end
  else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc2 && mem_wEn_Mem==1'b0) begin
    operand_B=Data_mem_Mem;
  end
  else begin
    //normal selection 
    if (op_B_sel==1'b1) begin
      operand_B=imm32;
    end
    else begin
      operand_B=Rdata2;
    end
  end
end
  /*adding data path in operand a and b mux to fix data hazard*/

endmodule