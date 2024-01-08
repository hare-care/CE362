module SingleCycleCPU#(
   parameter ADDRESS_BITS = 32)
   (halt, clk, rst);
   output halt;
   input clk, rst;


   // fetch to inetruction cache
   wire [31:0] PC,NPC ;
   wire [31:0] InstWord;
   //register file
   wire [4:0]  Rsrc1, Rsrc2, Rdst;
   wire [31:0] Rdata1, Rdata2, RWrdata;
   wire        RWrEn;               // low active 
   // instruction decode
   wire [6:0]  opcode;
   wire [6:0]  funct7;
   wire [2:0]  funct3;
   //decoder for control signals of ALU and register file
   wire [31:0] imm32;               // immediate operation 
   wire [5:0] ALU_Control;                // control ALU calculation 
   wire [1:0]op_A_sel;              // operand A MUX control
   wire op_B_sel;                   // operand B MUX control
   wire wEn;                        // register file write enable (write back/load)
   wire mem_wEn;                    // data cache write enable(store)
   // ALU computation 
   wire [31:0]operand_A;
   wire [31:0]operand_B;
   wire [31:0]ALU_result;
   wire ALU_branch_flag;            // get the LSB of ALU_result
   // branch and jump to fetch
   wire branch_op;                  // have done branch compare in ALU
   wire branch_jump_flag;                // branch jump to address enable
   wire next_PC_select;             // jump to address enable(b type/jal,jalr)
   wire [31:0]target_PC;                  // jump address target value
   // data cache , write back
   wire wb_sel;                     // write back mux control, from dcahce/ALU
   wire [31:0] DataAddr, StoreData, DataWord;
   wire [1:0]  MemSize;
   wire load_extend_sign;
   wire        MemWrEn;             // low active 
   
//------------------------------error detection------------------------------
   // Only support valid instructions
   assign halt = !((opcode == `R_TYPE)||(opcode == `I_TYPE)||(opcode == `S_TYPE)||(opcode == `I_TYPE_LOAD)
   ||(opcode == `B_TYPE)||(opcode == `I_JALR) ||(opcode == `J_JAL)||(opcode == `U_AUIPC)||(opcode == `U_LUI));

//----------------------------------------Instruction Fetch-------------------------------------------------------------------------//

   // PC register, insturction fetch
   Reg PC_REG(.Din(NPC), .Qout(PC), .WEN(1'b0), .CLK(clk), .RST(rst));
   InstMem IMEM(.Addr(PC), .Size(`SIZE_WORD), .DataOut(InstWord), .CLK(clk));
//-----------------------------------Instruction Decode------------------------------------------------------------------------------//

   // decoder 
   decoder #(
      .ADDRESS_BITS(32)        
   ) decoder_unit (
      // input
      .PC(PC),             
      .instruction(InstWord),  
      //output 
      // InstWord decode
      .opcode(opcode),
      .funct7(funct7),
      .funct3(funct3),
      .read_sel1(Rsrc1),      
      .read_sel2(Rsrc2),       
      .rd(Rdst),
      // ALU
      .imm32(imm32),             
      .op_A_sel(op_A_sel),        
      .op_B_sel(op_B_sel),         
      .ALU_Control(ALU_Control),  
      // branch
     .branch_op(branch_op),
      //data memory and writeback 
      .mem_wEn(mem_wEn),  
      .MemSize(MemSize),
      .load_extend_sign(load_extend_sign),
      .wEn(wEn),          
      .wb_sel(wb_sel)             
   );
   
   // register file
   assign RWrEn=~wEn;
   RegFile RF(.AddrA(Rsrc1), .DataOutA(Rdata1), 
	      .AddrB(Rsrc2), .DataOutB(Rdata2), 
	      .AddrW(Rdst), .DataInW(RWrdata), .WenW(RWrEn), .CLK(clk));
   
   // operand A MUX,  
	assign operand_A = (op_A_sel == 2'b00) ? Rdata1:  
							 (op_A_sel == 2'b01) ? PC:
							 (op_A_sel == 2'b10) ? (PC + 32'd4):
							 (32'b0);
   // operand B MUX  				 
	assign operand_B = op_B_sel ? imm32:Rdata2; 

//-------------------------------------Execution----------------------------------------------------------------------------//
   // Execution 
   // ALU 
   ALU ALU_inst (
    .ALU_Control(ALU_Control),  
    .operand_A(operand_A),      
    .operand_B(operand_B),      
    .ALU_result(ALU_result)     
   );
//-----------------------------------------------------------------------------------------------------------------//
   // Fetch Address Datapath

   // branch MUX 
   assign ALU_branch_flag=ALU_result[0];
   assign branch_jump_flag = branch_op & ALU_branch_flag;

   //target_pc MUX (target PC address of branch/jump)               
   assign target_PC = (branch_jump_flag == 1'b1||opcode == `J_JAL)? (PC + imm32)://branch/jal instructions 
                            (opcode == `I_JALR)? (Rdata1+imm32): //jalr instruction 
                            32'b0;                                                        //default 
   //next PC select mux  (jump or PC+4)
   assign next_PC_select= (branch_jump_flag == 1'b1 || opcode==`I_JALR || opcode==`J_JAL);
   assign NPC = next_PC_select ? target_PC:PC + 4;

   //-----------------------------------------------------------------------------------------------------------------//

   // Memory access

   // write to register MUX
   assign RWrdata = (wb_sel)? DataWord:ALU_result; // data back to register 
   // store datapath
   assign StoreData=Rdata2; // data from register to data cache
   // data cache
   DataMem DMEM(.Addr(ALU_result), .Size(MemSize), .load_extend_sign(load_extend_sign),.DataIn(StoreData), .DataOut(DataWord), .WEN(MemWrEn), .CLK(clk));
   assign MemWrEn=~mem_wEn;// negative high

   
endmodule // SingleCycleCPU


