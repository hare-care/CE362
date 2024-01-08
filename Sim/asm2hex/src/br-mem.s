.org 0x0 			#code start at address 0x0
 	.global _start
_start:
	addi x1, x0, 0
	addi x2, x0, 0
	addi x3, x0, 10
	jal x0, condition
body:
	addi x1, x1, 33
	addi x2, x2, 1
condition:
	blt x2, x3, body
