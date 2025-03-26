.syntax unified

.thumb

.global main

.data

alphabet_string: .asciz "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\0"
substitution_cipher_string: .asciz "eqhygmsuifdrlzvoktncjwpxbaEQHYGMSUIFDRLZVOKTNCJWPXBA\0"

.text

@ Loading various parameters
cipher_main:

	LDR R0, =0x01 @Desired cypher cycles.
	LDR R12, =alphabet_string @Load the address of the alphabet string into register R12.
	LDR R4, =substitution_cipher_string @Load the address of the substitution cipher string into register R4.
	LDR R5, =0x-01 @Index of input string.
	LDR R6, =0x00 @Index of alphabet/substitution cipher string.

@ Checks if the number of desired substitution cycles have been completed.
program_loop:

	CMP R0, #0x00 @Checks if the desired number of cycles have been completed.
	BEQ return @Terminates the program if the desired number of cycles had been completed.

	B traverse_string_loop @Traverses the input string.

@Traverses the string, then calls for encryption.
traverse_string_loop:

	ADD R5, #0x01 @Increments the index for the input string traversal.
	LDRB R7, [R1, R5] @Loads the character of the string at the offset of the increment.

	CMP R7, R2 @Checks if the null termination character has been reached.
	BEQ subtract_cycle @Subtracts one from the remaining cycles (desired cycles).

	B traverse_alphabet @Traverses through the alphabet, looking to find a match with the current input string character.

@Traverses the alphabet, comparing it with the string character, then encoding the string character if it is a match.
traverse_alphabet:

	LDRB R8, [R12, R6] @Loads the character of the alphabet at the offset of the alphabet increment.

	@If the end of the alphabet was reached without finding a match, that character does not need to be encrypted.
	CMP R8, #0x00 @Checks if the null termination character has been reached (NOT the user-defined termination character).
	BEQ letter_not_found @Goes to the next character in the input string.

	CMP R7, R8 @Checks if the current character of the alphabet matches the current character of the input string.
	BEQ encode_character @Gets the corresponding substitution cipher character.

	ADD R6, #0x01 @Increments the index of the alphabet.

	B traverse_alphabet @Recalls for the next index of the alphabet.

@Encoding the string character with the corresponding substitution cipher value.
encode_character:

	LDRB R9, [R4, R6] @Loads the corresponding substitution cipher character based off the offset of the alphabet string.
	STRB R9, [R1, R5] @Overwrites the input string data with the substitution cipher data.

	LDR R6, =0x00 @Resets the index of the alphabet to the start.

	B traverse_string_loop @Recalls for the next index of the input string.

@Removes one from the desired substitution cycles count.
subtract_cycle:

	LDR R5, =0x-01 @Resets the index of the input string to the start.
	SUB R0, 0x01 @Subtracts one from the remaining cycles (desired cycles).
	B program_loop @Calls for a start of the next cycle.

@Where a letter is not found, the index of alphabet/substitution cipher string is reset.
letter_not_found:

	LDR R6, =0x00
	B traverse_string_loop

@Substitution cipher complete, returns back to transmission process
return:

	BX LR @ return
