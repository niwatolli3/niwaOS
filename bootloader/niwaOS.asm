;*********************************
; NiwaOS
;*********************************
ORG	0xC000		; 0x7E00(MBR start) + 0x4200
BITS	16

;*********************************
; const value
;*********************************
CYLS EQU 10	; cylinders
AX_FAT_ADDR EQU	0x7E00	; memory of FAT

MOV	AL, 0x13	; VGA, 320x200x8bit color
MOV	AH, 0x00
INT	0x10
fin:
	HLT
	JMP fin
string:
	DB	"hello world!", 0
