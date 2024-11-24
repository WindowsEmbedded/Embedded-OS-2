#ifndef INT_H_
#define INT_H_
#include <stdint.h>

typedef void* intr_handler;
void register_handler(uint8_t vector_no,intr_handler func);
void idt_init();
#endif