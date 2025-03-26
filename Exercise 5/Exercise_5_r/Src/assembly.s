.syntax unified
.thumb

.global main


#include "lower_conversion.s"
#include "initialise.s"
#include "cipher.s"

.data
@ define variables


.align

incoming_buffer: .space 62

user_defined_terminating_character: .asciz "#"

@ define checking list
checking_list: .string "0abcdefghijklmnopqrstuvwxyz"

.text
@ define text

@ this is the entry function called from the c file
main:
	BL enable_timer2_clock
	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart5
	BL initialise_discovery_board
	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer
	@ Then, counter clock frequency CK_CNT is equal to fCK_PSC / (PSC[15:0] + 1), which is 8MHz/(7+1)=1MHz
	MOV R1, #0x7 @ with delay period 1 microsecond
	STR R1, [R0, TIM_PSC] @ set the prescaler register

	@ see the notes in the trigger_prescaler function
	BL trigger_prescaler

	@ start the counter and auto-reload running
	LDR R0, =TIM2	@ load the base address for the timer
	LDR R1, [R0, #TIM_CR1]  @ load the current value of the control registers
	ORR R1, 1 << 7 | 1 << 0 @ 7st bit is enable Auto-reload preload, 0 is enable Counter
	STR R1, [R0, #TIM_CR1] @ enable the counter and Auto-reload preload

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

	LDR R4, =UART5 @ the base address for the register to set up UART
	LDR R5, [R4, USART_ISR] @ load the status of the UART

	TST R5, 1 << UART_ORE | 1 << UART_FE  @ 'AND' the current status with the bit mask that we are interested in
						   @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	BNE clear_error

	TST R5, 1 << UART_RXNE @ check if there was a character to read
	BEQ loop_forever @ loop back if there was no character to read

	LDRB R6, [R4, USART_RDR] @ load the lowest byte (RDR bits [0:7] for an 8 bit read)

	CMP R2, R6 @ check that the termination character has been reached
	BNE no_reset

	BL cipher_main @decipher the string
	BL lower_conversion_main @convert the result to lowercase

	LDR R4, =USART1 @ the base address for the register to set up UART

	STRB R2, [R1, R3] @Re-add the terminating character (the recieving loop removes it)
	B String_checking @Begin flashing

@ When not at termination character, resetting the status of the UART
no_reset:

	STRB R6, [R1, R3]
	ADD R3, #1

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

@ Gets the character from the alphabet, initialise various paramters
String_checking:

	@Load string to R11
	MOV R11, R1
	@Load checking list to R5 (the STM will flash based on every character which matches the checking list)
	LDR R5, =checking_list
	@initialize the num counter
	LDR R7, =0x00
	@ Initialize the bitmask
	LDR R4, =0b00000000

	B loop_through_the_checking_list

@ Compares the alphabet character to each element in the string, creating a tally of matches
loop_through_the_checking_list:

	LDRB R3, [R5], #1 @load the current character from the checking list
	CMP R3, #0 @check if the null terminating character has been reached
    BEQ finish_scanning @ if R1 equal 0x00, which means the string is end. Turn all LED on
    B set_led @Search the input string for instances of the current character of interest.

@ set the number of LEDs as the number of times the letter is appears
set_led:

	BL loop_through_the_string @Count the number of instances of the character in the string.
	@ initialize R3 to 1，R3 will be used in bitmask_set branch
	MOV R3,#1
	BL bitmask_set
	LDR R0, =GPIOE @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1] @ store this to the second byte of the ODR (bits 8-15)

	BL delay_loop @ wait 500ms (function in initialise)
	@ reset the bitmask
	LDR R4, =0b00000000
	@Load string to R11
	MOV R11, R1
	B loop_through_the_checking_list

@ Loads the character from the string
loop_through_the_string:

	LDRB R8, [R11], #1 @load the current character of the string

    CMP R8, R2 @Check for the null terminating character.
    BEQ Back @If the null terminating character has been reached, the search is complete. Return to the display LED function.

    CMP R8,R3 @Check if the current character matches the character of interest.
    BEQ	num_count @If so, increment the counter.

    B loop_through_the_string

@ this branch is use to turn back LP saving address after meet the requirement
Back:
	BX LR

@ Lights up all LEDs to signifiy string checking has been completed.
finish_scanning:

	LDR R4, =0B11111111
	LDR R0, =GPIOE @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1] @ store this to the second byte of the ODR (bits 8-15)

	B loop_forever_reset

@ sit the LED bitmask according to the number of times the letter is appears
bitmask_set:

	CMP R7, #0 @ Check R3 equal 0 or not
    BEQ Back @ if R3 is 0，bitmask done

    ORR R4, R4, R3 @ Set the lowest bit to 1 if not all LEDs are on
    LSL R3, R3, #1 @ Shift left to turn on the next LED
    SUB R7, #1 @ num counter minus one when led bitmask set 1

    B bitmask_set @ loop again

@count when the letter is appears
num_count:

	ADD R7, #1
	B loop_through_the_string @ go back to loop_through_the_string after count

@ Resets the buffers to allow for process to start again
loop_forever_reset:

	LDR R1, =incoming_buffer
	MOV R3, #0x00

	B loop_forever
