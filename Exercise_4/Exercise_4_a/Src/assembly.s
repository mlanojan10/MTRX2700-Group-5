.syntax unified
.thumb

#include "initialise.s"

.global main


.data
@ define variables


.text
@ define code


@ this is the entry function called from the startup file
main:

	BL enable_timer2_clock
	BL enable_peripheral_clocks
	BL initialise_discovery_board

	@ start the counter running
	LDR R0, =TIM2	@ load the base address for the timer
	MOV R1, #0b1 @ store a 1 in bit zero for the CEN flag
	STR R1, [R0, TIM_CR1] @ enable the counter(8MHz)

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer
	@ Then, counter clock frequency CK_CNT is equal to fCK_PSC / (PSC[15:0] + 1), which is 8MHz/(7+1)=1MHz
	MOV R1, #0x07 @ 7
	STR R1, [R0, TIM_PSC] @ set the prescaler register

	@ see the notes in the trigger_prescaler function
	BL trigger_prescaler

	@ Set the delay time with unit microseconds and store in R1
	LDR R1, =2000000

@ Sets LEDs on
LED_on_loop:

	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	@ store the current light pattern (binary mask) in R7
	LDR R7, =0b01010101 @ load a pattern for the set of LEDs (every second one is on)
	STRB R7, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

	BL delay_loop

	B LED_off_loop

@ Sets LEDs off
LED_off_loop:

	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	@ store the current light pattern (binary mask) in R7
	LDR R7, =0b00000000 @ load a pattern for the set of LEDs (every second one is on)
	STRB R7, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

	BL delay_loop

	B LED_on_loop
