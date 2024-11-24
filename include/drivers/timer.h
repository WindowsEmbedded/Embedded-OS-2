#ifndef TIMER_H_
#define TIMER_H_
#include <stdint.h>

void timer_init();
static void intr_timer_handler(uint8_t vec_nr);
#endif