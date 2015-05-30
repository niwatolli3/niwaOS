;*********************************
; BootLoader
;*********************************
org	0x7c00
bits	16

Start:
	CALL	PrintString
	
	cli			; Clear interrupts
	hlt			; halt the system

PrintChar:
	MOV AH, 0x0E
	INT 0x10	
	RET

PrintString:
	MOV SI, string
	
	string_loop:
	MOV AL, [SI]
	INC SI
	OR AL, AL
	JZ exit_print_string
	CALL PrintChar
	JMP string_loop

	exit_print_string:
	RET
	

string:
	db 'Hello World!', 0

times 510 - ($ - $$) db 0	; Clear the rest of the bytes with 0
dw 0xAA55			; Boot signature(2byte)

