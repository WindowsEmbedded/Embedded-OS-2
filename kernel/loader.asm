;loader.asm
;org 0xc200
jmp near start  

kernelbin db "KERNEL  BIN"
msg       db 0dh,0ah,"ERR:Couldn't find kernel.bin",0
startmsg  db 0dh,0ah,"Starting EmbeddedOS...",0
kernelseg equ 0x3500

start:
    mov ax,cs 
    mov ds,ax
    mov es,ax
	
	mov si,startmsg
	call print

    mov si,kernelbin
    call findkrn
    cmp ah,0 ;AH=0没找到文件
    jne jmpkrn

    mov si,msg
    call print 
    jmp $
findkrn: ;寻找kernel.bin
    mov ax,0a60h
    mov es,ax
    sub di,di ;清空di
    mov cx,11
.loop:
    mov ah,[si]
    mov al,[es:di]
    cmp ah,al
    jne .next
    inc si
    inc di
    loop .loop
    mov ah,1 ;AH=1找到文件
    ret
.next:
    mov ax,es
    add ax,2h
    mov es,ax
    sub di,di
    mov al,[es:di]
    cmp al,0
    je .end
    mov cx,11 ;再找一次
    jmp .loop
.end:
    mov ah,0
    ret
jmpkrn:
    mov ax,es
    add ax,1h 
    mov es,ax
    mov cx,[es:10]
    mov ax,0
.mul:
    add ax,20h
    loop .mul
    add ax,0be0h

    mov ds,ax
    mov si,0
    mov ax,kernelseg
    mov es,ax
    mov di,0
    mov cx,0xffff
    call memcpy
    jmp dword kernelseg:0 ;跳转到kernel
print:
    mov al,[si]
    cmp al,0
    je .ret
    mov ah,0eh
    int 10h
    inc si
    jmp print
.ret:
    ret
memcpy:
    mov al,[ds:si]
    mov [es:di],al
    inc si
    inc di
    loop memcpy
.memcpyend:
    ret


