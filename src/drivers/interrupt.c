#include <interrupt.h>
#include <stdint.h>
#include <stdio.h>
#include <log.h>
#include <global.h>
#include <io.h>

#define IDT_DESC_CNT 0x81          //目前支持的中断数
#define PIC_M_CTRL 0x20             //主片控制端口
#define PIC_M_DATA 0x21             //主片的数据端口
#define PIC_S_CTRL 0xa0             //从片控制端口
#define PIC_S_DATA 0xa1

//中断门描述符结构体
struct gate_desc {
    uint16_t func_offet_low_word;
    uint16_t selector;
    uint8_t dcount;
    uint8_t attribute;
    uint16_t func_offet_high_word;
};

/*定义idt表*/
static struct gate_desc idt[IDT_DESC_CNT];
extern intr_handler intr_entry_table[IDT_DESC_CNT];

char *intr_name[IDT_DESC_CNT]; //中断异常名字
intr_handler idt_table[IDT_DESC_CNT]; //定义中断处理程序

/*通用的中断处理程序,一般用在异常出现时处理*/
static void general_handler(uint8_t vec_nr) {
    if (vec_nr == 0x27 || vec_nr == 0x2f) {
        return;
    }

    fatal("Interrupt exception\n");
    fatal("name:");putstr(intr_name[vec_nr],4);

    while(1);

}
static void exception_init() {
    int i;
    for (i = 0;i < IDT_DESC_CNT; i++) {
        idt_table[i] = general_handler;
        intr_name[i] = "unknown";
    }
    intr_name[0] = "#DE Divide Error";
    intr_name[1] = "#DB Debug Exception";
    intr_name[2] = "NMI Interrupt";
    intr_name[3] = "#BP Breakpoint Exception";
    intr_name[4] = "#OF Overflow Exception";
    intr_name[5] = "#BR BOUND Range Exceeded Exception";
    intr_name[6] = "#UD Invalid Opcode Exception";
    intr_name[7] = "#NM Device Not Available Exception";
    intr_name[8] = "#DF Double Fault Exception";
    intr_name[9] = "Coprocessor Segment Overrun";
    intr_name[10] = "#TS Invalid TSS Exception";
    intr_name[11] = "#NP Segment Not Present";
    intr_name[12] = "#SS Stack Fault Exception";
    intr_name[13] = "#GP General Protection Exception";
    intr_name[14] = "#PF Page-Fault Exception";
    //第15项是intel保留项，不使用
    intr_name[16] = "#MF x87 FPU Floating-Point Error";
    intr_name[17] = "#AC Alignment Check Exception";
    intr_name[18] = "#MC Machine-Check Exception";
    intr_name[19] = "#XF SIMD Floating-Point Exception";
}
/*初始化8259A*/
static void pic_init() {
    /*初始化主片*/
    outb(PIC_M_CTRL,0x11);
    outb(PIC_M_DATA,0x20);
    outb(PIC_M_DATA,0x04);
    outb(PIC_M_DATA,0x01);

    /*初始化从片*/
    outb(PIC_S_CTRL,0x11);
    outb(PIC_S_DATA,0x28);
    outb(PIC_S_DATA,0x02);
    outb(PIC_S_DATA,0x01);

    outb(PIC_M_DATA,0xfe);
    outb(PIC_S_DATA,0xff);

    info("PIC init done.\n");
}

/*创建中断门描述符*/
static void make_idt_desc(struct gate_desc *p_gdesc, uint8_t attr,intr_handler func) {
    p_gdesc->func_offet_low_word = (uint32_t)func & 0x0000ffff;
    p_gdesc->selector = SELECTOR_K_CODE;
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offet_high_word = ((uint32_t)func & 0xffff0000) >> 16;
}

/*初始化中断描述符表*/
static void idt_desc_init() {
    int i = 0;
    for (i = 0;i < IDT_DESC_CNT;i++) {
        make_idt_desc(&idt[i],IDT_DESC_ATTR_DPL0,intr_entry_table[i]);
    }
    info("IDT desc init done.\n");
}

/*完成中断有关的初始化工作*/
void idt_init() {
    info("IDT init begin\n");
    idt_desc_init();
    exception_init();
    pic_init();

    /*加载idt*/
    uint64_t idt_operand = (sizeof(idt) - 1) | ((uint64_t)(uint32_t)idt << 16);
    asm volatile("lidt %0" : : "m"(idt_operand));
    info("IDT init done\n");
}

/*在中断处理程序数组第vector_no个元素中安装中断处理程序*/
void register_handler(uint8_t vector_no,intr_handler func) {
    idt_table[vector_no] = func;
}