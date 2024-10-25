#Embedded OS
#Makefile
#
#Copyright (c) WindowsEmbedded 2022~2024
TOOLPATH = ./tools/
KRNPATH = ./kernel/
BUILDPATH = ./build/
IMGPATH = ./images/

NASM = nasm
MAKE = make -r
EDIMG = qemu-img
DEL = rm
#QEMU = $(TOOLPATH)QEMU/qemu-system-i386.exe
QEMU = qemu-system-i386.exe

IMG = $(IMGPATH)target.img
OBJ = $(BUILDPATH)boot.bin $(BUILDPATH)loader.bin $(BUILDPATH)kernel.bin
.PHONY:build

default:
	$(MAKE) $(IMG)

makeimg:
	$(EDIMG) create $(IMG) 1474560
	mformat -f 1440 -B $(BUILDPATH)boot.bin -i $(IMG)

$(IMG):$(OBJ) Makefile
	$(MAKE) makeimg
	mcopy -i $(IMG) $(BUILDPATH)loader.bin ::
	mcopy -i $(IMG) $(BUILDPATH)kernel.bin ::

$(BUILDPATH)%.bin:$(KRNPATH)%.asm Makefile
	$(NASM) $< -o $@

build: 
	mkdir build

clean:
	$(DEL) $(OBJ)
	$(DEL) $(IMG)
run:
	$(MAKE) $(IMG)
	$(QEMU) -fda $(IMGPATH)target.img
