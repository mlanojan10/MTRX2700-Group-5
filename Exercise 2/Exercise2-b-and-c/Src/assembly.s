@ This code has been adapted from the examples provided

.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define initial led state
led_state: .byte 0b00000000

.text

@ Entry function
main:
	BL enable_peripheral_clocks	@ Enable clocks for peripherals
	BL initialise_discovery_board	@ Initialize Discovery board I/O
	BL turn_on_leds	@ Turn LEDs on one-by-one


turn_on_leds:
	LDR R4, =led_state	@ Load LED state address
	LDRB R5, [R4]	@ Load LED state value
	LDR R0, =GPIOE	@ Load GPIOE base address
	STRB R5, [R0, #ODR + 1]	@ Update LED output


idle_on:
	LDR R0, =GPIOA	@ Load GPIOA base address
	LDRB R1, [R0, #IDR]	@ Read button input state
	ANDS R1, #0X01	@ Check if button is pressed
	BEQ idle_on	@ Wait until button is pressed

	BL button_down	@ Handle button press

idle_off:
	LDR R0, =GPIOA	@ Load GPIOA base address
	LDRB R1, [R0, #IDR]	@ Read button input state
	ANDS R1, #0X01	@ Check if button is pressed
	BEQ idle_off	@ Wait until button is pressed

	BL turn_off_loop	@ Handle button press

button_down:
	LDR R4, =led_state	@ Load LED state address
	LDRB R5, [R4]	@ Load LED state value

	CMP R5, #0XFF	@ Check if all LEDs are on
	BEQ turn_off_leds	@ If so, start turning them off

	LSL R5, R5, #1 @ Change number of LEDs on
    	ORR R5, R5, #0x01

	STRB R5, [R4]	@ Store updated LED state
	LDR R0, =GPIOE	@ Load GPIOE base address
	STRB R5, [R0, #ODR + 1]	@ Update LED output

	BL delay_function	@ Delay for visibility
	B idle_on	@ Wait for next button press


turn_off_leds:
	LDR R4, =led_state	@ Load LED state address
	LDRB R5, [R4]	@ Load LED state value

turn_off_loop:
	CMP R5, #0x00	@ Check if all LEDs are off
    BEQ idle_on	@ If so, return to waiting state

	LSR R5, R5, #1	@ Shift right to turn off one LED
	STRB R5, [R4]	@ Store updated LED state
	LDR R0, =GPIOE	@ Load GPIOE base address
	STRB R5, [R0, #ODR + 1]	@ Update LED output

	BL delay_function	@ Delay for visibility
	BL idle_off
	B turn_off_loop	@ Continue turning off LEDs


delay_function:
	LDR R6, =0xFFFFF	@ Load delay counter

done:
	SUBS R6, 0x01	@ Decrement delay counter
	BNE done	@ Loop until counter reaches zero

	BX LR	@ Return from function
