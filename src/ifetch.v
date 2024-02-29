module ifetch(
    //control signal from Dec stage
    input npc_control,
    input IF_stall,
    // data
    input [31:0] branch_pc,  // PC from exe stage
    input rst,
    input clk,
    output [31:0] instruction,
    output [31:0]PC,
    output halt
);
    reg [31:0] PC_in;
    wire [31:0]PC_out;
    wire [31:0]InstWord;
    wire [6:0]opcode;

   InstMem IMEM(
    .Addr(PC_in), 
    .Size(`SIZE_WORD), 
    .DataOut(InstWord), 
    .CLK(clk)
    );
    //mini decoder for JAL and static branch predict
    mini_decoder mini_decoder(
        .instruction(InstWord),
        .PC(PC_in),
        .PC_predict(PC_out)
    );
   assign PC=PC_in;  // output for the current PC value
   // assign instruction_PC=npc_control ?  branch_pc: PC_in+4; // select for the right PC to get instruction
   // PC register, insturction fetch
    always @ (negedge clk)begin
        if (!rst) begin
            PC_in <= 32'b0;
        end
        else if (npc_control) begin
            PC_in <= (IF_stall)?PC:branch_pc; //add stall signal
        end
        else begin
            PC_in <= (IF_stall)?PC:PC_out;
        end
    end
    assign instruction=InstWord;
    assign opcode = InstWord[6:0];
    assign halt = !((opcode == `R_TYPE)||(opcode == `I_TYPE)||(opcode == `S_TYPE)||(opcode == `I_TYPE_LOAD)
   ||(opcode == `B_TYPE)||(opcode == `I_JALR) ||(opcode == `J_JAL)||(opcode == `U_AUIPC)||(opcode == `U_LUI));
endmodule