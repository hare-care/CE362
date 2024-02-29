`define SIZE_BYTE  2'b00
`define SIZE_HWORD 2'b01
`define SIZE_WORD  2'b10

// opcode
`define R_TYPE       7'b0110011  // compute in ALU
`define I_TYPE        7'b0010011  // Get immediate value,compute in ALU
`define S_TYPE        7'b0100011 // store 
`define I_TYPE_LOAD   7'b0000011
`define B_TYPE        7'b1100011  // Branch
`define I_JALR        7'b1100111
`define J_JAL         7'b1101111
`define U_AUIPC       7'b0010111
`define U_LUI         7'b0110111

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
//store
`define STORE 6'b101010 
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