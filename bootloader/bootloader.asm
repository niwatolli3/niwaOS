;*********************************
; BootLoader
;*********************************
ORG	0x7c00
BITS	16

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
BS_VolID	DD	0x00000000
BS_VolLab	DB	"NiwaOS     "
BS_FileSysType	DB	"FAT12    "

%include "printstring.asm"

string:
	DB 'Hello World!', 0

BOOT:
	MOV SI, string
	CALL PrintString
	CLI
	HLT

	TIMES 510 - ($ - $$) DB 0	; Clear the rest of the bytes with 0
	DW 0xAA55			; Boot signature(2byte)
