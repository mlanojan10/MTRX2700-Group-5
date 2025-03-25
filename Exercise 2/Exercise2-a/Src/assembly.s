@ This code has been adapted from the examples provided

.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables

.text

main:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	LDR R4, =0b00010001 @ load a pattern for the set of LEDs
						@ (alternating between the 4th and 8th LEDs (blue LEDs)
						@ being on, and the rest of the LEDs being on)

program_loop:

@ 	Look at the GPIOE offset ODR, display as hex, then as binary. Look at the manual page 239

	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	EOR R4, #0xFF	@ toggle all of the bits in the byte (1->0 0->1)

	BL delay_function @ delay for visibility
	B program_loop @ return to the program_loop label


delay_function:
	LDR R6, =0x9FFFF @ Large delay number to make it easy to see alternating LEDs

	@ we continue to subtract one from R6 while the result is not zero,
	@ then return to where the delay_function was called
not_finished_yet:
	SUBS R6, 0x01
	BNE not_finished_yet

	BX LR @ return from function call
