module execution(
  //from control signal
  input [1:0] op_A_sel,
  input op_B_sel,
  input [5:0]ALU_Control,
  //from decode
  input [31:0] Rdata1, //Read Data 1
  input [31:0] Rdata2, //Read Data 1
  input [31:0] imm32,
  input [31:0] PC,//PC_Exec_in
  input [4:0] Rsrc1_Exec,
  input [4:0] Rsrc2_Exec,
  input [1:0] forward_select_A,
  input [1:0] forward_select_B,
  // fromWB
  input [4:0] Rd_WB,
  input wrEn_WB,
  input [31:0]RWrdata_WB,
  //from Mem
  input [4:0] Rd_Mem,
  input mem_wEn_Mem,
  input [31:0]Data_mem_Mem,
  input [31:0] ALU_output_Mem,
  input [6:0]opcode_Mem,
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
  if(forward_select_A==2'b01) begin
    operand_A=RWrdata_WB;  //include both load arithmetic
  end
  else if (forward_select_A==2'b10) begin
    if(opcode_Mem==`I_TYPE_LOAD)
      operand_A=Data_mem_Mem;   // load operation
    else
      operand_A=ALU_output_Mem;   //Arithmetic operation
  end
  else begin
    //normal selection
    case (op_A_sel)
      2'b00: operand_A=Rdata1;
      2'b01: operand_A=PC;  //AUIPC 
      2'b10:  operand_A=PC + 32'd4; // jump(should be removed)
      default: operand_A=32'b0;//LUI
    endcase
  end
  // data forward operand_B
  //forward from WB to exec
  if(forward_select_B==2'b01) begin
    operand_B=RWrdata_WB;  
  end
  //forward from Mem to Exec
  else if (forward_select_B==2'b10) begin
    if (opcode_Mem==`I_TYPE_LOAD)
      operand_B=Data_mem_Mem;
    else 
      operand_B=ALU_output_Mem;
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