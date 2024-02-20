// pass Rd to write back
// pass ALU_result to write back
// pass jump_target_PC to IF
module mem_access(
    // synchronous memory write 
    input clk,
    //from conrtol unit 
    input mem_wEn,          
    input load_extend_sign,       
    input [1:0]MemSize,
    // from execution stage 
    input [31:0]Rdata2,     
    input [31:0]ALU_result,
    output [31:0]DataWord
);


// data memory access
DataMem DMEM(
    .Addr(ALU_result), 
    .Size(MemSize), 
    .load_extend_sign(load_extend_sign),
    .DataIn(Rdata2), 
    .DataOut(DataWord), 
    .WEN(mem_wEn), 
    .CLK(clk)
    );

endmodule