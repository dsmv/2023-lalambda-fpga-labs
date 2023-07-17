# RISC-V simple  program
#

            .text

            li   a0, 0x55
            addi a0, zero, 0x55
            
            li t6, 2
            li t5, 0x10


start:      addi a0, a0, 1     
            beq zero, zero, start  