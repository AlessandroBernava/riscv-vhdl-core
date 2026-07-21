.section .text.init
.global _start

_start:
    la sp, __StackTop
    la t0, __bss_start__
    la t1, __bss_end__

loop1: bge t0, t1, done
    sw x0, 0(t0)
    addi t0, t0, 4
    j loop1
done:

    call main

halt:                   /* loop infinito */
    j halt
