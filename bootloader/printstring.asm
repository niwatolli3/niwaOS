;*********************************
; printstring
;*********************************
%ifndef PRINTSTRING_ASM
%define PRINTSTRING_ASM

;org	0x7c00
bits	16

PrintChar:
	MOV AH, 0x0E
	INT 0x10	
	RET

; input: SI(pointer of string)
PrintString:
	;MOV SI, string
	
	string_loop:
	MOV AL, [SI]
	INC SI
	OR AL, AL
	JZ exit_print_string
	CALL PrintChar
	JMP string_loop

	exit_print_string:
	RET
;string:
;	db 'Hello World!', 0

%endif
