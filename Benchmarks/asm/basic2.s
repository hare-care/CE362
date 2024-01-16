.org 0x0 			#code start at address 0x0
 	.global _start
_start:   
    # Load Upper Immediate
    lui x1, 0x12345  # Load upper 20 bits into t0
    # Add Upper Immediate to PC
    auipc x2, 0x12345 # Load PC + offset into t1
    jal x3, label1    # Jump to label1 and store return address in t2
label1:
    beq x1, x2, label2
    addi x1,x1,4
    jalr x4, x0, 12  
label2:
    bne t0, t1, label3
    addi x1,x1,4
    jalr x5, x0, 24
label3:
    blt x1, x2, label4
    addi x2, x2, 8
    jalr x6, x0, 36
label4:
    bge x1, x2, label5
    addi x1,x1,4
    jalr x7,x0,48
label5:
    bltu x1, x2, label6
    addi x2,x2,4
    jalr x8,x0,60
label6:
    bgeu x1, x2, label7
    addi x1,x1,4
    jalr x9,x0,72
label7:
    addi x0,x0,0

        