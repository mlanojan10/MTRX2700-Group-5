.syntax unified
.thumb

.global main

#include "initialise.s"
#include "cipher.s"
#include "palindromecheck .s"

.data

.align

incoming_buffer: .space 62

user_defined_terminating_character: .asciz "#"


.text
@ define text


@ this is the entry function
main:

	BL initialise_power
	BL enable_peripheral_clocks
	BL initialise_discovery_board
	BL enable_usart1 @The transmission board recieves on USART1
	BL enable_uart4 @The transmission board transmis on UART4.

	@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and terminating character
	LDR R1, =incoming_buffer
	LDR R2, =user_defined_terminating_character

	@ dereference the terminating character, store it in R2
	LDRB R2, [R2]

	@ Keep a count of how many bytes have been received
	MOV R3, #0x00


@ continue reading from USART1 until a terminating character is detected.
loop_forever:

	LDR R4, =USART1 @ the base address for the register to set up USART1

	LDR R5, [R4, USART_ISR] @ load the status of USART1 into R5

	TST R5, 1 << UART_ORE | 1 << UART_FE  @ Checking for error and clearing
	BNE clear_error

	TST R5, 1 << UART_RXNE @Check if there is a character to read.
	BEQ loop_forever @ loop back if there was no character to read

	LDRB R6, [R4, USART_RDR] @ load the lowest byte (RDR bits [0:7] for an 8 bit read)
	CMP R2, R6 @ checks if the termination character has been reached
	BNE no_reset

	BL palindrome_check_main @ check is the string palindrom or not

@ When not at termination character, resets the stats of USART1
no_reset:

	STRB R6, [R1, R3] @Store the byte in R1 (the buffer).
	ADD R3, #1 @Increment the location of where the byte should be stored in R1.

	@ load the status of the UART
	LDR R5, [R4, USART_RQR]
	ORR R5, 1 << UART_RXFRQ
	STR R5, [R4, USART_RQR] @Resets the status of USART1

	BGT loop_forever

@ Clear the overrun/frame error flag in the register USART_ICR (see page 897)
clear_error:

	LDR R5, [R4, USART_ICR] @ loading the UART clear flag section
	ORR R5, 1 << UART_ORECF | 1 << UART_FECF @ clear the flags (by setting flags to 1)
	STR R5, [R4, USART_ICR] @ storing the cleared flags in the clear flag section
	B loop_forever

@ Transmits the characters from serial monitor to the UART
tx_uart:
	LDR R0, =UART4 @ the base address for the register to set up UART4

	LDR R5, [R0, USART_ISR] @ load the status of the UART
	ANDS R5, 1 << UART_TXE  @ 'AND' the current status with the bit mask that we are interested in
						    @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	@ loop back to check status again if the flag indicates there is no byte waiting
	BEQ tx_uart

	@ load the next value in the string into the transmit buffer for UART4
	LDRB R7, [R1], #1 @Accessing current value of the string to transmit
	STRB R7, [R0, USART_TDR] @Shifts to the next byte

	@ check terminating pointer
	CMP R7, R2
	BEQ loop_forever_reset @ end transmit and wating for next trans

	@ loop back to the start
	B tx_uart


@ Resets the buffers to allow for process to start again
loop_forever_reset:
	LDR R1, =incoming_buffer
	MOV R3, #0x00
	B loop_forever
