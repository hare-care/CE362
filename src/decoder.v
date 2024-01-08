// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Decode Module

module decoder #(
  parameter ADDRESS_BITS = 32
) (
  // Inputs from Fetch
  input [ADDRESS_BITS-1:0] PC,
  input [31:0] instruction,
  // instruction decode
  output [6:0] opcode,
  output [6:0] funct7,
  output [2:0] funct3,
  // Outputs to Reg File
  output [4:0] read_sel1,                   // source register address 1
  output [4:0] read_sel2,                   // source register address 2
  output [4:0] rd,                          // destination regiter address 
  output reg wEn,
  // Outputs to Execute/ALU
  output branch_op,                       // Tells ALU if this is a branch instruction
  output [31:0] imm32,                      // immediate value for computation
  output reg [1:0] op_A_sel,                 // select operand A, 00: readdata1, 01: PC, 10: PC+4, 11:0
  output reg op_B_sel,                      // 0:immediate, 1: readdata2
  output reg [5:0] ALU_Control,              // control signal for ALU computation operations
  // Outputs to Memory
  output reg mem_wEn,
  output reg [1:0]MemSize,
  output reg load_extend_sign,
  // Outputs to Writeback
  output reg wb_sel

);
/* Instruction decoding */
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
// Read registers
assign read_sel2  = instruction[24:20];
assign read_sel1  = instruction[19:15];
/* Write register */
assign rd = instruction[11:7];

// These are internal wires that I used. You can use them but you do not have to.
// Wires you do not use can be deleted.
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

//wire [1:0] extend_sel;
wire [ADDRESS_BITS-1:0] branch_target;
wire [ADDRESS_BITS-1:0] JAL_target;
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
assign uj_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
assign uj_imm_32 = { {11{uj_imm[20]}}, uj_imm};
//shamt for slli,srli,srai
assign shamt = instruction[24:20];
assign shamt_32 = {27'b000000000000000000000000000, shamt};


// get target immediate value
assign imm32 =  (opcode == `I_TYPE && (funct3 == 3'b001||funct3 == 3'b101))? shamt_32:  //SLLI,srli,srai
					 (opcode == `I_TYPE)? i_imm_32:  //I-type
					 (opcode == `I_TYPE_LOAD)? i_imm_32:  //I-type,Load
					 (opcode == `S_TYPE)? s_imm_32:  //S-type
					 (opcode == `B_TYPE)? sb_imm_32: //Branches
					 (opcode == `J_JAL)? uj_imm_32: //JAL 
					 (opcode == `I_JALR)? i_imm_32:  //JALR
					 (opcode == `U_AUIPC)? u_imm_32:  //Auipc
					 (opcode == `U_LUI)? u_imm_32:  //Lui
					 0;  //default 

	assign branch_op= opcode==`B_TYPE;
    // assign mem_wEn=(opcode==`S_TYPE)?1'b1:1'b0; 
    // assign wb_sel=(opcode=`I_TYPE_LOAD)?1'b1:1'b0;		 
//signal calculations for most wires 
  always @(*) begin 
    case (opcode) 
	   `R_TYPE: begin // R-type
		//  branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b00; // use data from register 
		  op_B_sel <= 0; // use data from register
		  wb_sel <= 0; //write back ALU result 
		  wEn <= 1;
          case (funct3)
                3'b000 : begin
                    if (funct7 == 7'b0000000) begin//add
                            ALU_Control <= `ADD;
                    end else if (funct7==7'b0100000) begin
                            ALU_Control <= `SUB;     //sub  
                    end
                end
                3'b001: ALU_Control<=`SLL; //sll
                3'b010: ALU_Control<=`SLT;//slt
                3'b011: ALU_Control<=`SLTU;//sltu
                3'b100: ALU_Control<=`XOR;//xor
                3'b101: begin
                    if(funct7==7'b0000000)begin
                        ALU_Control<=`SRL; //srl
                    end
                    else if (funct7==7'b0100000) begin
                        ALU_Control<=`SRA; // sra, signed shift
                    end
                end
                3'b110:ALU_Control<=`OR;//or
                3'b111:ALU_Control<=`AND;//and
                default: ALU_Control<=`DEFAULT;
          endcase
		 
      end 		  
		`I_TYPE: begin //I-type
		//  branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b00;// use data from register
		  op_B_sel <= 1; // use immediate data
		  wb_sel <= 0;
		  wEn <= 1;
          case (funct3)
            3'b000: ALU_Control <= `ADD;
            3'b001:ALU_Control <=`SLL;
            3'b010: ALU_Control<=`SLT;
            3'b011: ALU_Control<=`SLTU;
            3'b100: ALU_Control<=`XOR;
            3'b101: begin
                if (funct7 == 7'b0000000) begin 
                ALU_Control <= `SRL; //srli
                end else if(funct7==7'b0100000) begin 
                ALU_Control <= `SRA; //srai
                end
            end
            3'b110: ALU_Control <= `OR;
            3'b111: ALU_Control <= `AND;
            default: ALU_Control<=`DEFAULT;
          endcase
		end
        `I_TYPE_LOAD: begin //Load
		//  branch_op <= 0;
		  mem_wEn <= 0;  
		  op_A_sel <= 2'b00;
		  op_B_sel <= 1;
		  wb_sel <= 1;
		  wEn <= 1;  //reg file write enable 
		  ALU_Control <= `ADD;
      case (funct3)
       3'b000 :begin MemSize<=`SIZE_BYTE; load_extend_sign<= 1'b1; end//lb
       3'b001 : begin MemSize<=`SIZE_HWORD; load_extend_sign<= 1'b1; end // lh 
       3'b010 : MemSize<= `SIZE_WORD; //lw
       3'b100:begin MemSize<=`SIZE_BYTE;load_extend_sign<= 1'b0; end//lbu 
       3'b101:begin MemSize<=`SIZE_HWORD;load_extend_sign<= 1'b0; end//lhu
        default: begin MemSize<=`SIZE_BYTE;load_extend_sign<= 1'b0; end
      endcase
		end 
        `S_TYPE: begin //Store, set mem(rs1+immediate) to 8 LSB of rs2/16 LSB of rs2/ 32bit of rs2
		 // branch_op <= 0;
		  mem_wEn <= 1; // write to memory from rs2
		  op_A_sel <= 2'b00; //rs1
		  op_B_sel <= 1;  // use immediate
		  wb_sel <= 0;
		  wEn <= 0;
		  ALU_Control <= `ADD;
      case (funct3)
        3'b000: MemSize<=`SIZE_BYTE; //store byte
        3'b001: MemSize<=`SIZE_HWORD; // store half word
        3'b010: MemSize<=`SIZE_WORD; //store word
        default: MemSize<=2'b11;
      endcase
		end
        `B_TYPE : begin //Branch 
      //  branch_op <= 1;   // branch_flag
        mem_wEn <= 0;
        op_A_sel <= 2'b00;  //rs1
        op_B_sel <= 0;  //rs2
        wb_sel <= 0;
        wEn <= 0;
        case (funct3)
           3'b000 : ALU_Control<=`BEQ;
           3'b001: ALU_Control<=`BNE;
           3'b100: ALU_Control<=`BLT;
           3'b101 : ALU_Control<=`BGE;
           3'b110 : ALU_Control<=`BLTU;
           3'b111: ALU_Control<=`BGEU;
          //  default: `DEFAULT;
        endcase
		end
		`I_JALR: begin //Jalr, set rd<=pc+4 and jump tp address rs1+immediate
		 // branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b10; //operanda<= PC + 4, stores to rd
		  op_B_sel <= 0;  // doesnt matter
		  wb_sel <= 0;
		  wEn <= 1;
		  ALU_Control <= `JALR; // pass through 
		end
		`J_JAL: begin //Jal, set rd<=pc+4, then jump to address pc+immediate
		 // branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b10;  // PC + 4 , stores to rd
		  op_B_sel <= 0; // doesnt matter
		  wb_sel <= 0;
		  wEn <= 1;
		  ALU_Control <= `JAL; // pass through
		end
		`U_AUIPC: begin //Auipc//
		  //branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b01; // PC
		  op_B_sel <= 1; //  use immediate
		  wb_sel <= 0;
		  wEn <= 1;
		  ALU_Control <=`ADD;  // PC+ immediate
		end
		`U_LUI : begin //Lui
		 // branch_op <= 0;
		  mem_wEn <= 0;
		  op_A_sel <= 2'b11; // hard code to zero  
		  op_B_sel <= 1;     //  use immediate
		  wb_sel <= 0;
		  wEn <= 1;
		  ALU_Control <= `ADD; // 0+immediate
		end
    endcase 
  end	 
endmodule