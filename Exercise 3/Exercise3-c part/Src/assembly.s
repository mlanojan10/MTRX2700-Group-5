.syntax unified
.thumb

.global main

#include "initialise.s"             @ Include low-level hardware init functions

.data
.align

incoming_buffer: .space 62         @ Reserve 62 bytes for UART input buffer
incoming_counter: .byte 62         @ Store max number of bytes to receive (buffer limit)

.text

@ ------------------------------------------------------------------
@ Main entry point
@ ------------------------------------------------------------------
main:
    BL initialise_power            @ Power system setup
    BL change_clock_speed          @ Change system clock speed (if needed)
    BL enable_peripheral_clocks    @ Enable GPIO and peripheral clocks
    BL enable_uart                 @ UART peripheral setup

    @ Setup pointers
    LDR R6, =incoming_buffer       @ R6: Pointer to start of buffer
    LDR R7, =incoming_counter      @ R7: Pointer to buffer size variable
    LDRB R7, [R7]                  @ R7: Load max buffer size (value)

    MOV R8, #0                     @ R8: Current buffer index (received count)

@ ------------------------------------------------------------------
@ Main loop: receive and store UART data
@ ------------------------------------------------------------------
loop_forever:
    LDR R0, =UART                  @ R0: UART base address
    LDR R1, [R0, USART_ISR]        @ R1: UART status register

    @ Check for Overrun Error or Framing Error
    TST R1, #(1 << UART_ORE) | (1 << UART_FE)
    BNE clear_error                @ If error flags set, clear them

    @ Check if new data received (RXNE = Receive Not Empty)
    TST R1, #(1 << UART_RXNE)
    BEQ loop_forever              @ If no data, poll again

    @ Read the received byte
    LDRB R3, [R0, USART_RDR]       @ R3: Received byte (8-bit)
    STRB R3, [R6, R8]              @ Store at buffer[R8]
    ADD R8, R8, #1                 @ Increment buffer index

    @ If buffer is full, wrap around (circular buffer logic)
    CMP R8, R7
    BGE reset_index               @ If reached max, reset index

@ ------------------------------------------------------------------
@ Clear RXNE flag after successful read
@ ------------------------------------------------------------------
no_reset:
    LDR R1, [R0, USART_RQR]        @ R1: Read UART Request Register
    ORR R1, R1, #(1 << UART_RXFRQ) @ RXFRQ = Receive data flush request
    STR R1, [R0, USART_RQR]        @ Clear RXNE flag

    B loop_forever                @ Continue receiving

@ ------------------------------------------------------------------
@ Reset buffer index to zero when full
@ ------------------------------------------------------------------
reset_index:
    MOV R8, #0                    @ Reset write pointer
    B no_reset                    @ Clear RXNE and continue

@ ------------------------------------------------------------------
@ Handle and clear UART error flags
@ ------------------------------------------------------------------
clear_error:
    LDR R1, [R0, USART_ICR]        @ R1: UART interrupt clear register
    ORR R1, R1, #(1 << UART_ORECF) | (1 << UART_FECF)  @ Clear ORE and FE flags
    STR R1, [R0, USART_ICR]        @ Write back to clear
    B loop_forever

@ ------------------------------------------------------------------
@ Optional software delay loop (not used in main flow)
@ ------------------------------------------------------------------
delay_loop:
    LDR R9, =0xFFFFF              @ Load loop counter

delay_inner:
    SUBS R9, R9, #1               @ Decrement with condition flags
    BGT delay_inner               @ Loop until zero
    BX LR                         @ Return
