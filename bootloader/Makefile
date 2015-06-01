ASM = nasm
MBR_NAME = mbr
NASMFILE_SFX = .asm
FLOPPYIMG_SFX = .img

FLOPPY = floppy.img

DATAAREA_NAME = data_area

mbr.img : mbr.asm
	$(ASM) $(MBR_NAME)$(NASMFILE_SFX) -o mbr$(FLOPPYIMG_SFX)
niwaOS.img : niwaOS.asm
	$(ASM) niwaOS$(NASMFILE_SFX) -o niwaOS$(FLOPPYIMG_SFX)

floppy : mbr.img data_area.img niwaOS.img
	cp $(MBR_NAME)$(FLOPPYIMG_SFX) $(FLOPPY)
	dd if=$(DATAAREA_NAME)$(FLOPPYIMG_SFX) of=$(FLOPPY) seek=1 skip=1
	dd if=niwaOS$(FLOPPYIMG_SFX) of=$(FLOPPY) seek=33 skip=0 conv=notrunc

run : floppy.img
	qemu-230 -L . -m 32 -localtime -vga std -fda floppy.img

.PHONY: clean
clean:
	-rm $(MBR_NAME)$(FLOPPYIMG_SFX)
	-rm $(FLOPPY)
