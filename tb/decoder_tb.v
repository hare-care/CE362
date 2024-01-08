`timescale 1ns / 1ps

module decoder_tb;

    parameter ADDRESS_BITS = 32;

    // Inputs
    reg [ADDRESS_BITS-1:0] PC;
    reg [31:0] instruction;

    // Outputs
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [4:0] read_sel1;
    wire [4:0] read_sel2;
    wire [4:0] rd;
    wire wEn;
    wire branch_op;
    wire [31:0] imm32;
    wire [1:0] op_A_sel;
    wire op_B_sel;
    wire [5:0] ALU_Control;
    wire mem_wEn;
    wire wb_sel;
    wire [1:0] MemSize;
    // Instantiate the decoder module
    decoder #(.ADDRESS_BITS(ADDRESS_BITS)) uut (
        .PC(PC),
        .instruction(instruction),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .read_sel1(read_sel1),
        .read_sel2(read_sel2),
        .rd(rd),
        .wEn(wEn),
        .branch_op(branch_op),
        .imm32(imm32),
        .op_A_sel(op_A_sel),
        .op_B_sel(op_B_sel),
        .ALU_Control(ALU_Control),
        .mem_wEn(mem_wEn),
        .MemSize(MemSize),
        .wb_sel(wb_sel)
    );

    initial begin
        // Initialize Inputs
        PC = 0;
        instruction = 0;
        #100;

        // Test Case 1: R-type instruction (e.g., ADD)
        // ADD rd, rs1, rs2: Adds rs1 and rs2, stores the result in rd
        PC = 32'h00400000;
        instruction = 32'h00B50533; // ADD x10, x10, x11
        #10;
        $display("R-type (ADD) Instruction Decoded: ADD x10, x10, x11 ");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);

        // Test Case 2: I-type instruction (e.g., ADDI)
        // ADDI rd, rs1, immediate: Adds rs1 and immediate value, stores the result in rd
        instruction = 32'h00550613; // ADDI x12, x10, 5
        #10;
        $display("I-type (ADDI) Instruction Decoded:  ADDI x12, x10, 5");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);
        // Test Case 3: S-type instruction (e.g., SW)
        // SW rs2, offset(rs1): Stores the value in rs2 into the memory address given by rs1 + offset
        instruction = 32'h00A52023; // SW x10, 0(x10)
        #10;
        $display("S-type (SW) Instruction Decoded :  SW x10, 0(x10)");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);
        // Test Case 4: B-type instruction (e.g., BEQ)
        // BEQ rs1, rs2, offset: If rs1 equals rs2, branch to the current PC + offset
        instruction = 32'h00B50463; // BEQ x10, x11, 8
        #10;
        $display("B-type (BEQ) Instruction Decoded: BEQ x10, x11, 8");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);
        // Test Case 5: U-type instruction (e.g., LUI)
        // LUI rd, immediate: Loads a 20-bit immediate value into the upper 20 bits of rd
        instruction = 32'hFFFFF37; // LUI x6, 0xFFFFF
        #10;
        $display("U-type (LUI) Instruction Decoded: LUI x6, 0xFFFFF");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);
        // Test Case 6: J-type instruction (e.g., JAL)
        // JAL rd, offset: Jumps to the current PC + offset and stores the return address in rd
        instruction = 32'h00C000EF; // JAL x1, 12
        #10;
        $display("J-type (JAL) Instruction Decoded: JAL x1, 12");
        $display("op_A_sel:%b,\n op_B_sel:%b,\n write enable: %b,\n branch_op: %b,\n ALU_control: %b, \nmemory_write enable: %b,\n writeback select: %b \n" ,op_A_sel,op_B_sel,wEn,branch_op,ALU_Control, mem_wEn,wb_sel);
        $display("All Tests Complete");
    end

endmodule
