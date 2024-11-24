/**
 * kernel.c
 * Copyright (c) WindowsEmbedded 2022-2024
 */
#include <stdio.h>
#include "init.h"
#include <drivers/serial.h>


extern void KernelMain (unsigned long magic, unsigned long addr);
void asm_sti();


void KernelMain (unsigned long magic, unsigned long addr) {
    printf ("Starting Embedded OS...\n\n");
    init();

    //asm volatile("sti");
    while(1);
}

