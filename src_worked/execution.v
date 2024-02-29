module execution(
  //from control signal
  input [1:0] op_A_sel,
  input op_B_sel,
  input [5:0]ALU_Control,
  //from decode
  input [31:0] Rdata1, //Read Data 1
  input [31:0] Rdata2_in, //Read Data 1
  input [31:0] imm32,
  input [31:0] PC,//PC_Exec_in
  input [1:0] forward_select_A,
  input [1:0] forward_select_B,
  // fromWB
  input [31:0]RWrdata_WB,
  //from Mem
  input [31:0]Data_mem_Mem,
  input [31:0] ALU_output_Mem,
  input [6:0]opcode_Mem,
  output reg[31:0]Rdata2_out,
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
      2'b11: operand_A=32'b0;//LUI
      default: operand_A=32'b0;//LUI
    endcase
  end
  // data forward operand_B
  //forward from WB to exec
  if (op_B_sel==1'b1) begin
      operand_B=imm32;
  end 
  else begin
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
        operand_B=Rdata2_in;
    end
  end

  // add a data path for store operation
  if(ALU_Control==`STORE) begin
     if(forward_select_B==2'b01) begin
      Rdata2_out=RWrdata_WB;  
    end
    else if (forward_select_B==2'b10) begin
      if (opcode_Mem==`I_TYPE_LOAD)
        Rdata2_out=Data_mem_Mem;
      else 
        Rdata2_out=ALU_output_Mem;
    end
    else begin
      //normal selection 
        Rdata2_out=Rdata2_in;
    end
  end
  else begin
    Rdata2_out=32'b0;
  end

end
  /*adding data path in operand a and b mux to fix data hazard*/

endmodule