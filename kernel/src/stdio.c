#include <stdio.h>


static int x;
static int y;
static volatile unsigned char *video = (char*) VIDEO;

void putchar(int chr) { //打印一个字符
    if (chr == '\n' || chr == '\r') { //转行
        newline:
            x = 0;
            y++;
            if (y >= LINE) {
                y = 0;
            }
            return;
    }
    *(video + (x + y * COLUMN) *2) = chr & 0xff;
    *(video + (x + y * COLUMN) * 2 + 1) = ATTRIBUTE;

    x++;
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
        if (c != '%') putchar (c);
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
                    for (;p2 < p + pad; p2++) putchar (pad0 ? '0' : ' ');
                    while (*p) putchar(*p++);
                    break;
                default:
                    putchar (*((int *) arg++));
                    break;
            }
        }
    }
    
}