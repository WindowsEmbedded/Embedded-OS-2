#ifndef STDIO_H_
#define STDIO_H_

#define COLUMN      80
#define LINE        24
#define ATTRIBUTE   7
#define VIDEO       0xb8000 //显存起始位置

void putchar (int chr);
void itoa (char *buf, int base, int d);
void printf (const char *format, ...);

#endif