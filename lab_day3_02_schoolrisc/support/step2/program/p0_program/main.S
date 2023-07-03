# RISC-V simple sprite move program
#
# Dmitry Smekhov, 2023
#
 
            .text

            li a0, 0
            # li t6, 2
            # li t5, 0

            # li t6, 1
            # li t5, 0 

start:      #mv t5, a0
            addi a0, a0, 1
            mv t5, a0


            addi a0, a0, 0  # задержка до обнуления tick_counter
            addi a0, a0, 0 
            addi a0, a0, 0
            addi a0, a0, 0

wait_cycle: beq t5, zero, wait_cycle                        


            beq zero, zero, start


 
