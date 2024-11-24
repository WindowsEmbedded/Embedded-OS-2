/**
 * global.h
 * Copyright (c) WindowsEmbedded 2022-2024.
 */
#ifndef MULTIBOOT2_H_
#define MULTIBOOT2_H_
#include <stdint.h>
/*GDT描述符属性*/
#define RPL0            0
#define RPL1            1
#define RPL2            2
#define RPL3            3

#define TI_GDT          0
#define TI_LDT          1

#define DESC_G_4K       1
#define DESC_D_32       1
#define DESC_L          0
#define DESC_AVL        0
#define DESC_P          1
#define DESC_DPL_0      0
#define DESC_DPL_1      1
#define DESC_DPL_2      2
#define DESC_DPL_3      3

#define DESC_S_CODE     1
#define DESC_S_DATA     DESC_S_CODE
#define DESC_S_SYS      0
#define DESC_TYPE_CODE  8

#define SELECTOR_K_CODE     ((1 << 3) + (TI_GDT << 2) + RPL0)
#define SELECTOR_K_DATA     ((2 << 3) + (TI_GDT << 2) + RPL0)
#define SELECTOR_K_STACK    SELECTOR_K_DATA
#define SELECTOR_K_GS       ((3 << 3) + (TI_GDT << 2) + RPL0)

/*IDT描述符属性*/
#define IDT_DESC_P          1
#define IDT_DESC_DPL0       0
#define IDT_DESC_DPL3       3
#define IDT_DESC_32_TYPE    0xE
#define IDT_DESC_16_TYPE    0X6

#define IDT_DESC_ATTR_DPL0 \
        ((IDT_DESC_P << 7) + (IDT_DESC_DPL0 << 5) + IDT_DESC_32_TYPE)
#define IDT_DESC_ATTR_DPL3 \
        ((IDT_DESC_P << 7) + (IDT_DESC_DPL3 << 5) + IDT_DESC_32_TYPE)

#endif