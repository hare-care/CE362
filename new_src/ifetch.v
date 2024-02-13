module ifetch(
    //control signal from mem stage
    input npc_control,
    // data
    input [31:0] branch_pc,  // PC from exe stage
    input rst,
    input clk,
    output [31:0] instruction,
    output reg[31:0]PC,
    output halt
);
    reg [31:0]NPC;
    reg [31:0] PC_in;
    wire [31:0]PC_out;
    wire [31:0]InstWord;
    wire [6:0]opcode;

    //mini decoder for JAL and static branch predict
    mini_decoder mini_decoder(
        .instruction(InstWord),
        .PC(PC_in),
        .PC_predict(PC_out)
    );
    assign PC=PC_in;
    // assign NPC=npc_control ?  branch_pc: PC+4;
   // PC register, insturction fetch
    always @ (negedge clk)begin
     if (!rst)
       NPC <= 32'b0;
    else if (npc_control) begin
        NPC<= branch_pc;
    end
    else begin
        NPC <= PC_out
    end
    end
    always @(*) begin
        if (!rst) 
         PC_in=32'b0;
        else
         PC_in=NPC;
    end

//    Reg PC_REG(
//     .Din(NPC), 
//     .Qout(PC), 
//     .WEN(1'b0), 
//     .CLK(clk), 
//     .RST(rst)
//     );
   InstMem IMEM(
    .Addr(NPC), 
    .Size(`SIZE_WORD), 
    .DataOut(InstWord), 
    .CLK(clk)
    );
    assign instruction=InstWord;
    assign opcode = InstWord[6:0];
    assign halt = !((opcode == `R_TYPE)||(opcode == `I_TYPE)||(opcode == `S_TYPE)||(opcode == `I_TYPE_LOAD)
   ||(opcode == `B_TYPE)||(opcode == `I_JALR) ||(opcode == `J_JAL)||(opcode == `U_AUIPC)||(opcode == `U_LUI));
endmodule