@ This code has been adapted from the examples provided and previous code

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


@ CHECK IF VOWEL
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

@ CHECK IF CONSONANT
check_consonant:
    MOV R3, #0              @ Assume not a consonant

    CMP R2, #'b'
    BEQ is_consonant
    CMP R2, #'c'
    BEQ is_consonant
    CMP R2, #'d'
    BEQ is_consonant
    CMP R2, #'f'
    BEQ is_consonant
    CMP R2, #'g'
    BEQ is_consonant
    CMP R2, #'h'
    BEQ is_consonant
    CMP R2, #'j'
    BEQ is_consonant
    CMP R2, #'k'
    BEQ is_consonant
    CMP R2, #'l'
    BEQ is_consonant
    CMP R2, #'m'
    BEQ is_consonant
    CMP R2, #'n'
    BEQ is_consonant
    CMP R2, #'p'
    BEQ is_consonant
    CMP R2, #'q'
    BEQ is_consonant
    CMP R2, #'r'
    BEQ is_consonant
    CMP R2, #'s'
    BEQ is_consonant
    CMP R2, #'t'
    BEQ is_consonant
    CMP R2, #'v'
    BEQ is_consonant
    CMP R2, #'w'
    BEQ is_consonant
    CMP R2, #'x'
    BEQ is_consonant
    CMP R2, #'y'
    BEQ is_consonant
    CMP R2, #'z'
    BEQ is_consonant

    CMP R2, #'B'
    BEQ is_consonant
    CMP R2, #'C'
    BEQ is_consonant
    CMP R2, #'D'
    BEQ is_consonant
    CMP R2, #'F'
    BEQ is_consonant
    CMP R2, #'G'
    BEQ is_consonant
    CMP R2, #'H'
    BEQ is_consonant
    CMP R2, #'J'
    BEQ is_consonant
    CMP R2, #'K'
    BEQ is_consonant
    CMP R2, #'L'
    BEQ is_consonant
    CMP R2, #'M'
    BEQ is_consonant
    CMP R2, #'N'
    BEQ is_consonant
    CMP R2, #'P'
    BEQ is_consonant
    CMP R2, #'Q'
    BEQ is_consonant
    CMP R2, #'R'
    BEQ is_consonant
    CMP R2, #'S'
    BEQ is_consonant
    CMP R2, #'T'
    BEQ is_consonant
    CMP R2, #'V'
    BEQ is_consonant
    CMP R2, #'W'
    BEQ is_consonant
    CMP R2, #'X'
    BEQ is_consonant
    CMP R2, #'Y'
    BEQ is_consonant
    CMP R2, #'Z'
    BEQ is_consonant

    BX LR                   @ Not a consonant, return

is_consonant:
    MOV R3, #1              @ Set R3 to 1 if it's a consonant
    BX LR


@ DISPLAY RESULT ON LEDS
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


@ DISPLAY LED
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
