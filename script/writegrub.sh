#!/usr/bin/env bash
CFGPATH = $1
cat <<EOF > $CFGPATH
set timeout=10
set default=0
menuentry "Embedded OS" {
    multiboot2 /boot/kernel.bin
    boot
}
EOF