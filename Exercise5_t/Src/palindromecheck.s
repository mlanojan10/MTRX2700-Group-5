.syntax unified
.thumb

.global main

.data
input_string: .asciz "RAC$#$CaR" @ Change this string to test different cases

.text

@ Exercise 1 b)
main:
    LDR R1, =input_string        @ Load address of input string
    BL string_length             @ Get string length in R3
    SUB R3, R3, #1               @ Adjust index to last character

    BL palindrome_checker        @ Call palindrome checker

    B finished_string            @ Infinite loop if check is done

@ Function to compute string length
string_length:
    MOV R3, #0                   @ Initialize counter
length_loop:
    LDRB R2, [R1, R3]            @ Load byte from string
    CMP R2, #0                   @ Check if null terminator
    BEQ length_done              @ If null, exit
    ADD R3, R3, #1               @ Increment counter
    B length_loop                @ Repeat
length_done:
    BX LR                        @ Return to caller

@ Palindrome checker (case-insensitive, ignoring special characters)
palindrome_checker:
    MOV R4, #0             		 @ Initialize front index (R4)
    MOV R5, R3             		 @ Initialize back index (R5)

palindrome_loop:
    CMP R4, R5            	     @ Check if front index meets or crosses back index
    BGE is_palindrome     	     @ If crossed, string is palindrome

@ Skip non-alphanumeric characters (Front)
skip_front:
    LDRB R6, [R1, R4]     	     @ Load front character
    BL is_alphanumeric    	     @ Check if it's alphanumeric
    CMP R0, #0             	     @ If not, move to next character
    BEQ increment_front          @ Skip if non-alphanumeric
    B check_back                 @ Otherwise, check back index

increment_front:
    ADD R4, R4, #1               @ Move to next character from the start
    B palindrome_loop            @ Restart loop

@ Skip non-alphanumeric characters (Back)
check_back:
    LDRB R7, [R1, R5]            @ Load back character
    BL is_alphanumeric           @ Check if it's alphanumeric
    CMP R0, #0                   @ If not, move to previous character
    BEQ decrement_back           @ Skip if non-alphanumeric
    B compare_chars              @ Otherwise, compare characters

decrement_back:
    SUB R5, R5, #1               @ Move to previous character from the end
    B palindrome_loop            @ Restart loop

@ Compare characters after filtering
compare_chars:
    BL to_lowercase              @ Convert both characters to lowercase

    CMP R6, R7                   @ Compare characters
    BNE not_a_palindrome         @ If mismatch, not a palindrome

    ADD R4, R4, #1               @ Move to next character from the start
    SUB R5, R5, #1               @ Move to next character from the end
    B palindrome_loop            @ Repeat check

@ Convert R6 and R7 to lowercase if they are uppercase
to_lowercase:
    CMP R6, #0x41                @ Compare front char with 'A'
    BLT skip_lower_R6            @ If less than 'A', skip conversion
    CMP R6, #0x5A                @ Compare front char with 'Z'
    BGT skip_lower_R6            @ If greater than 'Z', skip conversion
    ADD R6, R6, #0x20            @ Convert to lowercase

skip_lower_R6:
    CMP R7, #0x41                @ Compare back char with 'A'
    BLT skip_lower_R7            @ If less than 'A', skip conversion
    CMP R7, #0x5A                @ Compare back char with 'Z'
    BGT skip_lower_R7            @ If greater than 'Z', skip conversion
    ADD R7, R7, #0x20            @ Convert to lowercase

skip_lower_R7:
    BX LR                        @ Return

@ Check if R6 or R7 is alphanumeric (A-Z, a-z, 0-9)
is_alphanumeric:
    CMP R6, #0x30                @ Compare with '0'
    BLT not_alphanumeric         @ If less than '0', not alphanumeric
    CMP R6, #0x39                @ Compare with '9'
    BLE is_valid                 @ If between '0' and '9', alphanumeric

    CMP R6, #0x41                @ Compare with 'A'
    BLT not_alphanumeric         @ If less than 'A', not alphanumeric
    CMP R6, #0x5A                @ Compare with 'Z'
    BLE is_valid                 @ If between 'A' and 'Z', alphanumeric

    CMP R6, #0x61                @ Compare with 'a'
    BLT not_alphanumeric         @ If less than 'a', not alphanumeric
    CMP R6, #0x7A                @ Compare with 'z'
    BLE is_valid                 @ If between 'a' and 'z', alphanumeric

not_alphanumeric:
    MOV R0, #0                   @ Not alphanumeric
    BX LR

is_valid:
    MOV R0, #1                   @ Is alphanumeric
    BX LR

not_a_palindrome:
    MOV R0, #0                   @ Store 0 in R0 (Not a palindrome)
    BX LR

is_palindrome:
    MOV R0, #1                   @ Store 1 in R0 (Is a palindrome)
    BX LR

finished_string:
    B finished_string            @ Infinite loop (can be replaced with another task)
