.syntax unified
.thumb

.global main

.data
input_string: .asciz "RACERCaR"  @ Change this string to test different cases

.text

@ Exercise  1 b)
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

@ Palindrome checker (case-insensitive)
palindrome_checker:
    MOV R4, #0             		 @ Initialize front index (R4)
    MOV R5, R3             		 @ Initialize back index (R5)

palindrome_loop:
    CMP R4, R5            	     @ Check if front index meets or crosses back index
    BGE is_palindrome     	     @ If crossed, string is palindrome

    LDRB R6, [R1, R4]     	     @ Load front character
    LDRB R7, [R1, R5]       	 @ Load back character

    BL to_lowercase         	 @ Convert both characters to lowercase before comparison

    CMP R6, R7              	 @ Compare characters
    BNE not_a_palindrome    	 @ If mismatch, not a palindrome

    ADD R4, R4, #1          	 @ Move to next character from the start
    SUB R5, R5, #1          	 @ Move to next character from the end
    B palindrome_loop       	 @ Repeat check

@ Convert R6 and R7 to lowercase if they are uppercase
to_lowercase:
    CMP R6, #0x41           	 @ Compare front char with 'A'
    BLT skip_lower_R6        	 @ If less than 'A', skip conversion
    CMP R6, #0x5A            	 @ Compare front char with 'Z'
    BGT skip_lower_R6        	 @ If greater than 'Z', skip conversion
    ADD R6, R6, #0x20        	 @ Convert to lowercase

skip_lower_R6:
    CMP R7, #0x41           	@ Compare back char with 'A'
    BLT skip_lower_R7        	@ If less than 'A', skip conversion
    CMP R7, #0x5A            	@ Compare back char with 'Z'
    BGT skip_lower_R7        	@ If greater than 'Z', skip conversion
    ADD R7, R7, #0x20        	@ Convert to lowercase

skip_lower_R7:
    BX LR                    	@ Return

not_a_palindrome:
    MOV R0, #0               	@ Store 0 in R0 (Not a palindrome)
    BX LR                    	@ Return

is_palindrome:
    MOV R0, #1               	@ Store 1 in R0 (Is a palindrome)
    BX LR                       @ Return

finished_string:
    B finished_string       	@ Infinite loop (can be replaced with another task)
