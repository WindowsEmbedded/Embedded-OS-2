;loader.asm
;org 0x3500
jmp  near start  

;kernelbin db "KERNEL  BIN"
;msg       db 0dh,0ah,"ERR:Couldn't find kernel.bin",0
startmsg  db 0dh,0ah,"Starting EmbeddedOS...",0dh,0ah,0
;kernelseg equ 0x3500
loaderseg db 0,0,0,0
[section .gdt]
;定义gdt描述符
gdt_start:

gdt_null:               ; the mandatory null descriptor
  dd 0x00               
  dd 0x00   

gdt_code:               ;   the code segment descriptor
  dw 0xfff              
  dw 0x0                
  db 0x00               
  db 10011010b          
  db 11001111b          
  db 0x0                

gdt_data:               ; the data segment descriptor
  dw 0xfff              ; Limit (bits 0-15)
  dw 0x0                ; Base  (bits 0-15)
  db 0x00               ; Base  (bits 16-23)
  db 10010010b          ; 1st flags, type flags
  db 11001111b          ; 2nd flags, Limit(bits 16-19)
  db 0x0                ; Base (bits 24-31)

gdt_end:                
                    
; GDT descriptor
gdt_descriptor:
  dw gdt_end -gdt_start -1    ; Size of our GDT, always less one of the true size
  dd gdt_start                ; Start address of our GDT

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
	
	


;ards_buf times 244 db 0
;ards_nr dw 0
[section .text]
;[bits 16]



start:
    mov ax,cs 
	;mov byte[loaderseg+2],al
	;mov byte[loaderseg+3],ah
    mov ds,ax
    mov es,ax
	
	mov si,startmsg
	call print

.enterprotectmode: ;进入保护模式
    ;1 开启a20gate
    in al,0x92
    or al,0000_0010b
    out 0x92,al

    ;2.禁用中断
    cli
    
	;3. 加载gdt并进入保护模式
	lgdt [gdt_descriptor]
	
	mov eax,cr0
	or eax,0x1
	mov cr0,eax
	

	;刷新16位保护模式的流水线和缓存
	jmp dword CODE_SEG:inpmode
	;jmp $

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

[bits 32]
inpmode:
	mov ax, DATA_SEG
	mov ds,ax
	mov es,ax
	mov ss,ax
	;mov ax,SELECTOR_DISP
	;mov gs,ax
	;mov byte[gs:0x00],'s'
	
	jmp $


