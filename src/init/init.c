#include <stdio.h>
#include "init.h"
#include <log.h>
#include <interrupt.h>
#include <drivers/timer.h>
#include <drivers/serial.h>
void init(void) {
    
    serial_init();
    info ("Initializing kernel\n");
    idt_init();
    timer_init();
    
}