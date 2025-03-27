.syntax unified
.thumb

.global main

#include "initialise.s"        @ Include hardware setup functions

.data
.align

incoming_buffer: .space 62     @ Buffer to store incoming UART characters (max 62 bytes)
terminator: .asciz "."         @ User-defined terminating character

.text

@ ------------------------------------------------------------------
@ Main entry point
@ ------------------------------------------------------------------
main:
    BL initialise_power                  @ Initialize power supply
    BL enable_peripheral_clocks         @ Enable GPIO and peripheral clocks
    BL enable_uart                      @ Initialize UART peripheral

    @ Initialize buffer pointer and termination character
    LDR R1, =incoming_buffer            @ R1: Base address of input buffer
    LDR R2, =terminator                 @ R2: Pointer to termination character string
    LDRB R2, [R2]                       @ Load the termination character into R2

    MOV R3, #0x00                       @ R3: Offset counter (tracks number of bytes received)

@ ------------------------------------------------------------------
@ Loop to read UART data continuously
@ ------------------------------------------------------------------
loop_forever:
    LDR R4, =UART                       @ R4: Base address of UART registers
    LDR R5, [R4, USART_ISR]             @ R5: Read UART status flags

    @ Check for Overrun Error (ORE) or Framing Error (FE)
    TST R5, #(1 << UART_ORE) | (1 << UART_FE)
    BNE clear_error                     @ If error flags are set, clear them

    @ Check if RXNE (Receive Not Empty) flag is set
    TST R5, #(1 << UART_RXNE)
    BEQ loop_forever                    @ If no data received, loop again

    @ Read received character from UART
    LDRB R6, [R4, USART_RDR]            @ R6: Received byte (8-bit)

    @ Check if received character equals termination character
    CMP R6, R2
    BEQ end_input                       @ If terminator matched, stop input

@ ------------------------------------------------------------------
@ Store character in buffer and continue receiving
@ ------------------------------------------------------------------
no_reset:
    STRB R6, [R1, R3]                   @ Store character at buffer[R3]
    ADD R3, R3, #1                      @ Increment buffer index

    @ Clear RXNE flag by writing to RQR register
    LDR R5, [R4, USART_RQR]
    ORR R5, #(1 << UART_RXFRQ)         @ Set RXFRQ bit to request RX clear
    STR R5, [R4, USART_RQR]

    B loop_forever                     @ Continue receiving

@ ------------------------------------------------------------------
@ Handle UART errors by clearing ORE and FE flags
@ ------------------------------------------------------------------
clear_error:
    LDR R5, [R4, USART_ICR]             @ Load interrupt clear register
    ORR R5, #(1 << UART_ORECF) | (1 << UART_FECF)  @ Set flags to clear
    STR R5, [R4, USART_ICR]             @ Write back to clear error flags
    B loop_forever

@ ------------------------------------------------------------------
@ Reached the terminating character - stop receiving
@ ------------------------------------------------------------------
end_input:
    B forever_loop                      @ Stay in an infinite loop after input

@ ------------------------------------------------------------------
@ Infinite loop (used after string reception is complete)
@ ------------------------------------------------------------------
forever_loop:
    B forever_loop                      @ Do nothing, halt execution
