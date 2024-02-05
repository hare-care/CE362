Rand Benchmark

The benchmark is trying to test the performance drawbacks of mispredicted branchs. The branches taken should be random, and predictors should not have much help. 

This benchmark will generate a random number using a LCG algorithm and
based off that random number it will do a different operation on the hold
variable.

The LCG algorithm uses large prime numbers and a seed to create a psuedo random number.
First a number is added to the seed and then it is multiplied by a different number.
This is then saved as the new seed. 

The starting seed in this benchmark is 42. You can change this value to try different paths.

The starting iteration count is 10, you can change this value as well. 
There is a python script that will follow the same path as the ASM and you can also
see the distribution of random numbers.

regs_out will give the correct values for the registers if using an iteration of 10 and seed of 42. 
