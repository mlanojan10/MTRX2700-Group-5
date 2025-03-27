.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62                        @ Buffer to store received characters
user_defined_terminating_character: .asciz "#"    @ Terminating character

.text

@ --------------------------------------------------
@ Main entry point
@ --------------------------------------------------
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL initialise_discovery_board
    BL enable_usart1              @ USART1 for receiving input
    BL enable_uart4               @ UART4 for sending output

    LDR R1, =incoming_buffer      @ R1 = pointer to buffer
    LDR R2, =user_defined_terminating_character
    LDRB R2, [R2]                 @ R2 = terminating character (e.g., '#')
    MOV R3, #0                    @ R3 = buffer index (starting from 0)

@ --------------------------------------------------
@ UART receive loop (USART1)
@ --------------------------------------------------
loop_forever:
    LDR R4, =USART1               @ R4 = USART1 (input)
    LDR R0, =UART4                @ R0 = UART4 (output)
    LDR R5, [R4, USART_ISR]       @ R5 = status register

    @ Check for overrun or framing error
    TST R5, #(1 << UART_ORE) | (1 << UART_FE)
    BNE clear_error

    @ Check if data received (RXNE = 1)
    TST R5, #(1 << UART_RXNE)
    BEQ loop_forever              @ If no data, continue polling

    @ Read received byte
    LDRB R6, [R4, USART_RDR]      @ R6 = received character

    @ Store character in buffer
    STRB R6, [R1, R3]
    ADD R3, R3, #1                @ Increment buffer index

    @ Check if termination character received
    CMP R6, R2
    BEQ tx_uart                   @ If so, begin transmit phase

@ --------------------------------------------------
@ Continue receiving if not at terminator
@ --------------------------------------------------
no_reset:
    LDR R5, [R4, USART_RQR]
    ORR R5, R5, #(1 << UART_RXFRQ)   @ Clear RXNE flag
    STR R5, [R4, USART_RQR]
    B loop_forever

@ --------------------------------------------------
@ Clear UART error flags (ORE, FE)
@ --------------------------------------------------
clear_error:
    LDR R5, [R4, USART_ICR]
    ORR R5, R5, #(1 << UART_ORECF) | (1 << UART_FECF)
    STR R5, [R4, USART_ICR]
    B loop_forever

@ --------------------------------------------------
@ Transmit all received characters via UART4
@ --------------------------------------------------
tx_uart:
    LDR R5, [R0, USART_ISR]
    TST R5, #(1 << UART_TXE)         @ Wait until TX buffer is empty
    BEQ tx_uart

    LDRB R7, [R1], #1                @ Load character from buffer (R1 auto-increment)
    STRB R7, [R0, USART_TDR]         @ Send character to UART4

    CMP R7, R2                       @ Is this the terminator?
    BEQ reset_and_restart            @ If so, reset everything

    B tx_uart                        @ Continue sending next byte

@ --------------------------------------------------
@ Reset buffer for next reception
@ --------------------------------------------------
reset_and_restart:
    LDR R1, =incoming_buffer         @ Reset buffer pointer
    MOV R3, #0                       @ Reset buffer index
    B loop_forever                   @ Go back to receive loop

@ --------------------------------------------------
@ Optional delay function (not currently used)
@ --------------------------------------------------
delay_loop:
    LDR R9, =0xFFFFF

delay_inner:
    SUBS R9, #1
    BGT delay_inner
    BX LR
