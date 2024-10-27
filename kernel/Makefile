CC = gcc
LD = ld
CFLAGS = -m32 -fno-builtin -fno-stack-protector -nostartfiles -I../include/
LDFLAGS = -Ttext 0x100000 -melf_i386 -nostdlib 

INITPATH = ./init/
BUILDPATH = ../build/

OBJS = $(BUILDPATH)muitlboot.o $(BUILDPATH)stdio.o $(BUILDPATH)kernel.o 

all: $(BUILDPATH)kernel.bin
$(BUILDPATH)kernel.bin:$(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $@
$(BUILDPATH)%.o:$(INITPATH)%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)%.o:./src/%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(BUILDPATH)muitlboot.o:./init/muitlboot.S 
	$(CC) -c $(CFLAGS) $< -o $@