.org 0x0 			#code start at address 0x0
 	.global _start
_start:
    lui x1, 912092
    addi x1, x1, -273
    addi x2, x0, 0x80
    sw x1, 4(x2)
    lw x3, 4(x2) 
    lb x4, 5(x2) 
    sb x1, -1(x2)
    sb x1, -2(x2)
    sb x1, -3(x2)
    sb x1, -4(x2)
    lw x5, -4(x2)
    sw x5, 0(x2)
    lb x6, 2(x2)
    lbu x7, 3(x2)
