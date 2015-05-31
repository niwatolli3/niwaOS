ASM = nasm
MBR_NAME = mbr
NASMFILE_SFX = .asm
FLOPPYIMG_SFX = .img

FLOPPY = floppy.img

DATAAREA_NAME = data_area

mbr.img : mbr.asm
	$(ASM) $(MBR_NAME)$(NASMFILE_SFX) -o mbr$(FLOPPYIMG_SFX)

floppy : mbr.img data_area.img
	cp $(MBR_NAME)$(FLOPPYIMG_SFX) $(FLOPPY)
	dd if=$(DATAAREA_NAME)$(FLOPPYIMG_SFX) of=$(FLOPPY) seek=1 skip=1

.PHONY: clean
clean:
	-rm $(MBR_NAME)$(FLOPPYIMG_SFX)
