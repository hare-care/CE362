
//---------------------------------instruction cache----------------------------------
module InstMem(Addr, Size, DataOut, CLK);
   input [31:0] Addr;
   input [1:0] 	Size;
   output [31:0] DataOut;
   reg [31:0] DataOut;   
   input 	CLK;
   reg [7:0] 	Mem[0:1024];
   wire [31:0] 	AddrW;

   // Addresses are word aligned
   assign AddrW = Addr & 32'hfffffffc;

   // Little endian 
   always @ *
     DataOut = {Mem[AddrW+3], Mem[AddrW+2], 
		Mem[AddrW+1], Mem[AddrW]};
      
endmodule // InstMem

//---------------------------------data cache---------------------------------------------
module DataMem(Addr, Size, load_extend_sign, DataIn, DataOut, WEN, CLK);
   input [31:0] Addr;
   input [1:0] 	Size; 
   input load_extend_sign;  
   input [31:0] DataIn;   
   output reg[31:0] DataOut;
   input      WEN, CLK;
   reg [7:0] 	Mem[0:1024];

   wire [31:0] 	AddrH, AddrW;

   assign AddrH = Addr & 32'hfffffffe;
   assign AddrW = Addr & 32'hfffffffc;

//load memory
always @ (*) begin
    if (Size == `SIZE_BYTE && load_extend_sign == 1'b1) begin
        // Sign-extended byte
        DataOut = {{24{Mem[Addr][7]}}, Mem[Addr]};
    end else if (Size == `SIZE_BYTE && load_extend_sign == 1'b0) begin
        // Zero-extended byte
        DataOut = {24'b0, Mem[Addr]};
    end else if (Size == `SIZE_HWORD && load_extend_sign == 1'b1) begin
        // Sign-extended half word (2 bytes)
        DataOut = {{16{Mem[AddrH+1][7]}}, Mem[AddrH+1], Mem[AddrH]};
    end else if (Size == `SIZE_HWORD && load_extend_sign == 1'b0) begin
        // Zero-extended half word (2 bytes)
        DataOut = {16'b0, Mem[AddrH+1], Mem[AddrH]};
    end else if (Size == `SIZE_WORD) begin
        // Word (4 bytes), assuming this is the default case
        DataOut = {Mem[AddrW+3], Mem[AddrW+2], Mem[AddrW+1], Mem[AddrW]};
    end else begin
        DataOut = 32'bx;
    end
end


 //write to memory  
always @ (negedge CLK)
  if (!WEN) begin
    case (Size)
      2'b00: begin // Write byte
        Mem[Addr] <= DataIn[7:0];
      end
      2'b01: begin  // Write halfword
        Mem[AddrH] <= DataIn[7:0];
        Mem[AddrH+1] <= DataIn[15:8];
      end
      2'b10, 2'b11: begin // Write word
        Mem[AddrW] <= DataIn[7:0];
        Mem[AddrW+1] <= DataIn[15:8];
        Mem[AddrW+2] <= DataIn[23:16];
        Mem[AddrW+3] <= DataIn[31:24];
      end
    endcase // case (Size)
  end // if (!WEN)
      
endmodule // InstMem
//---------------------------------------register file----------------------------------
module RegFile(AddrA, DataOutA,
	       AddrB, DataOutB,
	       AddrW, DataInW, WenW, CLK);
   input [4:0] AddrA, AddrB, AddrW;
   output [31:0] DataOutA, DataOutB;
   reg [31:0] DataOutA, DataOutB;   
   input [31:0]  DataInW;
   input 	 WenW, CLK;
   reg [31:0] 	 Mem[0:31];
   
   always @ * begin
      // Remember that x0 == 0
      DataOutA = (AddrA == 0) ? 32'h00000000 : Mem[AddrA];
      DataOutB = (AddrB == 0) ? 32'h00000000 : Mem[AddrB]; 
   end

   always @ (negedge CLK) begin
     if (!WenW) begin
       Mem[AddrW] <= DataInW;
     end
      Mem[0] <= 0; // Enforce the invariant that x0 = 0
   end
   
endmodule // RegFile

// ------------------------------------register----------------------------------
module Reg(Din, Qout, WEN, CLK, RST);
   parameter width = 32;
   input [width-1:0] Din;
   output [width-1:0] Qout;
   input 	      WEN, CLK, RST;

   reg [width-1:0]    Qout;
   
   always @ (negedge CLK or negedge RST)
     if (!RST)
       Qout <= 0;
     else
       if (!WEN)
	 Qout <= Din;
  
endmodule // Reg



