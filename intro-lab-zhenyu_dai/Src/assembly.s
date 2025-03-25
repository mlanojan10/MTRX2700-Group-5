.syntax unified
.thumb

.global main

.text

main:
    LDR R0, =0x1234
    LDR R1, =0x0001

forever_loop:
    ADD R0, R1
    B forever_loop

    BX LR
