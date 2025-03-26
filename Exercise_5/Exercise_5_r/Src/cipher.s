.syntax unified

.thumb

.global main

.data

alphabet_string: .asciz "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\0"
substitution_cipher_string: .asciz "eqhygmsuifdrlzvoktncjwpxbaEQHYGMSUIFDRLZVOKTNCJWPXBA\0"

.text

@ Loading various parameters
cipher_main:

	LDR R8, =0x01 @Desired cypher cycles.
	LDR R12, =alphabet_string @Load the address of the alphabet string into register R3.
	LDR R4, =substitution_cipher_string @Load the address of the substitution cipher string into register R4.
	LDR R5, =0x-01 @Index of input string.
	LDR R6, =0x00 @Index of alphabet/substitution cipher string.

@ Checks if the number of desired substitution cycles have been completed.
program_loop:

	CMP R8, #0x00 @Checks if the desired number of cycles have been completed.
	BEQ return @Terminates the program if the desired number of cycles had been completed.

@Traverses the string, then calls for decryption.
traverse_string_loop:

	ADD R5, #0x01 @Increments the index for the input string traversal.
	LDRB R7, [R1, R5] @Loads the character of the string at the offset of the increment.

	CMP R7, R2 @Checks if the null termination character has been reached.
	BEQ subtract_cycle @Subtracts one from the remaining cycles (desired cycles).

	B traverse_substitution_cipher @Traverses through the substitution cipher, looking for a match with the current input string character.

@Traverses the alphabet, comparing it with the string character, then decoding the string character if it is a match.
traverse_substitution_cipher:

	LDRB R10, [R4, R6] @Loads the character of the substitution cipher at the offset of the substitution cipher increment.

	CMP R10, #0x00 @Checks if the null termination character has been reached.
	BEQ letter_not_found

	CMP R7, R10 @Checks if the current character of the alphabet matches the current character of the input string.
	BEQ decode_character @Gets the corresponding substitution cipher character.

	ADD R6, #0x01 @Increments the index of the substitution cipher.

	B traverse_substitution_cipher @Recalls for the next index of the substitution cipher.

@Decoding the string character with the corresponding substitution cipher value.
decode_character:

	LDRB R11, [R12, R6] @Loads the corresponding substitution alphabet based off the offset of the cipher character string.
	STRB R11, [R1, R5] @Overwrites the input string data with the alphabet data.

	LDR R6, =0x00 @Resets the index of the cipher character to the start.

	B traverse_string_loop @Recalls for the next index of the input string.

@Removes one from the desired substitution cycles count.
subtract_cycle:

	LDR R5, =0x-01 @Resets the index of the input string to the start.
	SUB R8, 0x01 @Subtracts one from the remaining cycles (desired cycles).
	B program_loop @Calls for a start of the next cycle.

@Where a letter is not found, the index of alphabet/substitution cipher string is reset.
letter_not_found:

	LDR R6, =0x00

	B traverse_string_loop

@Substitution cipher complete, returns back to transmission process
return:

	BX LR @ return
