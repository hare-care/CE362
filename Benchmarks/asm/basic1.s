.org 0x0 			#code start at address 0x0
 	.global _start
_start:

# Immediate arithmetic and logical instructions

addi x1, x0, 10
slti x2, x0, 10
xori x3, x0, 10
ori x4, x0, 10
andi x5, x0, 10
slli x6, x1, 1
srli s7, x1, 1
srai x8, x1, 1

# Register-register arithmetic and logical instructions

add x9, x1, x2
sub x10, x1, x2
sll x11, x1, x2
slt x12, x1, x2
sltu x13, x1, x2
xor x14, x1, x2
srl x15, x1, x2
sra x16, x1, x2
or x17, x1, x2
and x18, x1, x2

#load and store

lb x19, 4(x0) # Load byte
lh x20, 4(x0) # Load half-word
lw x21, 4(x0) # Load word
lbu x22, 4(x0) # Load byte unsigned
lhu x23, 4(x0) # Load half-word unsigned
sb x1, 8(x0) # Store byte
sh x1, 12(x0) # Store half-word
sw x1, 16(x0) # Store word