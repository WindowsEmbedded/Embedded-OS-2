CC = gcc
ASM= nasm
LD = ld
CFLAGS = -m32 -fno-builtin -fno-stack-protector -nostartfiles -I../include/ -I../include/sys/ -I../include/kernel/ 
LDFLAGS = -Ttext 0x100000 -m elf_i386 -nostdlib 

INITPATH = ./init/
BUILDPATH = ../build/

OBJS =  $(BUILDPATH)idt.o $(BUILDPATH)io.o $(BUILDPATH)muitlboot.o $(BUILDPATH)stdio.o $(BUILDPATH)kernel.o \
		$(BUILDPATH)log.o $(BUILDPATH)interrupt.o  $(BUILDPATH)timer.o $(BUILDPATH)nasmfunc.o  $(BUILDPATH)init.o \
		$(BUILDPATH)serial.o

all: $(BUILDPATH)kernel.bin
$(BUILDPATH)kernel.bin:$(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $@
$(BUILDPATH)%.o:$(INITPATH)%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)%.o:./kernel/%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)%.o:./drivers/%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)%.o:./drivers/general/%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)muitlboot.o:./init/muitlboot.S 
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)%.o:./asmfunc/%.asm
	$(ASM) -f elf $< -o $@