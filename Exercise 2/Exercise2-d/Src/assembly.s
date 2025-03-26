.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
string_buffer: .asciz "replace this text replace this text"
ascii_string: .asciz "Hello\0"

@ Define initial led state
led_state: .byte 0b00000000


.text

main:
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    LDR R1, =ascii_string    @ Load the address of the input string
    MOV R4, #0               @ Initialize vowel count
    MOV R5, #0               @ Initialize consonant count

count_loop:
    LDRB R2, [R1], #1        @ Load a byte from the string into R2 and increment address
    CMP R2, #0               @ Check for null terminator
    BEQ display_result       @ If null terminator, stop

    BL check_vowel           @ Check if it's a vowel
    CMP R3, #1               @ If R3 = 1, it's a vowel
    BEQ increment_vowel

    BL check_consonant       @ Check if it's a consonant
    CMP R3, #1               @ If R3 = 1, it's a consonant
    BEQ increment_consonant

    B count_loop

increment_vowel:
    ADD R4, R4, #1           @ Increment vowel count directly in R4
    B count_loop

increment_consonant:
    ADD R5, R5, #1           @ Increment consonant count directly in R5
    B count_loop

@ -------------------------------------------
@ CHECK IF VOWEL
@ -------------------------------------------
check_vowel:
    MOV R3, #0              @ Assume not a vowel

    CMP R2, #'a'
    BEQ is_vowel
    CMP R2, #'e'
    BEQ is_vowel
    CMP R2, #'i'
    BEQ is_vowel
    CMP R2, #'o'
    BEQ is_vowel
    CMP R2, #'u'
    BEQ is_vowel

    CMP R2, #'A'
    BEQ is_vowel
    CMP R2, #'E'
    BEQ is_vowel
    CMP R2, #'I'
    BEQ is_vowel
    CMP R2, #'O'
    BEQ is_vowel
    CMP R2, #'U'
    BEQ is_vowel

    BX LR

is_vowel:
    MOV R3, #1              @ Set R3 to 1 if it's a vowel
    BX LR

@ -------------------------------------------
@ CHECK IF CONSONANT
@ -------------------------------------------
check_consonant:
    MOV R3, #0              @ Assume not a consonant

    CMP R2, #'a'
    BLT not_consonant
    CMP R2, #'z'
    BGT not_consonant

    CMP R2, #'A'
    BLT not_consonant
    CMP R2, #'Z'
    BGT not_consonant

    @ DO NOT call check_vowel here (it changes registers)
    CMP R2, #'a'
    BEQ not_consonant
    CMP R2, #'e'
    BEQ not_consonant
    CMP R2, #'i'
    BEQ not_consonant
    CMP R2, #'o'
    BEQ not_consonant
    CMP R2, #'u'
    BEQ not_consonant
    CMP R2, #'A'
    BEQ not_consonant
    CMP R2, #'E'
    BEQ not_consonant
    CMP R2, #'I'
    BEQ not_consonant
    CMP R2, #'O'
    BEQ not_consonant
    CMP R2, #'U'
    BEQ not_consonant

    MOV R3, #1              @ If it's not a vowel but a letter, it's a consonant

not_consonant:
    BX LR

@ -------------------------------------------
@ DISPLAY RESULT ON LEDS
@ -------------------------------------------
display_result:
    MOV R2, R4               @ Load vowel count into led_state by default
    LDR R6, =led_state
    STRB R2, [R6]            @ Store vowel count in led_state
    BL display_led           @ Display on LEDs

idle_on:
    LDR R0, =GPIOA           @ Load GPIOA base address
    LDRB R8, [R0, #IDR]      @ Read button input state
    ANDS R8, #0x01           @ Check if button is pressed
    BEQ idle_on              @ Wait until button is pressed

    BL button_down           @ Handle button press

button_down:
    LDR R6, =led_state
    CMP R2, R4               @ Check if currently showing vowel count
    BEQ switch_to_consonant

    @ If already showing consonants, switch to vowels
    MOV R2, R4               @ Load vowel count into led_state
    B store_led_state

switch_to_consonant:
    MOV R2, R5               @ Load consonant count into led_state

store_led_state:
    STRB R2, [R6]            @ Store new state
    LDR R0, =GPIOE
    STRB R2, [R0, #ODR + 1]  @ Update LED output

    BL delay_function
    B idle_on

@ -------------------------------------------
@ DISPLAY LED
@ -------------------------------------------
display_led:
    LDR R6, =led_state
    LDRB R7, [R6]            @ Load LED state value
    LDR R0, =GPIOE
    STRB R7, [R0, #ODR + 1]  @ Write to LED output register
    BX LR


delay_function:
	LDR R9, =0xFFFFF	@ Load delay counter

done:
	SUBS R9, 0x01	@ Decrement delay counter
	BNE done	@ Loop until counter reaches zero

	BX LR	@ Return from function
