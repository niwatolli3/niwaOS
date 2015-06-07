GDT_DESC_BYTE EQU 8
GDT_NUM EQU 3	; number of GDT

%define CODE_DESC	(0x08)
%define DATA_DESC	(0x08*2)


;*********************************
; NiwaOS
;*********************************
ORG	0xBE00
BITS	16

JMP	boot

%include "printstring.asm"

;*********************************
; const value
;*********************************
%define KERN_IMG_SIZE	(512*10)
%define KERN_IMG_RMODE_BASE	(0xBE00+0x4400-0x4200)
%define KERN_IMG_PMODE_BASE	0x100000

; GDT Table
_gdt:
	; Null descriptor (determined by the specific of Intel CPUs)
	DW	0x0000
	DW	0x0000
	DW	0x0000
	DW	0x0000
; Code Descriptor
	DW	0xFFFF		; Segment Limit Low
	DW	0x0000		; Base Address Low
	DB	0x00		; Base Address Mid
	DB	10011010b	; P, DPL, S, Type, A
	DB	11001111b	; G, D/B, 0, AVL, SegLimit Hi
	DB	0x00		; Base Address Hi

	; Data Descriptor
	DB	0xFFFF		; Segment Limit Low
	DW	0x0000		; Base Address Low
	DB	0x00		; Base Address Mid
	DB	10010010b	; P, DPL, S, Type, A
	DB	11001111b	; G, D/B, 0, AVL, SegLimit Hi
	DB	0x00		; Base Address Hi

gdt_toc:
	DW	GDT_DESC_BYTE*GDT_NUM	; GDT Size
	DD	_gdt			; GDT Addr

sel_cs0:
	DB	00b	; RPL
	DB	0b	; TI	; 0:GDT
	DB	0000000001000b	; Index
sel_ds0:
	DB	00b	; RPL
	DB	0b	; TI	; 0:GDT
	DB	0000000010000b	; Index

;*******************************
;Setup Global Descriptor Table
;*******************************
SetupGDT:
	CLI
	PUSHA
	LGDT	[gdt_toc]
	STI
	POPA
	RET
;*******************************
; Enable A20
;*******************************
string_a20_2401_error_01h:
	DB	"[E] INT2401h keycon is in secure mode", 0x00
string_a20_2401_error_86h:
	DB	"[E] INT2401h func not supported", 0x00
string_a20_2402_error_01h:
	DB	"[E] INT2402h keycon is in secure mode", 0x00
string_a20_2402_error_86h:
	DB	"[E] INT2402h func not supported", 0x00
string_a20_2402_success:
	DB	"Enable A20 Success..", 0x0d, 0x0a, 0x00
string_a20_2402_wait:
	DB	"Enable A20 wait...", 0x0d, 0x0a, 0x00
EnableA20:
	MOV	AX, 0x2401
	INT	0x15
	JNC	a20_2401_success
	CMP	AH, 0x01
	JZ	a20_2401_error_01h
	CMP	AH, 0x86
	JZ	a20_2401_error_86h
a20_2401_error_01h:
	MOV	SI, string_a20_2401_error_01h
a20_2401_error_86h:
	MOV	SI, string_a20_2401_error_86h
	CALL	PrintString
	HLT
a20_2401_success:
	MOV	AX, 0x2402
	INT	0x15
	JNC	a20_2402_success
	CMP	AH, 0x01
	JZ	a20_2402_error_01h
	CMP	AH, 0x86
	JZ	a20_2402_error_86h
a20_2402_error_01h:
	MOV	SI, string_a20_2402_error_01h
a20_2402_error_86h:
	MOV	SI, string_a20_2402_error_86h
	CALL	PrintString
	HLT
a20_2402_success:
	CMP	AL, 0x01
	MOV	SI, string_a20_2402_wait
	CALL	PrintString
	JNZ	a20_2401_success	;wait A20 enabled
	MOV	SI, string_a20_2402_success
	CALL	PrintString
	RET
;
string_goto_prot_mode:
	DB	"go2 prot mode...", 0x0d, 0x0a, 0x00
boot:
	CALL	SetupGDT
	CALL	EnableA20

	; go to the protection mode
	MOV	SI, string_goto_prot_mode
	CALL	PrintString
	MOV	EAX, CR0
	OR	EAX, 0x01
	MOV	CR0, EAX
	JMP	CODE_DESC:prot_mode_start

;********************
;Protected Mode
;********************
[BITS 32]
prot_mode_start:
	MOV	AX, DATA_DESC
	MOV	BX, AX
	MOV	DS, AX
	MOV	ES, AX
	MOV	FS, AX
	MOV	GS, AX
	MOV	SS, AX
	
	MOV	ESP, 0x90000
CopyKernImg:
; ESIからEDIのアドレスに1byteずつ,ECX回繰り返す
	MOV	ESI, KERN_IMG_RMODE_BASE
	MOV	EDI, KERN_IMG_PMODE_BASE
	MOV	ECX, KERN_IMG_SIZE
REP	MOVSD
	JMP	run_kernel
fail_exec_kern:
	HLT
	JMP	fail_exec_kern
run_kernel:
	MOV	EBP, KERN_IMG_PMODE_BASE
	CLI
	CALL	EBP
	JMP	fail_exec_kern
