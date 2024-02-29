module decode_stage(
    input clk,
    input rstn,
    //from control 
    // input wrEn_Dec,     //reg file write enable 
    input [5:0]ALU_Control,
    input branch_op,
    //from Ifectch
    input [31:0]PC,
    input [31:0]instruction,
    //from wirte back 
    input wrEN_WB,
    input [4:0]Rd_WB, //  from write back
    input [31:0]RWrdata_WB,  // write back data
    //data forwarding
    input [4:0] Rd_Exec,
    input mem_wEn_Exec,
    input [4:0] Rd_Mem,
    input mem_wEn_Mem,
    input [31:0] Data_mem_Mem,
    input [31:0] ALU_output_Mem,
    input [6:0]opcode_Mem,  // define whether it is a load operation 
    //to Exec
    output [31:0]Rdata1,
    output [31:0]Rdata2,
    output [31:0] imm32,    // genertae immediate value
    output [4:0] Rd_Dec,      // pass to next stage for write back
    output reg[1:0] forward_select_A_Dec,  
    output reg[1:0] forward_select_B_Dec,
    // to IF
    output reg npc_control,
    output reg [31:0]jump_target_PC,    // PC_exec_out
    //stall control
    output reg wait_signal_c // for wait_signal_c==1 ,wait 1 cycle 

);
reg [31:0]operand_A,operand_B;
wire[4:0] Rsrc1,Rsrc2;
reg [4:0] Rdst_in;
reg [31:0] RWrdata;
reg wrEn;
reg wait_signal;
reg [1:0] forward_select_A,forward_select_A_c;
reg [1:0] forward_select_B,forward_select_B_c;
reg jump_flag,branch_jump_flag;
reg [1:0]predict_result;

decoder decoder_unit (
      // input            
      .instruction(instruction),  
      //output 
      // InstWord decode
      .read_sel1(Rsrc1),      
      .read_sel2(Rsrc2),       
      .rd(Rd_Dec), 
      .imm32(imm32)            
   );

RegFile RF(
        .AddrA(Rsrc1), 
        .DataOutA(Rdata1), 
	      .AddrB(Rsrc2), 
        .DataOutB(Rdata2), 
	      .AddrW(Rdst_in), 
        .DataInW(RWrdata), 
        .WenW(wrEn),  // change write enable
        .CLK(clk)
        );  

/*---------------------branch JALR calculation and data forwading ------------*/
// branch result calculation 
branch_unit branch_unit(
  .ALU_Control(ALU_Control),
  .operand_A(operand_A),
  .operand_B(operand_B),
  .branch_result(branch_result)
);
//control PC+4 write  to register file for JAL and JALR   
always @(*) begin
  // save the current PC+4 when it is a jump 
  // if (ALU_Control==`JAL||ALU_Control==`JALR) begin
  //   Rdst_in=Rd_Dec;
  //   RWrdata=PC+4;
  //   wrEn=wrEn_Dec;
  // end
  // else begin
  Rdst_in=Rd_WB;
  RWrdata=RWrdata_WB;
  wrEn=wrEN_WB;
  // end
end 
//regiter the key decision signals
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    wait_signal=1'b0;
    forward_select_A=2'b00;
    forward_select_B=2'b00;
  end
  else begin
    wait_signal=wait_signal_c;
    forward_select_A=forward_select_A_c;
    forward_select_B=forward_select_B_c;
  end
end
// comb logic
always @(*) begin
    //default values
    forward_select_A_c=2'b00;
    forward_select_B_c=2'b00;
    wait_signal_c=1'b0;
    operand_A=32'b0;
    operand_B=32'b0;
    jump_target_PC=32'b0;
    jump_flag=1'b0; 
    branch_jump_flag=1'b0;
    npc_control=1'b0;
    forward_select_A_Dec=2'b0;
    forward_select_B_Dec=2'b0;
    predict_result=2'b0;
    /* it is branch_op and JALR, check conflict of register*/
  //start
  if (branch_op==1'b1 || ALU_Control==`JALR)  begin // if branch or JALR
   //not a stall and wait, check conflict regiter or direct calculate branch and JALR
    if (wait_signal==1'b0) begin 
      // conflict with Rsrc1, wait for 1 cycle
      if (Rd_WB!=5'b0 && Rd_WB==Rsrc1 && wrEN_WB==1'b1) begin
        wait_signal_c=1'b1;
        forward_select_A_c=2'b11;
      end
      else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc1 && mem_wEn_Mem==1'b1) begin //conflict with Mem stage
        wait_signal_c=1'b1;
        forward_select_A_c=2'b01;  
      end
      else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc1 && mem_wEn_Exec==1'b1) begin // conflict with Exec stage
        wait_signal_c=1'b1;
        forward_select_A_c=2'b10;  
      end
      else begin
      // no conflict
        operand_A=Rdata1;
      end
      // conflict with Rsrc2, wait for 1 cycle
      if (Rd_WB!=5'b0 && Rd_WB==Rsrc2 && wrEN_WB==1'b1) begin
        wait_signal_c=1'b1;
        forward_select_B_c=2'b11;
      end
      else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc2 && mem_wEn_Mem==1'b1) begin
        wait_signal_c=1'b1;
        forward_select_B_c=2'b01;   
      end
      else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc2 && mem_wEn_Exec==1'b1) begin
        wait_signal_c=1'b1;
        forward_select_B_c=2'b10;  
      end
      else begin
        // no conflict
        operand_B=Rdata2;
      end
    end
    // has wait for 1 cycle, forward the data to dec stage  
    else if (wait_signal==1'b1)begin  
      wait_signal_c=1'b0;
      //operand A forwarding
      if (forward_select_A==2'b11) begin
          operand_A=Rdata1;
      end
      else if(forward_select_A==2'b01) begin  //forward the data at WB stage
          operand_A=RWrdata_WB;  //include both load arithmetic
      end
      else if (forward_select_A==2'b10) begin //forward the data at Mem
        if(opcode_Mem==`I_TYPE_LOAD)
          operand_A=Data_mem_Mem;   // load operation
        else
          operand_A=ALU_output_Mem;   //Arithmetic operation
      end
      else begin
        operand_A=Rdata1;    // keep the same for waiting other operand
      end
      // Operand B forwarding
      if (forward_select_B==2'b11) begin
          operand_B=Rdata2;
      end
      else if(forward_select_B==2'b01) begin  //forward the data at WB stage
          operand_B=RWrdata_WB;  //include both load arithmetic
      end
      else if (forward_select_B==2'b10) begin //forward the data at Mem
        if(opcode_Mem==`I_TYPE_LOAD)
          operand_B=Data_mem_Mem;   // load operation
        else
          operand_B=ALU_output_Mem;   //Arithmetic operation
      end
      else begin
        operand_B=Rdata2;     // keep the same for waiting other operand
      end
    end
    //no conflict in this cycle, calculate branch and JALR 
    if (wait_signal_c==1'b0) begin 
      //check prediction result
      if (imm32[31]==1'b1) begin  // it is a jump back, predict PC jump
        if (branch_result==1'b1) begin  //right prediction,  the PC has jumped, continue
          predict_result=2'b11; 
        end
        else if (branch_result==1'b0) begin //wrong prediction, the PC doesnt jump, flush 1 stage and reload the PC 
          predict_result=2'b01;
        end
      end
      else if (imm32[31]==1'b0) begin  // no jump back, predict PC+4
        if (branch_result==1'b1) begin  //  predict wrong, PC should jump, flush 1 stage and load PC + imm
          predict_result=2'b10;
        end
        else if (branch_result==1'b0) begin //  predict right, PC not jump, continue 
            predict_result=2'b11; 
        end
      end
      else begin
        predict_result=2'b0;
      end
      // claculate next PC value and and PC select control signal 
      if (ALU_Control == `JALR) begin  // jump operation 
        jump_target_PC=operand_A+imm32;
        branch_jump_flag=1'b0;
        jump_flag=1'b1;
      end
      else if (branch_op==1'b1) begin    // branch operation 
        if (predict_result==2'b01) begin
          jump_target_PC=PC+4;
          branch_jump_flag=1'b1;
        end
        else if (predict_result==2'b10) begin
          jump_target_PC=PC + imm32;
          branch_jump_flag=1'b1;
        end
        else begin
          jump_target_PC=32'b0;  
          branch_jump_flag=1'b0;
        end
        jump_flag=1'b0;
      end
      else begin
        jump_target_PC=32'b0;
        jump_flag=1'b0;
        branch_jump_flag=1'b0;
      end
      // assign next pc control signal
      if (jump_flag||branch_jump_flag) begin   // identify jump operation
          npc_control=1'b1;
      end
      else begin
          npc_control=1'b0; 
      end
    end
  end
  //end
  /* it is branch_op and JALR, check conflict of register*/

  /* not a branch or JALR, normal forwarding check, check any conflict of register */
  //start
  else begin 
    // dont care about WB situation because path is short compared to branch path
    if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc1 && mem_wEn_Mem==1'b1) begin //not a store operation and write back desitination same as required reg address
      forward_select_A_Dec=2'b01;  // forward WB data to Exec in next cycle
    end
    else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc1 && mem_wEn_Exec==1'b1)
      forward_select_A_Dec=2'b10; // forward Mem data to Exec in next cycle
    else 
      forward_select_A_Dec=2'b00;  // dont forward data
    if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc2 && mem_wEn_Mem==1'b1) begin //not a store operation and write back desitination same as required reg address
      forward_select_B_Dec=2'b01;   // forward WB data to Exec in next cycle
    end
    else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc2 && mem_wEn_Exec==1'b1)
      forward_select_B_Dec=2'b10;   // forward Mem data to Exec in next cycle
    else 
      forward_select_B_Dec=2'b00;    // dont forward data
  end
  // **** as the WB stage is written into the reg file during falling edge, dont do forwarding on WB ****
  //end
  /* not a branch or JALR, check any conflict of register, normal forwarding */
end

endmodule