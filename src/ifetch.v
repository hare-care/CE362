module ifetch(
    //control signal from mem stage
    input npc_control,
    // data
    input [31:0] branch_pc,  // PC from exe stage
    input rst,
    input clk,
    output [31:0] instruction,
    output [31:0]PC
);
    wire [31:0]NPC;
    wire [31:0]InstWord;
    assign NPC=npc_control ?  branch_pc: PC+4;
   // PC register, insturction fetch
   Reg PC_REG(.Din(NPC), .Qout(PC), .WEN(1'b0), .CLK(clk), .RST(rst));
   InstMem IMEM(.Addr(NPC), .Size(`SIZE_WORD), .DataOut(InstWord), .CLK(clk));
    assign instruction=InstWord;
endmodule