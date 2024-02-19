.org 0x0 			#code start at address 0x0
 	.global _start
_start:
	addi x1, x0, 123
	addi x2, x0, -100
	slli x3, x1, 3
	xori x4, x1, 0
	add x5, x1, x2
	srai x7, x4, 5
	and x8, x4, x3
	or  x9, x3, x1
	slt x10, x4, x3
	sltu x11, x4, x3
	or x12, x5, x8
	sll x13, x3, x7
	srli x14, x4, 2
	srai x15, x4, 3