#include <stdio.h>
#include <log.h>
#include <drivers/serial.h>
void info(char *str) {
    
    putstr ("[info] ",2);
    putstr (str,7);
   // 
    //putchar ('\n',7);
    
        
    serial_putstr("\033[32m[info]\033[0m ");
    serial_putstr(str);//serial_putchar('\n');
    
}
void fatal(char *str) {
    
    putstr ("[fatal] ",4);
    putstr (str,7);
    //putchar ('\n',7);
}