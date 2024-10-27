#include <multiboot2.h>
#ifdef HAVE_ASM_USCORE
#defile EXT_C(sym)          _
#else
#define EXT_C(sym)          sym 
#endif
#define STACK_SIZE          0x4000

    .text

multiboot_header:
    .align 8
    .long 0xe85250d6 //魔数
    .long 0
    .long multiboot_header_end - multiboot_header //multiboot头大小
    .long -(0xe85250d6 + 0 + (multiboot_header_end - multiboot_header))
entry_address_tag_start:
    .align 8
    .short 3
    .short 1
    .long entry_address_tag_end - entry_address_tag_start
    .long entry
entry_address_tag_end:
end_tag_start:
    .align 8
    .short 0
    .short 0
    .long end_tag_end - end_tag_start
end_tag_end:
multiboot_header_end:
.global entry
entry: //main
    movl $(stack + STACK_SIZE), %esp //初始化栈

    pushl $0
    popf

    pushl %ebx
    pushl %eax

    call EXT_C(KernelMain)


loop:
    hlt 
    jmp loop
.comm stack,STACK_SIZE

