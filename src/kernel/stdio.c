#include <stdio.h>
#include <io.h>
#include <stdint.h>

static int x;
static int y;
static volatile unsigned char *video = (char*) VIDEO;

void gotoxy(int _x,int _y);

static void scroll() { //滚动屏幕
    uint16_t blank = 0x20 | (ATTRIBUTE << 8);

    if (y >= LINE) {
        int i;
        for (i = 0;i < 24 * 80;i++) {
            video[i] = video[i+80];
        }
        for (i = 24*80;i<25*80;i++) { //最后一行填充空格
            video[i] = blank;
        }
        y = 25;
    }
}
void log_info (char *str) {
    putchar('[',7);
    putstr ("INFO",2);
    putchar(']',7);
    putstr (str,7);

}
void putstr (char *str,int attr) {
    while (*str) {
        putchar (*str++,attr);
    }
}
void gotoxy (int _x,int _y) {
    uint16_t cursor = _y * 80 + _x;

    outb (0x3d4, 14);
    outb (0x3d5, cursor >> 8); //设置光标高8位
    outb (0x3d4, 15);
    outb (0x3d5, cursor);      //设置光标低8位

    
}

void putchar(int chr,uint8_t attr) { //打印一个字符
    if (chr == '\n' || chr == '\r') { //转行
        newline:
            x = 0;
            y++;
            scroll();
            gotoxy(x,y);
            return;
    }
    *(video + (x + y * COLUMN) *2) = chr & 0xff;
    *(video + (x + y * COLUMN) * 2 + 1) = attr;

    gotoxy(++x,y);
    if ( x >= COLUMN) goto newline;
}
void itoa (char *buf, int base, int d) { //整数转字符串
    char *p = buf;
    char *p1,*p2;
    unsigned long ud = d;
    int divisor = 10;

    if (base == 'd' && d < 0) { //如果是负数
        *p++ = '-';
        buf++;
        ud = -d;
    } else if (base == 'x') { //16进制
        divisor = 16;
    }

    do {
        int remainder = ud % divisor;
        *p++ = (remainder < 10) ? remainder + '0' : remainder + 'a' - 10;
    } while ( ud /= divisor);

    *p = 0;

    p1 = buf;
    p2 = p - 1;
    while (p1 < p2){
        char tmp = *p1;
        *p1 = *p2;
        *p2 = tmp;
        p1++;
        p2--;
    }
    
    
}
void printf (const char *format, ...) {
    char **arg = (char **) &format;
    int c;
    char buf[20];

    arg++;

    while ((c = *format++) != 0) {
        if (c != '%') putchar (c,ATTRIBUTE);
        else {
            char *p,*p2;
            int pad0 = 0,pad = 0;

            c = *format++;
            if (c == '0') {
                pad0 = 1;
                c = *format++;
            }

            if (c >= '0' && c <= '9') {
                pad = c - '0';
                c = *format++;
            }

            switch (c) {
                case 'd':
                case 'u':
                case 'x':
                    itoa(buf,c,*((int *) arg++));
                    p = buf;
                    goto string;
                    break;
                case 's':
                    p = *arg++;
                    if (!p) p = "nul";
                string:
                    for (p2 = p;*p2;p2++);
                    for (;p2 < p + pad; p2++) putchar (pad0 ? '0' : ' ',ATTRIBUTE);
                    while (*p) putchar(*p++,ATTRIBUTE);
                    break;
                default:
                    putchar (*((int *) arg++),ATTRIBUTE);
                    break;
            }
        }
    }
    
}