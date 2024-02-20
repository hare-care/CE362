module pipeline_top (
    input clk, rstn,
    output halt_out,
    output [31:0] instr_out, data_out
   // input [31:0] test
);

reg halt;

// stall and flush
wire stall;




// Pipeline register nets
//PC forward
wire [31:0] PC_IF,PC_Dec_out;
reg [31:0] PC_Dec_in,PC_Exec_in;
wire [31:0] PC_Exec_out;
reg [31:0] PC_Mem;
//Instructions
wire [31:0] Instruction_IF; 
reg [31:0] Instruction_Dec,Instruction_Exec,Instruction_Mem,Instruction_WB;
//Immeditae 32 bits
wire [31:0]Imm_Dec;
reg [31:0] Imm_Mem,Imm_Exec;  //add Imm_Mem
//Operand A and B for ALU
wire [31:0]A_Dec,B_Dec;
reg [31:0] A_Exec;  //operand A
reg [31:0] B_Exec;  //operand B
// Data1 and Data2 read from register file
wire [31:0]Rdata1_Dec;
reg [31:0] Rdata1_Exec;
wire [31:0]Rdata2_Dec;
reg [31:0] Rdata2_Exec,Rdata2_Mem;
// Write back address
wire [4:0]Rd_Dec;
reg [4:0] Rd_Exec,Rd_Mem,Rd_WB;  
//ALU results
wire [31:0]ALU_output_Exec;
reg [31:0] ALU_output_Mem, ALU_output_WB;
//Data memory read data
wire [31:0]Data_mem_Mem;
reg  [31:0]  Data_mem_WB;
// write back data to register file
wire [31:0] RWrdata_WB;
// branch and jump
wire jump_flag_Exec;
reg jump_flag_Mem;


//control unit
wire wrEn_Dec;
reg wrEn_Exec,wrEn_Mem,wrEN_WB;
wire [1:0]op_A_sel_Dec;
reg [1:0]op_A_sel_Exec;
wire op_B_sel_Dec;
reg op_B_sel_Exec;
wire [5:0]ALU_Control_Dec;
reg [5:0]ALU_Control_Exec;
wire branch_op_Dec;
reg branch_op_Exec,branch_op_Mem;
wire mem_wEn_Dec;
reg mem_wEn_Exec,mem_wEn_Mem;
wire [1:0] MemSize_Dec;
reg [1:0]MemSize_Exec,MemSize_Mem;
wire load_extend_sign_Dec;
reg load_extend_sign_Exec,load_extend_sign_Mem;
wire wb_sel_Dec;
reg wb_sel_Exec,wb_sel_Mem,wb_sel_WB;


// new signals
wire [6:0] opcode_Mem;

wire npc_control_Dec;  // from Dec to IF

wire [1:0]forward_select_A_Dec,forward_select_B_Dec;
reg [1:0] forward_select_A_Exec,forward_select_B_Exec;

wire wait_signal_Dec;

// halt detection
wire halt_IF;

//reg [31:0] Rt_Dec, Rt_Exec;  // not sure what it is 
//reg [31:0] Reg_dest_Exec, Reg_dest_Mem, Reg_dest_WB;
//reg [31:0] Zero_Exec, Zero_Mem;

assign halt_out = halt;
assign instr_out = Instruction_Dec;
assign data_out = RWrdata_WB;



// fetch
ifetch IF (
    .clk(clk),
    .rst(rstn),   //negative trigger
    // from mem_access
    .branch_pc(PC_Dec_out),    
    .npc_control(npc_control_Dec), 
    //output
    .instruction(Instruction_IF), 
    .PC (PC_IF),
    .halt(halt_IF)
    );
//control unit
control Control(
    .instruction(Instruction_Dec),
    .wEn(wrEn_Dec),
    .op_A_sel(op_A_sel_Dec),
    .op_B_sel(op_B_sel_Dec),
    .ALU_Control(ALU_Control_Dec),
    .branch_op(branch_op_Dec),
    .mem_wEn(mem_wEn_Dec),
    .MemSize(MemSize_Dec),
    .load_extend_sign(load_extend_sign_Dec),
    .wb_sel(wb_sel_Dec)
);
// decode
decode_stage Dec (
    .clk(clk),
    //from control
    .wrEn_Dec(wrEn_Dec),
    .ALU_Control(ALU_Control_Dec),
    .branch_op(branch_op_Dec),
    // from Ifetch
    .PC(PC_Dec_in),
    .instruction(Instruction_Dec),
    // from WB
    .wrEN_WB(wrEN_WB),
    .Rd_WB(Rd_WB),   //write back to register file
    .RWrdata_WB(RWrdata_WB),
    //data forwarding
    //Exec
    .Rd_Exec(Rd_Exec),
    .mem_wEn_Exec(mem_wEn_Exec),
    //Mem
    .Rd_Mem(Rd_Mem),
    .mem_wEn_Mem(mem_wEn_Mem),
    .Data_mem_Mem(Data_mem_Mem),
    .ALU_output_Mem(ALU_output_Mem),
    .opcode_Mem(opcode_Mem),
    //output 
    //to Exec
    // .operand_A(A_Dec),
    // .operand_B(B_Dec),
    .Rdata1(Rdata1_Dec),
    .Rdata2(Rdata2_Dec),
    .imm32(Imm_Dec),
    .Rd_Dec(Rd_Dec),
    .forward_select_A_Dec(forward_select_A_Dec),
    .forward_select_B_Dec(forward_select_B_Dec),
    //to IF
    .npc_control(npc_control_Dec),
    .jump_target_PC(PC_Dec_out),
    .wait_signal_c(wait_signal_Dec)
);

// execution
execution Exec (
    .op_A_sel(op_A_sel_Exec),
    .op_B_sel(op_B_sel_Exec),
    .ALU_Control(ALU_Control_Exec),
    // from decode
    .Rdata1(Rdata1_Exec),
    .Rdata2(Rdata2_Exec),
    .imm32(Imm_Exec),
    .PC(PC_Exec_in),
    .forward_select_A(forward_select_A_Exec),
    .forward_select_B(forward_select_B_Exec),
    //from WB
    .RWrdata_WB(RWrdata_WB),
    //from Mem
    .Data_mem_Mem(Data_mem_Mem),
    .ALU_output_Mem(ALU_output_Mem),
    .opcode_Mem(opcode_Mem),
    //ALU calculation result
    .ALU_result(ALU_output_Exec)
    );

// memory
mem_access Mem(
    .clk(clk),
    // control
    .mem_wEn(mem_wEn_Mem),
    .load_extend_sign(load_extend_sign_Mem),
    .branch_op(branch_op_Mem),
    .MemSize(MemSize_Mem),
    //from exec
    .instruction(Instruction_Mem),
    .PC(PC_Mem),
    .imm32(Imm_Mem),
    .Rdata2(Rdata2_Mem),
    .ALU_result(ALU_output_Mem),
    //output 
    .DataWord(Data_mem_Mem),
    .opcode(opcode_Mem)
);

// WB
write_back WB(
    //control
    .wb_sel(wb_sel_WB),
    .ALU_result(ALU_output_WB),
    .DataWord(Data_mem_WB),
    // output to reg_file
    .RWrdata(RWrdata_WB)
);
// pipeline registers
always @(posedge clk or negedge rstn) begin 
    if (!rstn) begin
        // halt
        halt<=1'b0;
    //control
        wrEn_Exec<=1'b0;
        wrEn_Mem<=1'b0;
        wrEN_WB<=1'b0;
        ALU_Control_Exec<=6'b0;
        branch_op_Exec<=1'b0;
        branch_op_Mem<=1'b0;
        mem_wEn_Exec<=1'b0;
        mem_wEn_Mem<=1'b0;
        MemSize_Exec<=2'b0;
        MemSize_Mem<=2'b0;
        load_extend_sign_Exec<=1'b0;
        load_extend_sign_Mem<=1'b0;
        wb_sel_Exec<=1'b0;
        wb_sel_Mem<=1'b0;
        wb_sel_WB<=1'b0;


        //decoder
        
        PC_Dec_in <= 32'b0;
        Instruction_Dec <= 32'b0;
        Instruction_Exec<=32'b0;
        Instruction_Mem<=32'b0;
        Instruction_WB<=32'b0;

        
        //execution  
        PC_Exec_in <= 32'b0;
        A_Exec <= 32'b0;
        Rdata1_Exec<=32'b0;
        Rdata2_Exec<=32'b0;
        B_Exec <= 32'b0;
        Imm_Exec <= 32'b0;
        Rd_Exec <= 32'b0;
        op_A_sel_Exec<=2'b0;
        op_B_sel_Exec<=1'b0;
        forward_select_A_Exec<=2'b0;
        forward_select_B_Exec<=2'b0;

        //memory access
        
        PC_Mem <= 32'b0;

        ALU_output_Mem <= 32'b0;
        Rdata2_Mem<=32'b0;
        Rd_Mem<=32'b0;  // add more rd 
        jump_flag_Mem<= 32'b0; //add jump flag

        //writeback
        Data_mem_WB <= 32'b0;
        ALU_output_WB <= 32'b0;
        Rd_WB<=32'b0;  //add more rd



       // Rt_Exec <= 32'b0;
        //PC_Exec_out<=32'B0;
        //Reg_dest_WB <= 32'b0;
        //B_Mem <= 32'b0;
        //Reg_dest_Mem <= 32'b0;
        //Zero_Mem <= 32'b0;
    end
    else begin
        //halt
        halt<=halt_IF;
        //conrtol path
        wrEn_Exec<=(stall)? wrEn_Exec : wrEn_Dec;
        ALU_Control_Exec<=(stall)? ALU_Control_Exec : ALU_Control_Dec;
        branch_op_Exec<=(stall)? branch_op_Exec : branch_op_Dec;
        mem_wEn_Exec<=(stall)? mem_wEn_Exec : mem_wEn_Dec;
        MemSize_Exec<=(stall)? MemSize_Exec : MemSize_Dec;
        load_extend_sign_Exec<=(stall)? load_extend_sign_Exec : load_extend_sign_Dec;
        wb_sel_Exec<=(stall)? wb_sel_Exec : wb_sel_Dec;
        op_A_sel_Exec<=(stall)?op_A_sel_Exec:op_A_sel_Dec;
        op_B_sel_Exec<=(stall)?op_B_sel_Exec:op_A_sel_Dec;
        PC_Exec_in<=(stall)?PC_Exec_in:PC_Dec_in;
        forward_select_A_Exec<=(stall)?forward_select_A_Exec:forward_select_A_Dec;
        forward_select_B_Exec<=(stall)? forward_select_B_Exec:forward_select_B_Dec;

        wrEn_Mem<=(stall)? wrEn_Mem : wrEn_Exec; // duplicate in question
        branch_op_Mem<=(stall)? branch_op_Mem : branch_op_Exec;
        mem_wEn_Mem<=(stall)? mem_wEn_Mem : mem_wEn_Exec;
        MemSize_Mem<=(stall)? MemSize_Mem : MemSize_Exec;
        load_extend_sign_Mem<=(stall)? load_extend_sign_Mem : load_extend_sign_Exec;
        wb_sel_Mem<=(stall)? wb_sel_Mem : wb_sel_Exec;

        wb_sel_WB<=(stall)? wb_sel_WB : wb_sel_Mem;
        wrEn_Mem<=(stall)? wrEn_Mem : wrEn_Exec; // there seems to be duplicate is this right?

        // data path
        PC_Dec_in <= (stall)? PC_Dec_in : PC_IF;
        Instruction_Dec <= (stall)? Instruction_Dec : Instruction_IF;

        PC_Exec_in <= (stall)? PC_Exec_in : PC_Dec_in;
        A_Exec <= (stall)? A_Exec : A_Dec;
        B_Exec <= (stall)? B_Exec : B_Dec;
        Rdata1_Exec<= (stall)? Rdata1_Exec : Rdata1_Dec;
        Rdata2_Exec<= (stall)? Rdata2_Exec : Rdata2_Dec;
        Imm_Exec <= (stall)? Imm_Exec : Imm_Dec;
        Rd_Exec <= (stall)? Rd_Exec : Rd_Dec;
        Instruction_Exec<=(stall)?Instruction_Exec:Instruction_Dec;

        PC_Mem <= (stall)? PC_Mem : PC_Exec_out;
        ALU_output_Mem <= (stall)? ALU_output_Mem : ALU_output_Exec;
        Rdata2_Mem<= (stall)? Rdata2_Mem : Rdata2_Exec;
        Rd_Mem<= (stall)? Rd_Mem : Rd_Exec;  // add more rd 
        jump_flag_Mem<= (stall)? jump_flag_Mem : jump_flag_Exec; // add jump flag
        Instruction_Mem<=(stall)? Instruction_Mem:Instruction_Exec;

        Data_mem_WB <= (stall)? Data_mem_WB : Data_mem_Mem;
        ALU_output_WB <= (stall)? ALU_output_WB : ALU_output_Mem;
        Rd_WB<= (stall)? Rd_WB : Rd_Mem; // add more rd 
        wrEN_WB<= (stall)? wrEN_WB : wrEn_Mem;
        Instruction_WB<=(stall)? Instruction_WB:Instruction_Mem;

        // Rt_Exec <= Rt_Dec;
        //  Zero_Mem <= Zero_Exec;
        //B_Mem <= B_Exec;
        //Reg_dest_Mem <= Reg_dest_Exec;
        // Reg_dest_WB <= Reg_dest_Mem;
    end
end

endmodule