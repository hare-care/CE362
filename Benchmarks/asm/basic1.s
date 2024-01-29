.org 0x0 			#code start at address 0x0
 	.global _start
_start:

# Immediate arithmetic and logical instructions

addi x1, x0, 19
addi x1, x1, -9 #positive 10
addi x2, x0, -10 # negative 10
slti x3, x0, 10
slti x4, x0, -10
xori x5, x0, 10
ori x6, x0, 10
andi x7, x0, 10
slli x6, x1, 1
slli x7, x2, 1
srli x8, x1, 1
srai x9, x2, 1

# Register-register arithmetic and logical instructions

add x10, x1, x2
sub x11, x1, x2
sub x12, x2, x1
sll x13, x1, x2
sll x14, x2, x1
slt x15, x1, x2
sltu x16, x1, x2
xor x17, x1, x2
srl x18, x1, x2
srl x19, x2, x1
sra x20, x1, x2
sra x21, x2, x1
or x22, x1, x2
and x23, x1, x2

#load and store

sb x1, 8(x0) # Store byte
sh x1, 12(x0) # Store half-word
sw x1, 16(x0) # Store word
sb x2, 20(x0) # Store byte
sh x2, 24(x0) # Store half-word
lb x24, 8(x0) # Load byte
lh x25, 12(x0) # Load half-word
lw x26, 16(x0) # Load word
lbu x27, 20(x0) # Load byte unsigned
lhu x28, 24(x0) # Load half-word unsigned