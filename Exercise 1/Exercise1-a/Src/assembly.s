.syntax unified
.thumb

.global main

.data
input_string: .asciz "Hello, World!"  @ String to encode/decode

.text

@ Exercise  1 c)
main:
    LDR R1, =input_string  @ Load address of input string into R1
    MOV R2, #3             @ Shift value (Change for encoding/decoding)

    BL caesar_cipher       @ Call Caesar Cipher function

    B finished             @ Infinite loop (end of program)

@ Function: Apply Caesar Cipher with shift value in R2
caesar_cipher:
    PUSH {LR}              @ Save return address
    MOV R3, R1             @ Copy string address into R3 (iterator)

cipher_loop:
    LDRB R4, [R3]          @ Load current character
    CMP R4, #0             @ Check if null terminator
    BEQ cipher_done        @ If null, exit function

    CMP R4, #'A'           @ Check if char is >= 'A'
    BLT check_lower        @ If less, check lowercase range
    CMP R4, #'Z'           @ Check if char is <= 'Z'
    BLE shift_upper        @ If in uppercase range, shift it

check_lower:
    CMP R4, #'a'           @ Check if char is >= 'a'
    BLT next_char          @ If less, it's not a letter, skip
    CMP R4, #'z'           @ Check if char is <= 'z'
    BLE shift_lower        @ If in lowercase range, shift it
    B next_char            @ Otherwise, move to next character

@ Shift uppercase letters
shift_upper:
    ADD R4, R4, R2         @ Apply shift
    CMP R4, #'Z'           @ Check if it exceeds 'Z'
    BLE store_char         @ If within range, store
    SUB R4, R4, #26        @ Wrap around
    B store_char

@ Shift lowercase letters
shift_lower:
    ADD R4, R4, R2         @ Apply shift
    CMP R4, #'z'           @ Check if it exceeds 'z'
    BLE store_char         @ If within range, store
    SUB R4, R4, #26        @ Wrap around

store_char:
    STRB R4, [R3]          @ Store modified character

next_char:
    ADD R3, R3, #1         @ Move to next character
    B cipher_loop          @ Repeat loop

cipher_done:
    POP {LR}               @ Restore return address
    BX LR                  @ Return

finished:
    B finished             @ Infinite loop (end of program)
