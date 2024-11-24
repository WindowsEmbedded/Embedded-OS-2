#include <drivers/serial.h>
#include <stdint.h>
#include <sys/log.h>
#include <stdio.h>
#include <io.h>
static int com_base = 0;
void serial_putstr(char* str) {
    int i;
    for (i = 0;str[i] !='\0';i++) {
        serial_putchar(str[i]);
    }
}
void serial_putchar(uint16_t ch) {
    uint8_t res;

    do {
        res = inb(com_base + COM_REG_LSR);
    } while ((res & 0x20) == 0);

    outb (com_base,ch);
}
int init_com(size_t base_port) {
    outb(base_port + COM_REG_IER,0x00);

    outb(base_port + COM_REG_LCR, COM_LCR_DLAB_ON);

    outb(base_port + COM_REG_DLL, 0x03);
    outb(base_port + COM_REG_DLM, 0x00);

    outb(base_port + COM_REG_LCR,
         COM_LCR_DB_WLEN_8 | COM_LCR_SB_ONE | COM_LCR_DLAB_OFF);

    outb(base_port + COM_REG_FCR,
       COM_FCR_ITLB_TL_14 | COM_FCR_CTFB_ON | COM_FCR_CRFB_ON | COM_FCR_EFB_ON);
    
    outb(base_port + COM_REG_MCR,
         COM_MCR_OUT2_ON | COM_MCR_RTSB_ON | COM_MCR_DTRB_ON);

    outb(base_port + COM_REG_MCR,
         COM_MCR_LB_ON | COM_MCR_OUT2_ON | COM_MCR_OUT1_ON | COM_MCR_RTSB_ON);

    outb(base_port + COM_REG_TX, 'a');
    if (inb(base_port+COM_REG_TX) != 'a') {
        return -1;
    }

    outb(base_port + COM_REG_MCR,
         COM_MCR_OUT2_ON | COM_MCR_OUT1_ON | COM_MCR_RTSB_ON | COM_MCR_DTRB_ON);

    //info("serial init done");
    return 0;
}
void serial_init() {
    if (init_com(COM1_BASE)) {
        if (init_com(COM2_BASE)) {
            fatal("Serial init failed");
        } else {
            com_base = COM2_BASE;
        }
    } else {
        com_base = COM1_BASE;
    }
    info ("serial init done.");
    return;
}