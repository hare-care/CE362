Welcome to Data attack benchmark

this benchmark runs through all forwarding path including ALU-ALU MEM-ALU WB-ALU(or write back to RF in the first half cycle, read from RF in the second half cycle) 

the aim of this is to test full_forwarding functionality

To use this benchmark, you can compare the data_attack_reg_out file with yours after running simulation with data_attack_mem_in and default regs_in. And also you should compare the data_attack_mem_out with yours, although it should be correct if your reg_out file is the same as data_attack_reg_out file.

