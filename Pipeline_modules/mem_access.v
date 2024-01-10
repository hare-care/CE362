// branch control logic on top level

// assign npc_control= branch_jump_flag||jump_flag;
// assign branch_pc = jump_flag ? jump_target_PC:
// branch_jump_flag ? branch_traget_PC:
// 32'b0;


// pass Rd to write back
// pass ALU_result to write back
module mem_access(
    // synchronous memory write 
    input clk,
    //from conrtol unit 
    input mem_wEn,          
    input load_extend_sign,  
    input branch_op,       
    input [1:0]MemSize,
    // from execution stage 
    input PC,
    input [31:0] imm32,
    input [31:0]Rdata2,     
    input [31:0]ALU_result, 
    output [31:0]DataWord,
    output branch_jump_flag,
    output [31:0] branch_target_pc
);
// process branch result
wire ALU_branch_flag;
assign ALU_branch_flag=ALU_result[0];
assign branch_jump_flag = branch_op & ALU_branch_flag;
assign branch_target_pc=branch_jump_flag?(PC + imm32):32'b0;
// data access
DataMem DMEM(.Addr(ALU_result), .Size(MemSize), .load_extend_sign(load_extend_sign),.DataIn(Rdata2), .DataOut(DataWord), .WEN(MemWrEn), .CLK(clk));

endmodule