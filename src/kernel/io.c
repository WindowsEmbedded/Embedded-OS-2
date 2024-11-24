#include <io.h>

inline void outb (uint16_t port, uint8_t data) { //向port写入一字节
    asm volatile ("outb %b0, %w1" : : "a" (data),"Nd"(port));
}
inline void outsw (uint16_t port, const void* addr, uint32_t word_cnt) { //将addr处起始的word_cnt个字写入端口port
    asm volatile ("cld; rep outsw" : "+S" (addr),"+c" (word_cnt) : "d" (port));
}

inline uint8_t inb (uint16_t port) {
    uint8_t data;
    asm volatile ("inb %w1, %b0" : "=a" (data) : "Nd" (port));
    return data;
}
inline void insw (uint16_t port, void* addr, uint32_t word_cnt) {
    asm volatile ("cld ; rep insw" : "+D" (addr), "+c" (word_cnt) : "d" (port) : "memory");
}