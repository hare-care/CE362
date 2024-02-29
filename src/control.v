module control  (
  // Inputs from iFetch
  input [31:0] instruction,
  // Outputs to Reg File
  output reg wEn,   //write back to register file
  // Outputs to Execute/ALU
  output reg [1:0] op_A_sel,                 // select operand A, 00: readdata1, 01: PC, 10: PC+4, 11:0
  output reg op_B_sel,                      // 0:immediate, 1: readdata2
  output reg [5:0] ALU_Control,              // control signal for ALU computation operations
  // Outputs to Memory
  output reg branch_op,                       // if this is a branch instruction
  output reg mem_wEn,
  output reg [1:0]MemSize,
  output reg load_extend_sign,
  // Outputs to Writeback
  output reg wb_sel
);

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

//assign branch_op = opcode==`B_TYPE;
// assign mem_wEn=(opcode==`S_TYPE)?1'b1:1'b0; 
// assign wb_sel=(opcode=`I_TYPE_LOAD)?1'b1:1'b0;	

//signal calculations for most wires 
always @(*) begin 
  case (opcode) 
    `R_TYPE: begin // R-type
    branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b00; // use data from register 
    op_B_sel <= 0; // use data from register
    wb_sel <= 0; //write back ALU result 
    wEn <= 0;
        case (funct3)
              3'b000 : begin
                  if (funct7 == 7'b0000000) begin//add
                          ALU_Control <= `ADD;
                  end else if (funct7==7'b0100000) begin
                          ALU_Control <= `SUB;     //sub  
                  end else if (funct7==7'b0000001) begin
                          ALU_Control <= `MUL;
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
    branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b00;// use data from register
    op_B_sel <= 1; // use immediate data
    wb_sel <= 0;
    wEn <= 0;
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
    branch_op <= 0;
    mem_wEn <= 1;  
    op_A_sel <= 2'b00;
    op_B_sel <= 1;
    wb_sel <= 1;
    wEn <= 0;  //reg file write enable 
    ALU_Control <= `ADD;
    case (funct3)
      3'b000 :begin MemSize<=`SIZE_BYTE; load_extend_sign<= 1'b1; end// lb
      3'b001 : begin MemSize<=`SIZE_HWORD; load_extend_sign<= 1'b1; end // lh 
      3'b010 : begin MemSize<= `SIZE_WORD; load_extend_sign<=1'b1; end//lw 
      3'b100:begin MemSize<=`SIZE_BYTE;load_extend_sign<= 1'b0; end//lbu 
      3'b101:begin MemSize<=`SIZE_HWORD;load_extend_sign<= 1'b0; end//lhu
      default: begin MemSize<=`SIZE_BYTE;load_extend_sign<= 1'b0; end
    endcase
  end 
      `S_TYPE: begin //Store, set mem(rs1+immediate) to 8 LSB of rs2/16 LSB of rs2/ 32bit of rs2
    branch_op <= 0;
    mem_wEn <= 0; // write to memory from rs2
    op_A_sel <= 2'b00; //rs1
    op_B_sel <= 1;  // use immediate
    wb_sel <= 0;
    wEn <= 1;
    ALU_Control <= `STORE;
    case (funct3)
      3'b000: MemSize<=`SIZE_BYTE; //store byte
      3'b001: MemSize<=`SIZE_HWORD; // store half word
      3'b010: MemSize<=`SIZE_WORD; //store word
      default: MemSize<=2'b11;
    endcase
  end
      `B_TYPE : begin //Branch 
      branch_op <= 1;   // branch_flag
      mem_wEn <= 1;
      op_A_sel <= 2'b00;  //rs1
      op_B_sel <= 0;  //rs2
      wb_sel <= 0;
      wEn <= 1;
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
    branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b10; //operanda<= PC + 4, stores to rd
    op_B_sel <= 0;  // doesnt matter
    wb_sel <= 0;
    wEn <= 0;
    ALU_Control <= `JALR; // pass through 
  end
  `J_JAL: begin //Jal, set rd<=pc+4, then jump to address pc+immediate
    branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b10;  // PC + 4 , stores to rd
    op_B_sel <= 0; // doesnt matter
    wb_sel <= 0;
    wEn <= 0;
    ALU_Control <= `JAL; // pass through
  end
  `U_AUIPC: begin //Auipc//
    //branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b01; // PC
    op_B_sel <= 1; //  use immediate
    wb_sel <= 0;
    wEn <= 0;
    ALU_Control <=`ADD;  // PC+ immediate
  end
  `U_LUI : begin //Lui
    branch_op <= 0;
    mem_wEn <= 1;
    op_A_sel <= 2'b11; // hard code to zero  
    op_B_sel <= 1;     //  use immediate
    wb_sel <= 0;
    wEn <= 0;
    ALU_Control <= `ADD; // 0+immediate
  end
  endcase 
end	 
endmodule