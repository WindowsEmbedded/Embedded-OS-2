#ifndef IO_H_
#define IO_H_
#include <stdint.h>

extern inline void outb (uint16_t port, uint8_t data);
extern inline void outsw (uint16_t port, const void* addr, uint32_t word_cnt);
extern inline uint8_t inb (uint16_t port);

#endif