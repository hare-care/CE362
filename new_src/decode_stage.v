//remeber to pass the PC
module decode_stage(
    input clk,
    //control signal
    input wrEn,     // write back enable 
    input [5:0]ALU_Control,
    input branch_op,
    //from Ifectch
    input [31:0]PC,
    //wirte back data
    input [31:0]instruction,
    input [4:0]Rdst_in, //  from write back
    input [31:0]RWrdata,  // write back data
    //data forwarding
    input [4:0] Rd_Exec,
    input [4:0] Rd_Mem,
    input [4:0] Rd_WB,
    input mem_wEn_Mem,
    input wrEn_WB,
    input [1:0]wait_signal_WB,
    output [31:0]Rdata1,
    output [31:0]Rdata2,
    output [31:0] imm32,    // genertae immediate value
    // to IF
    output npc_control,
    output reg [31:0]jump_target_PC,    // PC_exec_out
    //to Exec
    output  [4:0]Rsrc1,   // output for data forwarding
    output  [4:0]Rsrc2,
    output [4:0] Rdst_out,      // pass to next stage for write back
    output reg [1:0]wait_signal

);
// wire [31:0] Rdata1; // read data 1
// wire [31:0] Rdata2;  // read data 2
// wire [4:0] Rsrc1,Rsrc2; 
// wire Rdata1_sel,Rdata2_sel;
decoder decoder_unit (
      // input            
      .instruction(instruction),  
      //output 
      // InstWord decode
      .read_sel1(Rsrc1),      
      .read_sel2(Rsrc2),       
      .rd(Rdst_out), 
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
/*adjust calculation position of JALR and branch*/
wire branch_result;
reg branch_jump_flag;
// branch calculation 
branch_unit branch_unit(
  .ALU_Control(ALU_Control),
  .operand_A(operand_A),
  .operand_B(operand_B),
  .branch_result(branch_result)
);

  reg [31:0]operand_A;
  reg [31:0]operand_B;
  reg [31:0] JALR_Rdata1;

always @(*) begin
  if(wait_signal_WB==2'b01) begin
          operand_A = ALU_output_Exec;  //from exec to dec
      JALR_Rdata1=ALU_output_Exec;
  end

  else if ()
// forward branch data operand A and B, or JALR data at Rdata 1
  if(Rd_WB!=5'b0 && Rd_WB==Rsrc1&& wrEN_WB ==1'b0) begin
    operand_A=RWrdata_WB;  //forward from WB to dec
    JALR_Rdata1=RWrdata_WB;
  end
  else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc1 && mem_wEn_Mem==1'b0) begin
    operand_A=Data_mem_Mem;   //from mem to dec
    JALR_Rdata1=Data_mem_Mem;
  end
  else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc1) begin
    wait_signal=2'b01;
    // operand_A = ALU_output_Exec;  //from exec to dec
    // JALR_Rdata1=ALU_output_Exec;
  end
  else begin
    operand_A=Rdata1;   //dec
    JALR_Rdata1=Rdata1;
  end
  if(Rd_WB!=5'b0 && Rd_WB==Rsrc2&& wrEN_WB ==1'b0) begin
    operand_B=RWrdata_WB;  //forward from WB to dec
  end
  else if (Rd_Mem!=5'b0 && Rd_Mem==Rsrc2 && mem_wEn_Mem==1'b0) begin
    operand_B=Data_mem_Mem;   //from mem to dec
  end
  else if (Rd_Exec!= 5'b0 && Rd_Exec==Rsrc2) begin
    wait_signal=2'b01;
    //operand_B = ALU_output_Mem;  //from dec to exec
  end
  else begin
    operand_B=Rdata2;   //dec
  end 
end

always @(*) begin
  
// claculate next PC value and and jump signal 
  if (ALU_Control == `JALR) begin  // jump operation 
    jump_target_PC=JALR_Rdata1+imm32;
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
always @(*) begin
    branch_jump_flag = branch_op & branch_result;  // branch will be executed 
    if (jump_flag||branch_jump_flag) begin   // identify jump operation
        npc_control=1'b1;
    end
    else begin
        npc_control=1'b0; 
    end
end
/*adjust calculation position of JALR and branch*/
endmodule