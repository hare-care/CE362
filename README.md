# CE362 Computer Architecture Project


## Testdata construction
* The professor provides some test data examples in the folder: testdata_samples
* The testbench is in :  tb/Top_tb.v

### Refer to the data format provided by the professor, we have the following test data construction flow:

To test the function of the CPU, you need to construct the assembly language instructions that you want to test, and use **riscv-gnu-toolchain** to interpret it to the hexadecimal file that can be read by Top_tb.v

In this project, you can directly write the **assembly language**  / or write **C language** and convert it to assembly.
* The suggested format of assembly or C files is already in the **Sim/asm2hex(c2asm)/src** folder for reference.

To generate the assembly language instructions from C file, you can
```
cd Sim/c2asm/src
# create your .c file here
cd ..
make NAME= "the name of your C file"
```
The output .s file is in ./build/

To generate the hexadecimal/binary file from assembly files, you can
```
cd Sim/asm2hex/src
# put your .s file here
cd ..
make NAME="the name of your assembly file"
```
The output .hex and .bin file is in ./build/

(we use **.hex files** here)

