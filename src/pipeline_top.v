module pipeline_top (
    input clk, rstn,
    input [31:0] test
);

// Pipeline register nets
wire [31:0] PC4_IF;
reg [31:0] PC4_Dec, PC4_Exec, PC4_Mem;
wire [31:0] Instruction_IF;
reg [31:0] Instruction_Dec;
reg [31:0] Imm_Exec, Imm_Dec;
reg [31:0] A_Exec, A_Dec;
reg [31:0] B_Exec, B_Dec, B_Mem;
reg [31:0] Rd_Dec, Rd_Exec;
reg [31:0] Rt_Dec, Rt_Exec;
reg [31:0] Reg_dest_Exec, Reg_dest_Mem, Reg_dest_WB;
reg [31:0] ALU_output_Exec, ALU_output_Mem, ALU_output_WB;
reg [31:0] Zero_Exec, Zero_Mem;
reg [31:0] Data_mem_Mem, Data_mem_WB;

assign PC4_IF = test;


// fetch
//ifetch fetch (.branch_pc(), .npc_control, .instruction(), .PC4 ());

// decode
//decode_stage decode ((), );

// execution
//execution_unit ex ();

// memory

// WB


// pipeline registers
always @(posedge clk or negedge rstn) begin 
    if (!rstn) begin
        PC4_Dec <= 32'b0;
        Instruction_Dec <= 32'b0;

        PC4_Exec <= 32'b0;
        A_Exec <= 32'b0;
        B_Exec <= 32'b0;
        Imm_Exec <= 32'b0;
        Rt_Exec <= 32'b0;
        Rd_Exec <= 32'b0;

        PC4_Mem <= 32'b0;
        Zero_Mem <= 32'b0;
        ALU_output_Mem <= 32'b0;
        B_Mem <= 32'b0;
        Reg_dest_Mem <= 32'b0;

        Data_mem_WB <= 32'b0;
        Reg_dest_WB <= 32'b0;
        ALU_output_WB <= 32'b0;
    end
    else begin
        PC4_Dec <= PC4_IF;
        Instruction_Dec <= Instruction_IF;

        PC4_Exec <= PC4_Dec;
        A_Exec <= A_Dec;
        B_Exec <= B_Dec;
        Imm_Exec <= Imm_Dec;
        Rt_Exec <= Rt_Dec;
        Rd_Exec <= Rd_Dec;

        PC4_Mem <= PC4_Exec;
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