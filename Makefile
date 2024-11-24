#Embedded OS
#Makefile
#
#Copyright (c) WindowsEmbedded 2022~2024
TOOLPATH = ./tools/
KRNPATH = ./src/
BUILDPATH = ./build/
IMGPATH = ./images/

CC = gcc
LD = ld 
CFLAGS = -m32 -fno-builtin -fno-stack-protector -nostartfiles -I./include/ -I./include/sys/
LDFLAGS = -Ttext 0x100000 -melf_i386 -nostdlib 
NASM = nasm
MAKE = make -r
EDIMG = qemu-img
DEL = rm
#QEMU = $(TOOLPATH)QEMU/qemu-system-i386.exe
QEMU = qemu-system-i386

IMG = $(IMGPATH)target.img
OBJ = $(BUILDPATH)muitlboot.o $(BUILDPATH)stdio.o $(BUILDPATH)kernel.o 
.PHONY:build clean run 

default:
	$(MAKE) -C $(KRNPATH)
	$(MAKE) makeimg

makeimg: $(IMG) $(BUILDPATH)kernel.bin Makefile
	sudo losetup -P /dev/loop0 $(IMG)
	sudo mkdir /mnt/eos
	sudo mount /dev/loop0p1 /mnt/eos
	sudo ./script/writegrub.sh /mnt/eos/boot/grub/grub.cfg
	sudo cp $(BUILDPATH)kernel.bin /mnt/eos/boot
	sudo umount /mnt/eos
	sudo rmdir /mnt/eos
	sudo losetup -d /dev/loop0
	

$(IMG):$(OBJ) Makefile
	dd if=/dev/zero of=$(IMG) bs=1M count=60
	parted -s $(IMG) mklabel msdos mkpart primary ext2 1MiB 100%
	sudo losetup -P /dev/loop0 $(IMG)
	sudo mkfs.ext2 /dev/loop0p1
	sudo mkdir /mnt/eos
	sudo mount /dev/loop0p1 /mnt/eos
	sudo grub-install --target=i386-pc --boot-directory=/mnt/eos/boot /dev/loop0
	sudo mkdir -p /mnt/eos/boot/grub
	sudo umount /mnt/eos
	sudo rmdir /mnt/eos
	sudo losetup -d /dev/loop0

build: 
	mkdir build

clean:
	sudo umount /mnt/eos || true
	sudo rmdir /mnt/eos || true
	sudo losetup -d /dev/loop0 || true
	$(DEL) $(BUILDPATH)*
#	$(DEL) $(IMG)
run:
	$(MAKE) default
	$(QEMU) -hda $(IMGPATH)target.img -m 1G -serial stdio
