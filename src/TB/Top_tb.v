//`timescale 1ns/1ps
module Top_tb;
   reg clk, rst;
   reg exit;
   wire halt;
   

   // pipeline CPU instantiation
   pipeline_top CPU (
    .clk(clk),
    .rstn(rst),
    .halt(halt)
    );

   // Clock Period = 10 time units
   always
     #5 clk = ~clk;

   always @(posedge clk)
     if (halt)
       exit = 1;
   
   initial begin
      $dumpfile("waveform.vcd");
      $dumpvars(0, Top_tb);

      // Clock and reset steup


      // Load program
      #0 $readmemh("./TB/Pipeline1.hex", CPU.IF.IMEM.Mem);  // insrtuction memory input
     //#0 $readmemh("mem_in.hex", CPU.DMEM.Mem);  // data memory input
      //#0 $readmemh("regs_in.hex", CPU.RF.Mem);  //register file input 
      #0 clk = 0; exit =0;
      #10 rst = 0;
      #0 rst = 1;

      // Feel free to modify to inspect whatever you want
      #0 $monitor($time,"IF: PC=%08x IR=%08x halt=%x exit=%x", CPU.PC_IF, CPU.Instruction_IF, halt, exit);
      // #0 $monitor($time,"PC=%08x IR=%08x halt=%x exit=%x", CPU.PC_Dec, CPU.InstWord, halt, exit);
      // Exit???

      wait(exit);
      // Dump registers
      #0 $writememh("./TB/regs_out.hex", CPU.Dec.RF.Mem);

      // Dump memory
      #0 $writememh("./TB/mem_out.hex", CPU.Mem.DMEM.Mem);

      $finish;      
   end
   

endmodule // tb

