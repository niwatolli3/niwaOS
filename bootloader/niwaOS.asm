GDT_DESC_BYTE EQU 8
GDT_NUM EQU 3	; number of GDT


;*********************************
; NiwaOS
;*********************************
ORG	0xBE00
BITS	16

JMP	boot

;*********************************
; const value
;*********************************

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

boot:
	CALL	SetupGDT

	MOV	AL, 0x13	; VGA, 320x200x8bit color
	MOV	AH, 0x00
	INT	0x10
fin:
	HLT
	JMP fin
