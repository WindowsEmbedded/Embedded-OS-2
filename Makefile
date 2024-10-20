#Embedded OS
#Makefile
#
#Copyright (c) EmbedSys & WindowsEmbedded.
TOOLPATH = ./tools/
KRNPATH = ./kernel/
BUILDPATH = ./build/
IMGPATH = ./images/

NASM = $(TOOLPATH)nasm.exe
MAKE = $(TOOLPATH)make.exe -r
EDIMG = $(TOOLPATH)edimg.exe
DEL = del
#QEMU = $(TOOLPATH)QEMU/qemu-system-i386.exe
QEMU = qemu-system-i386.exe

default:
	$(MAKE) compile
build: 
	mkdir build
compile:
	$(NASM) $(KRNPATH)boot.asm -o $(BUILDPATH)boot.bin
	$(NASM) $(KRNPATH)loader.asm -o $(BUILDPATH)loader.bin
	$(NASM) $(KRNPATH)kernel.asm -o $(BUILDPATH)kernel.bin
	$(EDIMG) imgin:$(TOOLPATH)fdimg0at.tek \
		wbinimg src:$(BUILDPATH)boot.bin len:1024 from:0 to:0 \
		copy from:$(BUILDPATH)loader.bin to:@: \
		copy from:$(BUILDPATH)kernel.bin to:@: \
		imgout:$(IMGPATH)target.img
clean:
	$(DEL) .\build\*.bin
run:
	$(MAKE) compile
	$(QEMU) -fda $(IMGPATH)target.img
