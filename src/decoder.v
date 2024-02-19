module decoder (
  // Inputs from Fetch
  input [31:0] instruction,
  // Outputs to Reg File
  output [4:0] read_sel1,                   // source register address 1
  output [4:0] read_sel2,                   // source register address 2, and pass to next stage
  output [4:0] rd,                          // pass to next stage  
  output reg[31:0] imm32                      // extract and pass to execution
);
wire [6:0] opcode;
//wire [6:0] funct7;
wire [2:0] funct3;
// immediate wire
wire[6:0]  s_imm_msb;
wire[4:0]  s_imm_lsb;
wire[19:0] u_imm;
wire[11:0] i_imm_orig;
wire[20:0] uj_imm;
wire[11:0] s_imm_orig;
wire[12:0] sb_imm_orig;
wire[4:0] shamt;

wire[31:0] sb_imm_32;
wire[31:0] u_imm_32;
wire[31:0] i_imm_32;
wire[31:0] s_imm_32;
wire[31:0] uj_imm_32; // sign extend and and assign the right one 
wire[31:0] shamt_32;
/* Instruction decoding */
assign opcode = instruction[6:0];
//assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
// Read register file
assign read_sel2  = instruction[24:20];
assign read_sel1  = instruction[19:15];
/* Write register file*/
assign rd = instruction[11:7]; 


//immediates calculations 
// S-Type, immediate extraction
//sb,sh,sw
assign s_imm_msb = instruction[31:25];
assign s_imm_lsb = instruction[11:7];
assign s_imm_orig = {s_imm_msb, s_imm_lsb};
assign s_imm_32 = { {20{s_imm_orig[11]}},s_imm_orig}; // signed extend
// I type immediate extraction
//jalr,lb,lh,le,lbu,lhu 
//addi,slti,sltiu,xori,ori,andi,slli,srli,srai
assign i_imm_orig = instruction[31:20];
assign i_imm_32 = { {20{i_imm_orig[11]}}, i_imm_orig}; // signed extend

//u type
//lui,auipc
assign u_imm = instruction[31:12];
assign u_imm_32 = {u_imm, 12'b000000000000}; 
//B-type
// beq,bne,blt,bge,bltu,bgeu
assign sb_imm_orig = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign sb_imm_32 = { {19{sb_imm_orig[12]}}, sb_imm_orig}; 
 // UJ-type 
// assign uj_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
// assign uj_imm_32 = { {11{uj_imm[20]}}, uj_imm};
//shamt for slli,srli,srai
assign shamt = instruction[24:20];
assign shamt_32 = {27'b000000000000000000000000000, shamt};
always @(*) begin
    case (opcode)
        `I_TYPE: begin
            if (funct3 == 3'b001 || funct3 == 3'b101) begin
                imm32 = shamt_32; // SLLI, srli, srai
            end else begin
                imm32 = i_imm_32; // I-type
            end
        end
        `I_TYPE_LOAD: imm32 = i_imm_32; // I-type, Load
        `S_TYPE: imm32 = s_imm_32; // S-type
        `B_TYPE: imm32 = sb_imm_32; // Branches
        // `J_JAL: imm32 = uj_imm_32; // JAL
        // `I_JALR: imm32 = i_imm_32; // JALR
        `U_AUIPC: imm32 = u_imm_32; // Auipc
        `U_LUI: imm32 = u_imm_32; // Lui
        default: imm32 = 0; // default
    endcase
end

endmodule