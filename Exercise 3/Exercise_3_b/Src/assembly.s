.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ define variables


.align

incoming_buffer: .space 62

user_defined_terminating_character: .asciz "."


.text
@ define text


@ this is the entry function called from the c file
main:

	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart

	@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and terminating character
	LDR R1, =incoming_buffer
	LDR R2, =user_defined_terminating_character

	@ dereference the terminating character, store it in R2
	LDRB R2, [R2]

	@ Keep a pointer that counts how many bytes have been received
	MOV R3, #0x00

@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)
loop_forever:

	LDR R4, =UART @ the base address for the register to set up UART
	LDR R5, [R4, USART_ISR] @ load the status of the UART

	TST R5, 1 << UART_ORE | 1 << UART_FE  @ 'AND' the current status with the bit mask that we are interested in
						   @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set
	BNE clear_error

	TST R5, 1 << UART_RXNE @ 'AND' the current status with the bit mask that we are interested in
							  @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set
	BEQ loop_forever @ loop back if there was no character to read

	LDRB R6, [R4, USART_RDR] @ load the lowest byte (RDR bits [0:7] for an 8 bit read)

	CMP R2, R6 @ seeing if we have reached the termination character
	BNE no_reset

	B forever_loop

@ When not at termination character, traversing to next character in input string
no_reset:

	STRB R6, [R1, R3] @loading the next character in the string
	ADD R3, #1 @incrementing the offset

	@ load the status of the UART
	LDR R5, [R4, USART_RQR]
	ORR R5, 1 << UART_RXFRQ
	STR R5, [R4, USART_RQR]

	BGT loop_forever

@ Clear the overrun/frame error flag in the register USART_ICR (see page 897)
clear_error:

	LDR R5, [R4, USART_ICR] @ loading the UART clear flag section
	ORR R5, 1 << UART_ORECF | 1 << UART_FECF @ clear the flags (by setting flags to 1)
	STR R5, [R4, USART_ICR] @ storing the cleared flags in the clear flag section
	B loop_forever

@ Infinite loop
forever_loop:

	B forever_loop @infinite loop
