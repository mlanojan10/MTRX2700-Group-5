.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62                      @ Buffer to store received characters
user_defined_terminating_character: .asciz "#"  @ Terminator character

.text

@ ------------------------------------------------------------------
@ Main entry point
@ ------------------------------------------------------------------
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_uart5                   @ UART5 will be used to receive data
    BL enable_usart1                  @ USART1 will be used to transmit data

    LDR R1, =incoming_buffer          @ R1 = pointer to input buffer
    LDR R2, =user_defined_terminating_character
    LDRB R2, [R2]                     @ R2 = termination character (e.g., '#')
    MOV R3, #0                        @ R3 = buffer index / byte counter

@ ------------------------------------------------------------------
@ UART5 receive loop (input from serial monitor or device)
@ ------------------------------------------------------------------
loop_forever:
    LDR R4, =UART5                    @ R4 = base address of UART5 (receiver)
    LDR R0, =USART1                   @ R0 = base address of USART1 (transmitter)

    LDR R5, [R4, USART_ISR]           @ Read UART5 status register

    @ Check for overrun or framing error
    TST R5, #(1 << UART_ORE) | (1 << UART_FE)
    BNE clear_error                   @ If error flag set, clear and restart

    @ Check if data received (RXNE = 1)
    TST R5, #(1 << UART_RXNE)
    BEQ loop_forever                  @ No data yet → continue polling

    LDRB R6, [R4, USART_RDR]          @ R6 = received character

    CMP R6, R2                        @ Is it the terminating character?
    BEQ store_terminator_and_send     @ If so, end receive and start transmission

@ ------------------------------------------------------------------
@ Store received character in buffer and continue receiving
@ ------------------------------------------------------------------
no_reset:
    STRB R6, [R1, R3]                 @ Store character into buffer
    ADD R3, R3, #1                    @ Increment index

    @ Clear RXNE flag via RQR register
    LDR R5, [R4, USART_RQR]
    ORR R5, R5, #(1 << UART_RXFRQ)
    STR R5, [R4, USART_RQR]

    B loop_forever

@ ------------------------------------------------------------------
@ If termination character received, store and start transmission
@ ------------------------------------------------------------------
store_terminator_and_send:
    STRB R2, [R1, R3]                 @ Store terminator in buffer
    B tx_uart

@ ------------------------------------------------------------------
@ UART1 transmit loop (echo received data to terminal)
@ ------------------------------------------------------------------
tx_uart:
    LDR R7, [R0, USART_ISR]
    TST R7, #(1 << UART_TXE)          @ Check if transmit buffer is empty
    BEQ tx_uart                       @ Wait if not ready

    LDRB R8, [R1], #1                 @ Load next character from buffer (R1 auto-increment)
    CMP R8, R2                        @ Is it the terminator?
    BEQ loop_forever_reset            @ If so, reset and wait for next input

    STRB R8, [R0, USART_TDR]          @ Send byte via USART1
    B tx_uart                         @ Send next byte

@ ------------------------------------------------------------------
@ Reset buffer and index to start next reception
@ ------------------------------------------------------------------
loop_forever_reset:
    LDR R1, =incoming_buffer          @ Reset buffer pointer
    MOV R3, #0                        @ Reset index
    B loop_forever                    @ Go back to receive mode

@ ------------------------------------------------------------------
@ Clear UART error flags (overrun / framing)
@ ------------------------------------------------------------------
clear_error:
    LDR R5, [R4, USART_ICR]           @ Load interrupt clear register
    ORR R5, R5, #(1 << UART_ORECF) | (1 << UART_FECF)
    STR R5, [R4, USART_ICR]           @ Clear error flags
    B loop_forever
