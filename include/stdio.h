#ifndef STDIO_H_
#define STDIO_H_

#define COLUMN      80
#define LINE        25
#define ATTRIBUTE   7
#define VIDEO       0xb8000 //显存起始位置

#include <stdint.h>

void putstr (char *str,int attr);
//void log_info (char *str);
void putchar (int chr,uint8_t attr);
void itoa (char *buf, int base, int d);
void printf (const char *format, ...);

#endif