//remeber to pass the PC
module decode_stage(
    input [31:0]instruction,
    input wrEn,     // write back enable 
    input [31:0]RWrdata,  // write back data
    output [31:0] Rdata1, // read data 1
    output [31:0] Rdata2,  // read data 2
    output [31:0] imm32,    // genertae immediate value
    output [4:0] Rdst       // pass to next stage for write back
);

wire [4:0] Rsrc1,Rsrc2; 
decoder decoder_unit (
      // input            
      .instruction(instruction),  
      //output 
      // InstWord decode
      .read_sel1(Rsrc1),      
      .read_sel2(Rsrc2),       
      .rd(Rdst), 
      .imm32(imm32)            
   );
RegFile RF(.AddrA(Rsrc1), .DataOutA(Rdata1), 
	      .AddrB(Rsrc2), .DataOutB(Rdata2), 
	      .AddrW(Rdst), .DataInW(RWrdata), .WenW(wrEn), .CLK(clk));

endmodule