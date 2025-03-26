.syntax unified

.thumb

.global main

.data

input_string: .asciz "Td%ringTssadkc\0"

.text

@Initialises the input parameters and chooses whether to convert to upper or lower.
main:

	LDR R1, =input_string 				@Load the address of the input string into register R1
	LDR R2, =0x01 						@This specifies whether the string will be converted to upper or lower case
				  						@(where 0 represents lower and 1 respresents upper).
	LDR R3, =0x00 						@The counter to the current place in the string.

	CMP R2, #0x01 						@Determines if we are wanting to convert to upper or lower based on the bit in register 2.
	BEQ conversion_to_upper_loop 		@If the compare came back as true, the lower conversion loops are skipped.

@ Traverses the string characters, and sends upper case letters to be converted to lower case.
conversion_to_lower_loop:

	LDRB R4, [R1, R3] 					@This gets the current letter from the input string into the fourth register.

	CMP R4, #0 							@Checks for the null termination character.
	BEQ finished_string 				@Skips to the finished string block.

	SUB R5, R4, #65 					@Finds where the value would be in ASCII if a lower conversion is to occur.
	CMP R5, 25 							@Checks if the character is within the uppercase ASCII range. 25 is used because it is the range
			   							@of ASCII characters to convert with the alphabet.
	BLS conversion_to_lower 			@If the compare was less than or equal to 25, the character is taken to the lower
	 									@conversion block.

	ADD R3, #1 							@Increments the index.

	B conversion_to_lower_loop 			@Starts the process for the next character.

@ Converts an upper case letter to lower case, and leaves lower case letters as is.
conversion_to_lower:

	ADD R4, #32 						@32 is the distance between upper and lower case in ASCII.
	STRB R4, [R1, R3] 					@Storing the converted character (R4) into the index (R3) of the input string (R1).

	ADD R3, #1 							@Increments the index.
	B conversion_to_lower_loop 			@Starts the process for the next character.

@ Traverses the string characters, and sends lower case letters to be converted to upper case.
conversion_to_upper_loop:

	LDRB R4, [R1, R3] 					@This gets the current letter from the input string into the fourth register.

	CMP R4, #0 							@Checks for the null termination character.
	BEQ finished_string 				@Skips to the finished string block.

	SUB R5, R4, #97 					@Finds where the value would be in ASCII if an upper conversion is to occur.
	CMP R5, 25 							@Checks if the character is within the lowercase ASCII range. 25 is used because it is the range of
			   							@ASCII characters to convert with the alphabet.
	BLS conversion_to_upper 			@If the compare was less than or equal to 25, the character is taken to the upper
										@conversion block.

	ADD R3, #1 							@Increments the index.

	B conversion_to_upper_loop 			@Starts the process for the next character.

@ Converts a lower case letter to upper case, and leaves upper case letters as is.
conversion_to_upper:

	ADD R4, #-32 						@32 is the distance between upper and lower case in ASCII.
	STRB R4, [R1, R3] 					@Storing the converted character (R4) into the index (R3) of the input string (R1).

	ADD R3, #1 							@Increments the index.
	B conversion_to_upper_loop 			@Starts the process for the next character.

@ Infinite loop.
finished_string:

	B finished_string 					@Infinite loop.
