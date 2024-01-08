`timescale 1ns / 1ps
// ALU control signal

// computation
`define ADD 6'b000000
`define SUB 6'b000001
`define SLL 6'b000010
`define SLT 6'b000011
`define SLTU 6'b000100  
`define XOR 6'b000101
`define SRL 6'b000110
`define SRA  6'b000111  
`define OR 6'b001000
`define AND 6'b001001 
// branch
`define BEQ  6'b001010  // Branch if Equal
`define BNE  6'b001011  // Branch if Not Equal
`define BLT  6'b001100  // Branch if Less Than
`define BGE  6'b001101  // Branch if Greater Than or Equal
`define BLTU 6'b001110  // Branch if Less Than, Unsigned
`define BGEU 6'b001111  // Branch if Greater Than or Equal, Unsigned
//jump
`define JALR 6'b111111
`define JAL 6'b011111
`define DEFAULT 6'bx
module ALU_tb;

    // ... [Define ALU_Control values as before] ...

    // Inputs
    reg [5:0]  ALU_Control;
    reg [31:0] operand_A;
    reg [31:0] operand_B;

    // Output
    wire [31:0] ALU_result;

    // Instantiate the ALU module
    ALU uut (
        .ALU_Control(ALU_Control), 
        .operand_A(operand_A), 
        .operand_B(operand_B), 
        .ALU_result(ALU_result)
    );

    // Test Stimuli
    initial begin
        // Test for ADD
        ALU_Control = `ADD;
        operand_A = 32'd15;
        operand_B = 32'd10;
        #10;
        $display("ADD Test: %d + %d = %d", operand_A, operand_B, ALU_result);

        // Test for SUB
        ALU_Control = `SUB;
        operand_A = 32'd20;
        operand_B = 32'd5;
        #10;
        $display("SUB Test: %d - %d = %d", operand_A, operand_B, ALU_result);

        // Test for OR
        ALU_Control = `OR;
        operand_A = 32'hA5A5A5A5;
        operand_B = 32'h5A5A5A5A;
        #10;
        $display("OR Test: %h | %h = %h", operand_A, operand_B, ALU_result);

        // Test for XOR
        ALU_Control = `XOR;
        operand_A = 32'hF0F0F0F0;
        operand_B = 32'h0F0F0F0F;
        #10;
        $display("XOR Test: %h ^ %h = %h", operand_A, operand_B, ALU_result);

        // Test for AND
        ALU_Control = `AND;
        operand_A = 32'h12345678;
        operand_B = 32'h87654321;
        #10;
        $display("AND Test: %h & %h = %h", operand_A, operand_B, ALU_result);

        // Test for SLL
        ALU_Control = `SLL;
        operand_A = 32'd1;
        operand_B = 32'd5;
        #10;
        $display("SLL Test: %d << %d = %d", operand_A, operand_B, ALU_result);

        // Test for SRL
        ALU_Control = `SRL;
        operand_A = 32'h80000000;
        operand_B = 32'd1;
        #10;
        $display("SRL Test: %h >> %d = %h", operand_A, operand_B, ALU_result);

        // Test for SRA
        ALU_Control = `SRA;
        operand_A = 32'h80000000;
        operand_B = 32'd1;
        #10;
        $display("SRA Test: %h >>> %d = %h", operand_A, operand_B, ALU_result);

        // Test for SLT (Signed Less Than)
        ALU_Control = `SLT;
        operand_A = 32'd5;
        operand_B = 32'd10;
        #10;
        $display("SLT Test: %d < %d = %d", operand_A, operand_B, ALU_result);

        // Test for SLTU (Unsigned Less Than)
        ALU_Control = `SLTU;
        operand_A = 32'd5;
        operand_B = 32'd10;
        #10;
        $display("SLTU Test: %d < %d = %d", operand_A, operand_B, ALU_result);

        // Test for BEQ (Branch if Equal)
        ALU_Control = `BEQ;
        operand_A = 32'd15;
        operand_B = 32'd15;
        #10;
        $display("BEQ Test: %d == %d = %d", operand_A, operand_B, ALU_result);

        // Test for BNE (Branch if Not Equal)
        ALU_Control = `BNE;
        operand_A = 32'd20;
        operand_B = 32'd15;
        #10;
        $display("BNE Test: %d != %d = %d", operand_A, operand_B, ALU_result);

           // Test for BGE (Branch if Greater or Equal)
        ALU_Control = `BGE;
        operand_A = 32'd20;
        operand_B = 32'd15;
        #10;
        $display("BGE Test: %d >= %d = %d", operand_A, operand_B, ALU_result);

        // Test for BGEU (Branch if Greater or Equal, Unsigned)
        ALU_Control = `BGEU;
        operand_A = 32'd25;
        operand_B = 32'd20;
        #10;
        $display("BGEU Test: %d >= %d (unsigned) = %d", operand_A, operand_B, ALU_result);

        // Test for JAL (Jump and Link)
        ALU_Control = `JAL;
        operand_A = 32'd100; // Example PC value
        #10;
        $display("JAL Test: Jump to %d (PC + offset)", operand_A);

        // Test for JALR (Jump and Link Register)
        ALU_Control = `JALR;
        operand_A = 32'd200; // Example PC value
        #10;
        $display("JALR Test: Jump to %d (register value)", operand_A);

        // All tests complete
        $display("All ALU Tests Complete");
    end
endmodule

