/**
 * kernel.c
 * Copyright (c) WindowsEmbedded 2022-2024
 */
#include <stdio.h>


extern void KernelMain (unsigned long magic, unsigned long addr);


void KernelMain (unsigned long magic, unsigned long addr) {
    printf ("Starting Embedded OS...\n\n");
    while(1);
}

