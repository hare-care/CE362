// pass Rd to write back
// pass ALU_result to write back
// pass jump_target_PC to IF
module mem_access(
    // synchronous memory write 
    input clk,
    //from conrtol unit 
    input mem_wEn,          
    input load_extend_sign,  
    input branch_op,       
    input [1:0]MemSize,
    // from execution stage 
    input [31:0] PC,
    input [31:0] imm32,
    input [31:0]Rdata2,     
    input [31:0]ALU_result, 
    input jump_flag,   
    output [31:0]DataWord,
    output reg npc_control    

);
reg ALU_branch_flag;
reg branch_jump_flag;
// process next PC control signal based on ALU branch result
always @(*) begin
    ALU_branch_flag=ALU_result[0];
    branch_jump_flag = branch_op & ALU_branch_flag;
    if (jump_flag||branch_jump_flag) begin   // identify jump operation
        npc_control=1'b1;
    end
    else begin
        npc_control=1'b0; 
    end
end
// data memory access
DataMem DMEM(.Addr(ALU_result), .Size(MemSize), .load_extend_sign(load_extend_sign),.DataIn(Rdata2), .DataOut(DataWord), .WEN(mem_wEn), .CLK(clk));

endmodule