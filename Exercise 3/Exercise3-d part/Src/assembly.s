.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62                      @ Buffer for incoming characters (max 62 bytes)
terminator: .asciz "#"                          @ Terminating character for input

.text

@ ------------------------------------------------------------------
@ Entry point of the program
@ ------------------------------------------------------------------
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL initialise_discovery_board
    BL enable_uart

    LDR R1, =incoming_buffer                   @ R1 = pointer to buffer
    LDR R2, =terminator                        @ R2 = pointer to terminating character
    LDRB R2, [R2]                              @ R2 = terminating character (e.g. '#')

    MOV R3, #0                                 @ R3 = current buffer index (starting at 0)

@ ------------------------------------------------------------------
@ Receive loop: keep reading from UART into buffer
@ ------------------------------------------------------------------
receive_loop:
    LDR R0, =UART                              @ R0 = UART base address
    LDR R5, [R0, USART_ISR]                    @ Read UART status register

    @ Check for Overrun or Framing Error
    TST R5, #(1 << UART_ORE) | (1 << UART_FE)
    BNE clear_error

    @ Check if data received (RXNE flag)
    TST R5, #(1 << UART_RXNE)
    BEQ receive_loop                           @ If no data, continue polling

    LDRB R6, [R0, USART_RDR]                   @ R6 = received character
    STRB R6, [R1, R3]                          @ Store character in buffer
    ADD R3, R3, #1                             @ Increment buffer index

    CMP R6, R2                                 @ Check if received char == terminating char
    BEQ transmit_loop                          @ If terminator received, start echoing

@ Reset RXNE flag
    LDR R5, [R0, USART_RQR]
    ORR R5, R5, #(1 << UART_RXFRQ)
    STR R5, [R0, USART_RQR]

    B receive_loop                             @ Continue receiving

@ ------------------------------------------------------------------
@ Clear UART overrun/frame error flags
@ ------------------------------------------------------------------
clear_error:
    LDR R5, [R0, USART_ICR]                    @ Read interrupt clear register
    ORR R5, R5, #(1 << UART_ORECF) | (1 << UART_FECF)
    STR R5, [R0, USART_ICR]                    @ Clear ORE and FE flags
    B receive_loop

@ ------------------------------------------------------------------
@ Transmit characters from buffer over UART
@ ------------------------------------------------------------------
transmit_loop:
    LDR R0, =UART                              @ UART base address

next_char:
    LDR R5, [R0, USART_ISR]
    TST R5, #(1 << UART_TXE)                   @ Check if transmit register empty
    BEQ next_char                              @ Wait until ready

    LDRB R7, [R1], #1                          @ Load next byte from buffer, increment R1
    CMP R7, R2                                 @ Is it the terminator?
    BEQ reset_and_wait                         @ If yes, reset and go back to receive

    STRB R7, [R0, USART_TDR]                   @ Send character
    B next_char                                @ Send next character

@ ------------------------------------------------------------------
@ Reset buffer pointer and wait for new input
@ ------------------------------------------------------------------
reset_and_wait:
    LDR R1, =incoming_buffer                   @ Reset buffer pointer
    MOV R3, #0                                 @ Reset index counter
    B receive_loop

@ ------------------------------------------------------------------
@ Simple delay function (not used)
@ ------------------------------------------------------------------
delay_loop:
    LDR R9, =0xFFFFF

delay_inner:
    SUBS R9, #1
    BGT delay_inner
    BX LR
