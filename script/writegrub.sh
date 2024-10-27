#!/usr/bin/env bash
CFGPATH=$1
cat <<EOF >./build/grub.cfg
set timeout=10
set default=0
menuentry "Embedded OS" {
    multiboot2 /boot/kernel.bin
    boot
}
EOF
sudo cp ./build/grub.cfg ${CFGPATH}