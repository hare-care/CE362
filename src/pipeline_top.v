module pipeline_top (
    input clk, rstn,
    input [31:0] test
);

// Pipeline register nets
wire [31:0] PC_IF;
reg [31:0] PC_Dec, PC_Exec_in,PC_Exec_out, PC_Mem;
wire [31:0] Instruction_IF; 
reg [31:0] Instruction_Dec;
reg [31:0] Imm_Mem,Imm_Exec, Imm_Dec;  //add Imm_Mem
reg [31:0] A_Exec, A_Dec;  //data1
reg [31:0] B_Exec, B_Dec, B_Mem;  //data2
reg [31:0] Rd_Dec, Rd_Exec,Rd_Mem,Rd_WB;  //add meme and write abck
reg [31:0] Rt_Dec, Rt_Exec;  // not sure what it is 
reg [31:0] Reg_dest_Exec, Reg_dest_Mem, Reg_dest_WB;
reg [31:0] ALU_output_Exec, ALU_output_Mem, ALU_output_WB;
reg [31:0] Zero_Exec, Zero_Mem;
reg [31:0] Data_mem_Mem, Data_mem_WB;

reg npc_control;  // from mem to IF
wire jump_flag;   // from exe to me 
wire jump_target_PC;  //from exe to mem

// fetch
ifetch fetch (.branch_pc(PC_Mem), .npc_control(npc_control), .instruction(Instruction_IF), .PC (PC_IF));

// decode
//decode_stage decode ((), );

// execution
//execution_unit ex ();

// memory

// WB


// pipeline registers
always @(posedge clk or negedge rstn) begin 
    if (!rstn) begin
        PC_Dec <= 32'b0;
        Instruction_Dec <= 32'b0;

        PC_Exec <= 32'b0;
        A_Exec <= 32'b0;
        B_Exec <= 32'b0;
        Imm_Exec <= 32'b0;
        Rt_Exec <= 32'b0;
        Rd_Exec <= 32'b0;
        Rd_Mem<=32'b0;  // add more rd 
        Rd_WB<=32'b0;

        PC_Mem <= 32'b0;
        Zero_Mem <= 32'b0;
        ALU_output_Mem <= 32'b0;
        B_Mem <= 32'b0;
        Reg_dest_Mem <= 32'b0;

        Data_mem_WB <= 32'b0;
        Reg_dest_WB <= 32'b0;
        ALU_output_WB <= 32'b0;
    end
    else begin
        PC_Dec <= PC_IF;
        Instruction_Dec <= Instruction_IF;

        PC_Exec_in <= PC_Dec;
        A_Exec <= A_Dec;
        B_Exec <= B_Dec;
        Imm_Exec <= Imm_Dec;
        Rt_Exec <= Rt_Dec;
        Rd_Exec <= Rd_Dec;
        Rd_Mem<=Rd_Exec;  // add more rd 
        Rd_WB<=Rd_Mem;

        PC_Mem <= PC_Exec_out;
        Zero_Mem <= Zero_Exec;
        ALU_output_Mem <= ALU_output_Exec;
        B_Mem <= B_Exec;
        Reg_dest_Mem <= Reg_dest_Exec;

        Data_mem_WB <= Data_mem_Mem;
        Reg_dest_WB <= Reg_dest_Mem;
        ALU_output_WB <= ALU_output_Mem;
    end
end

endmodule