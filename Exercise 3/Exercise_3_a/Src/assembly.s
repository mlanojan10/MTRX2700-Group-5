.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ define variables


.align

tx_string: .asciz "abc"
user_definied_terminating_character: .asciz "." @ Teminating character added to the string


.text
@ define text


@ this is the entry function called from the c file
main:

	BL initialise_power
	BL enable_peripheral_clocks
	BL initialise_discovery_board
	BL enable_uart

	B waiting_for_press @ wating for button pressing

@ Button press waiting loop
waiting_for_press:

	LDR R0, =GPIOA
	LDR R1, [R0, IDR]
	TST R1, button @ PA0 is bit 0, so test for equal to this
	BEQ waiting_for_press @ loop while TST returns 0

	B tx_loop

@ Loads the string into the transmission buffer
tx_loop:

	LDR R0, =UART @ the base address for the register to set up UART

	@ load the memory addresses of the buffer and length information
	LDR R1, =tx_string
	LDR R6, =user_definied_terminating_character

@ Transmitting the characters of the buffer to the console
tx_uart:

	LDR R2, [R0, USART_ISR] @ load the status of the UART
	ANDS R2, 1 << UART_TXE  @ 'AND' the current status with the bit mask that we are interested in
						    @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	@ loop back to check status again if the flag indicates there is no byte waiting
	BEQ tx_uart

	@ load the next value in the string into the transmit buffer for the specified UART
	LDRB R5, [R1], #1
	@ check NULL termination character
	CMP R5, 0x00
	BEQ go_to_waiting_for_press @ end transmit and wating for next trans

	STRB R5, [R0, USART_TDR] @ puts character into console

	@ loop back to the start
	B tx_uart

@ load the next value in the string into the transmit buffer for the specified UART
go_to_waiting_for_press:

	LDRB R5, [R6], #1 @ loading the termination character in a register
	STRB R6, [R0, USART_TDR] @ appending the termination character to the end of the string
	BL delay_loop
	B waiting_for_press

@ Simple delay loop
delay_loop:
	LDR R9, =0xfffff

@ delay loop
delay_inner:
	@ notice the SUB has an S on the end, this means it alters the condition register
	@ and can be used to make a branching decision.
	SUBS R9, #1
	BGT delay_inner
	BX LR @ return from function call
