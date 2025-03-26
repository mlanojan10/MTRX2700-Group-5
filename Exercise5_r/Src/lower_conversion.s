.syntax unified

.thumb

.global main

.data

.text

@ Initialises the input parameters and chooses whether to convert to upper or lower.
lower_conversion_main:

	LDR R12, =0x00 @The counter to the current place in the string.

@ Traverses the string characters, and sends upper case letters to be converted to lower case.
conversion_to_lower_loop:

	LDRB R4, [R1, R12] @This gets the current letter from the input string into the fourth register.

	CMP R4, R2 @Checks for the termination character.
	BEQ lower_return @Skips to the finished string block.

	SUB R5, R4, #65 @Finds where the value would be in ASCII if a lower conversion is to occur.
	CMP R5, 25 @Checks if the character is within the uppercase ASCII range. 25 is used because it is the range
			   @of ASCII characters to convert with the alphabet.
	BLS conversion_to_lower @If the compare was less than or equal to 25, the character is taken to the lower
	 						@conversion block.

	ADD R12, #1 @Increments the index.

	B conversion_to_lower_loop @Starts the process for the next character.

@ Converts an upper case letter to lower case, and leaves lower case letters as is.
conversion_to_lower:

	ADD R4, #32 @32 is the distance between upper and lower case in ASCII.
	STRB R4, [R1, R12] @Storing the converted character (R4) into the index (R3) of the input string (R1).

	ADD R12, #1 @Increments the index.
	B conversion_to_lower_loop @Starts the process for the next character.

@Lower conversion complete, return back for LED process.
lower_return:

	BX LR
