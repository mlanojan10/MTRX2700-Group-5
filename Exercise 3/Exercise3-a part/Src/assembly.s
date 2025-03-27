.syntax unified
.thumb

.global main

#include "initialise.s"      @ Include hardware initialization functions

.data
.align

tx_string: .asciz "abc"      @ String to be sent over UART
terminator: .asciz "."       @ Custom terminating character

.text

@ ------------------------------------------------------------------
@ Entry point of the program, called from the startup file
@ ------------------------------------------------------------------
main:
    BL initialise_power               @ Initialize power system
    BL enable_peripheral_clocks      @ Enable GPIO and peripheral clocks
    BL initialise_discovery_board    @ Configure GPIO pins
    BL enable_uart                   @ Initialize UART peripheral

    B wait_for_button_press          @ Jump to button polling loop

@ ------------------------------------------------------------------
@ Waits until the user presses the button (PA0)
@ ------------------------------------------------------------------
wait_for_button_press:
    LDR R0, =GPIOA                   @ Load base address of GPIOA
    LDR R1, [R0, IDR]                @ Load GPIOA input data register
    TST R1, button                   @ Test if PA0 (bit 0) is HIGH
    BEQ wait_for_button_press       @ Loop until button is pressed

    B transmit_loop                  @ Start UART transmission

@ ------------------------------------------------------------------
@ Transmit the string over UART, character by character
@ ------------------------------------------------------------------
transmit_loop:
    LDR R0, =UART                    @ Load base address of UART
    LDR R1, =tx_string               @ Load pointer to the message string
    LDR R6, =terminator              @ Load pointer to the terminating character

send_next_char:
    @ Wait until UART is ready to transmit (TXE flag is set)
check_uart_ready:
    LDR R2, [R0, USART_ISR]          @ Load UART status register
    ANDS R2, #(1 << UART_TXE)        @ Check if TXE (Transmit Data Register Empty) is set
    BEQ check_uart_ready             @ If not ready, wait

    LDRB R5, [R1], #1                @ Load next character from string (R1 auto-increment)
    CMP R5, #0x00                    @ Check for NULL terminator
    BEQ send_terminator              @ If string ended, send terminator
    STRB R5, [R0, USART_TDR]         @ Write character to UART transmit data register
    B send_next_char                 @ Repeat for next character

@ ------------------------------------------------------------------
@ Sends the terminator character, waits, and goes back to button
@ ------------------------------------------------------------------
send_terminator:
    LDRB R5, [R6]                    @ Load terminating character ('.')
    STRB R5, [R0, USART_TDR]         @ Send terminator to UART
    BL delay_loop                    @ Add delay before accepting another press
    B wait_for_button_press          @ Return to button polling

@ ------------------------------------------------------------------
@ Simple delay loop using register decrement (blocking delay)
@ ------------------------------------------------------------------
delay_loop:
    LDR R9, =0xFFFFF                 @ Load loop count

delay_inner:
    SUBS R9, #1                      @ Subtract 1 and set condition flags
    BGT delay_inner                  @ Loop until R9 reaches 0
    BX LR                            @ Return from subroutine
