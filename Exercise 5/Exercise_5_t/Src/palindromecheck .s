.syntax unified
.thumb

.global main

.data

.text

@ Exercise 1 b)
palindrome_check_main:
    BL string_length             @ Get string length in R4
    SUB R4, R4, #1               @ Adjust index to last character

    BL palindrome_checker        @ Call palindrome checker


@ Function to compute string length
string_length:
    MOV R4, #0                   @ Initialize counter
length_loop:
    LDRB R2, [R1, R4]            @ Load byte from string
    CMP R2, #0                   @ Check if null terminator
    BEQ length_done              @ If null, exit
    ADD R4, R4, #1               @ Increment counter
    B length_loop                @ Repeat
length_done:
    BX LR                        @ Return to caller

@ Palindrome checker (case-insensitive, ignoring special characters)
palindrome_checker:
    MOV R5, #0             		 @ Initialize front index (R5)
    MOV R6, R4             		 @ Initialize back index (R6)

palindrome_loop:
    CMP R5, R6            	     @ Check if front index meets or crosses back index
    BGE is_palindrome     	     @ If crossed, string is palindrome

@ Skip non-alphanumeric characters (Front)
skip_front:
    LDRB R7, [R1, R5]     	     @ Load front character
    BL is_alphanumeric    	     @ Check if it's alphanumeric
    CMP R0, #0             	     @ If not, move to next character
    BEQ increment_front          @ Skip if non-alphanumeric
    B check_back                 @ Otherwise, check back index

increment_front:
    ADD R5, R5, #1               @ Move to next character from the start
    B palindrome_loop            @ Restart loop

@ Skip non-alphanumeric characters (Back)
check_back:
    LDRB R8, [R1, R6]            @ Load back character
    BL is_alphanumeric           @ Check if it's alphanumeric
    CMP R0, #0                   @ If not, move to previous character
    BEQ decrement_back           @ Skip if non-alphanumeric
    B compare_chars              @ Otherwise, compare characters

decrement_back:
    SUB R6, R6, #1               @ Move to previous character from the end
    B palindrome_loop            @ Restart loop

@ Compare characters after filtering
compare_chars:
    BL to_lowercase              @ Convert both characters to lowercase

    CMP R7, R8                   @ Compare characters
    BNE not_a_palindrome         @ If mismatch, not a palindrome

    ADD R5, R5, #1               @ Move to next character from the start
    SUB R6, R6, #1               @ Move to next character from the end
    B palindrome_loop            @ Repeat check

@ Convert R7 and R8 to lowercase if they are uppercase
to_lowercase:
    CMP R7, #0x41                @ Compare front char with 'A'
    BLT skip_lower_R7            @ If less than 'A', skip conversion
    CMP R7, #0x5A                @ Compare front char with 'Z'
    BGT skip_lower_R7            @ If greater than 'Z', skip conversion
    ADD R7, R7, #0x20            @ Convert to lowercase

skip_lower_R7:
    CMP R8, #0x41                @ Compare back char with 'A'
    BLT skip_lower_R8            @ If less than 'A', skip conversion
    CMP R8, #0x5A                @ Compare back char with 'Z'
    BGT skip_lower_R8            @ If greater than 'Z', skip conversion
    ADD R8, R8, #0x20            @ Convert to lowercase

skip_lower_R8:
    BX LR                        @ Return

@ Check if R7 or R8 is alphanumeric (A-Z, a-z, 0-9)
is_alphanumeric:
    CMP R7, #0x30                @ Compare with '0'
    BLT not_alphanumeric         @ If less than '0', not alphanumeric
    CMP R7, #0x39                @ Compare with '9'
    BLE is_valid                 @ If between '0' and '9', alphanumeric

    CMP R7, #0x41                @ Compare with 'A'
    BLT not_alphanumeric         @ If less than 'A', not alphanumeric
    CMP R7, #0x5A                @ Compare with 'Z'
    BLE is_valid                 @ If between 'A' and 'Z', alphanumeric

    CMP R7, #0x61                @ Compare with 'a'
    BLT not_alphanumeric         @ If less than 'a', not alphanumeric
    CMP R7, #0x7A                @ Compare with 'z'
    BLE is_valid                 @ If between 'a' and 'z', alphanumeric

not_alphanumeric:
    MOV R0, #0                   @ Not alphanumeric
    BX LR

is_valid:
    MOV R0, #1                   @ Is alphanumeric
    BX LR

not_a_palindrome:
	LDR R2, =user_defined_terminating_character
	@ dereference the terminating character, store it in R2
	LDRB R2, [R2]
	STRB R2, [R1, R3] @Store the terminating_character in R1 (the buffer).
    B tx_uart

is_palindrome:
    B cipher_main @ cipher the string if palindrome



