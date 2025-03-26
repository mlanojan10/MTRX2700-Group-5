.syntax unified
.thumb

.global main

.data

.text

cipher_main:

    MOV R0, #3             @ Shift value (Change for encoding/decoding)

    BL caesar_cipher       @ Call Caesar Cipher function

	LDR R2, =user_defined_terminating_character
	@ dereference the terminating character, store it in R2
	LDRB R2, [R2]
	STRB R2, [R1, R3] @Store the terminating_character in R1 (the buffer).
	SUB R1, R1, R3 @ reset address of R1
   	B tx_uart @ Begin transmission

@ Function: Apply Caesar Cipher with shift value in R2
caesar_cipher:
    PUSH {LR}              @ Save return address

cipher_loop:
    LDRB R5, [R1]          @ Load current character
    CMP R5, #0             @ Check if null terminator
    BEQ cipher_done        @ If null, exit function

    CMP R5, #'A'           @ Check if char is >= 'A'
    BLT check_lower        @ If less, check lowercase range
    CMP R5, #'Z'           @ Check if char is <= 'Z'
    BLE shift_upper        @ If in uppercase range, shift it

check_lower:
    CMP R5, #'a'           @ Check if char is >= 'a'
    BLT next_char          @ If less, it's not a letter, skip
    CMP R5, #'z'           @ Check if char is <= 'z'
    BLE shift_lower        @ If in lowercase range, shift it
    B next_char            @ Otherwise, move to next character

@ Shift uppercase letters
shift_upper:
    ADD R5, R5, R0         @ Apply shift
    CMP R5, #'Z'           @ Check if it exceeds 'Z'
    BLE store_char         @ If within range, store
    SUB R5, R5, #26        @ Wrap around
    B store_char

@ Shift lowercase letters
shift_lower:
    ADD R5, R5, R0         @ Apply shift
    CMP R5, #'z'           @ Check if it exceeds 'z'
    BLE store_char         @ If within range, store
    SUB R5, R5, #26        @ Wrap around

store_char:
    STRB R5, [R1]          @ Store modified character

next_char:
    ADD R1, R1, #1         @ Move to next character
    B cipher_loop          @ Repeat loop

cipher_done:
    POP {LR}               @ Restore return address
    BX LR                  @ Return



