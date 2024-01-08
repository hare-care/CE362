 iverilog -o Sim/my_test_result/Topmodule.vvp  ./src/defines.v ./tb/Top_tb.v ./src/Top.v ./src/mem_reg_library.v  ./src/decoder.v ./src/ALU.v 
 vvp Sim/my_test_result/Topmodule.vvp 
 gtkwave waveform.vcd