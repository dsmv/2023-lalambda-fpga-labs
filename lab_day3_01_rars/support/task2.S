# RISC-V simple  program
#

            .text
            la 	 a3, var0
            li   a0, 0x55
            li	 a1, 0x11
            add  a2, a0, a1
            sw   a2, 0(a3)
            
            li t6, 4

start:      addi a2, a2, 1     
	    addi t6, t6, -1
            bne zero, t6, start  
            
            sw a2, 4(a3)
stop:	    beq zero, zero, stop
            
            .data
var0:	    .word 0            
            .word 0xFFFFFFFF		
