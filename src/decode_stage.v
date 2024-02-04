//remeber to pass the PC
module decode_stage(
    input clk,
    //control signal
    input wrEn,     // write back enable 
    input [1:0] op_A_sel,   // select operand A, 00: readdata1, 01: PC, 10: PC+4, 11:0
    input op_B_sel,         // 1:immediate, 0: readdata2 
    //from Ifectch
    input [31:0]PC,
    //wirte back data
    input [31:0]instruction,
    input [4:0]Rdst_in, //  from write back
    input [31:0]RWrdata,  // write back data
    output reg [31:0]operand_A,  
    output reg [31:0]operand_B,
    output [31:0]Rdata1,
    output [31:0]Rdata2,
    output [31:0] imm32,    // genertae immediate value
    output [4:0] Rdst_out       // pass to next stage for write back
);
// wire [31:0] Rdata1; // read data 1
// wire [31:0] Rdata2;  // read data 2
wire [4:0] Rsrc1,Rsrc2; 
decoder decoder_unit (
      // input            
      .instruction(instruction),  
      //output 
      // InstWord decode
      .read_sel1(Rsrc1),      
      .read_sel2(Rsrc2),       
      .rd(Rdst_out), 
      .imm32(imm32)            
   );
  wire wrEn_RF;
  assign wrEn_RF=!wrEn; // negative trigger
RegFile RF(
        .AddrA(Rsrc1), 
        .DataOutA(Rdata1), 
	      .AddrB(Rsrc2), 
        .DataOutB(Rdata2), 
	      .AddrW(Rdst_in), 
        .DataInW(RWrdata), 
        .WenW(wrEn_RF), 
        .CLK(clk)
        );

// process operand A B
always @(*) begin
  case (op_A_sel)
    2'b00: operand_A=Rdata1;
    2'b01: operand_A=PC;
    2'b10:  operand_A=PC + 32'd4;
    default: operand_A=32'b0;
  endcase
  if (op_B_sel==1'b1) begin
    operand_B=imm32;
  end
  else begin
    operand_B=Rdata2;
  end
end
endmodule