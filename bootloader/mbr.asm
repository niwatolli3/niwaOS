;*********************************
; BootLoader (MBR Only)
;*********************************
ORG	0x7c00
;ORG	0x00
BITS	16

;*********************************
; const value
;*********************************
CYLS EQU 10	; cylinders
AX_FAT_ADDR EQU	0x07E0	; memory of FAT(*0.1 value)

;========================================
; BIOS Parameter Blog (BPB) for FAT12
;========================================
JMP		BOOT	; BS_jmpBoot
BS_OEMName	DB	"NiwaOS  "	; 8bytes
BPB_BytsPerSec	DW	0x0200		; Bytes Per Sector. 0x0200 = 512bytes
BPB_SecPerClus	DB	0x01
BPB_RsvdSecCnt	DW	0x0001
BPB_NumFATs	DB	0x02
BPB_RootEntCnt	DW	0x00E0
BPB_TotSec16	DW	0x0B40
BPB_Media	DB	0xF0		; 0xF0: removable media
BPB_FATSz16	DW	0x0009
BPB_SecPerTrk	DW	0x0012
BPB_NumHeads	DW	0x0002
BPB_HiddSec	DD	0x00000000
BPB_TotSec32	DD	0x00000000
BS_DrvNum	DB	0x00		; Drive A:0x00
BS_Reserved1	DB	0x00
BS_BootSig	DB	0x29
BS_VolID	DD	0x20150531
BS_VolLab	DB	"NiwaOS     "
BS_FilSysType	DB	"FAT12   "


%include "printstring.asm"

string:
	DB 'Hello World!', 0
stringError:
	DB 'FDD Read Error!', 0
stringResetFDDError:
	DB 'FDD Reset Error!', 0

ResetFDD:
	MOV	DL, 0x00	; drive A
	MOV	AH, 0x00
	MOV	DL, 0x00
	INT	0x13
	JC	ResetFDDFailed
	RET
ResetFDDFailed:
	MOV SI, stringResetFDDError
	CALL PrintString
	HLT

;*************
; read sector of C=0, H=0, S=2
; input: ES: address of memory
; input: CH: cylinder (0-indexed)
; input: DH: head (0-indexed)
; input: CL: sector (1-indexed, 1-18) ;*************
ReadSector:
	MOV	SI, 0	; retry count
retry:
	MOV	AH, 0x02	; AH=0x02 : disk read
	MOV 	AL, 1	; 1 sector
	MOV	BX, 0
	MOV	DL, 0x00	; drive A
	INT	0x13		; BIOS call: disk
	JNC	finReadSec
	INC	SI
	CMP	SI, 5
	JAE	error
	CALL	ResetFDD
	JMP	retry
error:
	MOV SI, stringError
	CALL PrintString
	HLT
finReadSec:
	RET

ReadFATSectors:
	MOV	AX, AX_FAT_ADDR ; FAT address on memory
	MOV	ES, AX
	MOV	CH, 0	; cylinder 0
	MOV	DH, 0	; head 0
	MOV	CL, 2	; sector 2
readFATLoop:
	CALL	ReadSector
	MOV	AX, ES
	ADD	AX, [BPB_BytsPerSec]	; 512bytes = 1 sector
	MOV	ES, AX
	INC	CL
	CMP	CL, 18
	JA	fin		; if CL > 18
	JMP	readFATLoop	; if CL <= 18

fin:
	RET
BOOT:
	;*************
	;init register
	;*************
	MOV	AX, 0
	MOV	BX, AX
	MOV	BP, AX
	MOV	CX, AX
	MOV	DX, AX
	MOV	SI, AX
	MOV	DI, AX
	
	MOV	SS, AX
	MOV	SP, 0x7c00
	MOV	DS, AX
	MOV	ES, AX
	
	CALL ReadFATSectors
	CALL ResetFDD
readCylinders:
	MOV	AX, [BPB_BytsPerSec]	; 512bytes = 1 sector
	MOV	BX, 17
	MUL	BX			; AX * BX(19sectors)
	ADD	AX, AX_FAT_ADDR		; FAT address on memory
	MOV	ES, AX
	MOV	CH, 0	; cylinder 0
	MOV	DH, 1	; head 1 (back)
	MOV	CL, 1	; sector 1
	CALL	ReadSector
	MOV	AX, ES
	ADD	AX, [BPB_BytsPerSec]
	MOV	ES, AX
	INC	CL
	CMP	CL, 18
	JA	.clNext		; CL > 18
	CALL	ReadSector	; CL <= 18
.clNext:
	MOV	CL, 1		; sector = 1
	INC	DH		; head++
	CMP	DH, 2		
	JAE	.dhNext		; DH >= 2
	CALL	ReadSector	; DH < 2
.dhNext:
	MOV	DH, 0		;head 0
	INC	CH		;cylinder++
	CMP	CH, CYLS
	JAE	.readCylindersFin	; CH >= CYLS
	CALL	ReadSector		; CH < CYLS
.readCylindersFin:
	MOV	SI, 0xBE00
	JMP	SI			; 0x7E00+0x4200-512
	MOV	SI, string
	CALL	PrintString
	HLT

	TIMES 510 - ($ - $$) DB 0	; Clear the rest of the bytes with 0
	DW 0xAA55			; Boot signature(2byte)
