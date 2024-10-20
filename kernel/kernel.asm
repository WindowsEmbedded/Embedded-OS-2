;org 0xc200
;org 0x3500
bootinfo equ 7e0h
jmp near start
;testmsg db "hello world",'$'
inputdup times 128 db 0
welcomemsg db "Welcome to Embedded OS v0.1",0dh,0ah,0
prompt db 'X>',0
unknownmsg db "Unknown command",0dh,0ah,0
vercmdmsg db "v0.1",0dh,0ah,0
dirmsg db 'Directory of  :\ ',0dh,0ah,0
isdir db '<DIR>',0

drivetmp dw 0
fileinfoseg db 0ah,60h

vercom db "ver"
clscom db "cls"
echocom db "echo"
shutdowncom db "shutdown"
rebootcom db "reboot" 
dircom db "dir"
start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x3500
	
	mov si,welcomemsg
	call print
	
	mov ax,bootinfo
	mov es,ax
	mov al,[es:0]
	mov [drivetmp],al
	mov [prompt],al
	mov al,[es:1]
	mov [drivetmp+1],al
	
putstart:	
	call newline
	mov si,prompt
	call print
	mov si,0
usrinput:
	mov ah,0
	int 16h ;输入一个字符
	cmp al,08h ;退格键
	je .backspace
	mov ah,0eh
	int 10h ;然后把输入的字符显示出来
	
	cmp al,0dh
	je .over ;回车键输入结束
	
	
	mov [inputdup+si],al
	inc si
	
	jmp usrinput
.backspace: ;退格
	cmp si,0
	je usrinput
	dec si
	mov word[inputdup+si],' ' ;删除字符
	mov al,08h
	mov ah,0eh
	int 10h
	mov al,' '
	int 10h
	mov al,08h
	int 10h
	jmp usrinput
	
.over:
	cmp byte[inputdup],0 ;判断是否输入
	je .noneinput
	call cmdswitch
	;call cleandup
	jmp putstart
.noneinput:
	call newline
	jmp putstart
print:
	mov al,[si]
	cmp al,0
	je .end
	mov ah,0eh
	int 10h
	inc si ;;si指向下一个字符
	jmp print
	call .end
.end:
	ret
newline:
	;新行
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	ret
cmdswitch:
	mov si,0
	mov cx,3
.nextcom1:
	mov ah,[vercom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .nextcom2
	inc si
	loop .nextcom1
	jmp .ver
.nextcom2:
	mov si,0
	mov cx,3
.nextcom2s:
	mov ah,[clscom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .nextcom3
	inc si
	loop .nextcom2s
	jmp .echo
.nextcom3:
	mov si,0
	mov cx,4
.nextcom3s:
	mov ah,[echocom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .nextcom4
	inc si
	loop .nextcom3s
	jmp .echo
.nextcom4:
	mov si,0
	mov cx,8
.nextcom4s:
	mov ah,[shutdowncom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .nextcom5
	inc si
	loop .nextcom4s
	jmp .shutdown
.nextcom5:
	mov si,0
	mov cx,6
.nextcom5s:
	mov ah,[rebootcom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .nextcom6
	inc si
	loop .nextcom5s
	jmp 0ffffh:0000h ;回到bios
.nextcom6:
	mov si,0
	mov cx,3
.nextcom6s:
	mov ah,[dircom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .unknowncmd
	inc si
	loop .nextcom6s
	jmp .dir
.unknowncmd:
	call newline
	mov si,unknownmsg
	call print
	jmp .dealover
.ver: ;显示版本
	call newline
	mov si,vercmdmsg
	call print
	jmp .dealover
.cls: ;清屏
	mov ah,00h
	mov al,03h
	int 10h
	jmp .dealover
.echo:
	call newline
	mov di,5 ;echo加上空格占5字节
.echo.try:
	mov al,[inputdup+di]
	cmp al,0
	je .echo.end
	mov ah,0eh
	int 10h
	inc di
	jmp .echo.try
.echo.end:
	call newline
	jmp .dealover
.shutdown: ;关机
	mov ax,5301h
	xor bx,bx
	int 15h
	
	mov ax,530eh
	mov cx,0102h
	int 15h
	mov ax,5307h
	mov bl,01h
	mov cx,0003h
	int 15h
	
	ret
.dir: 
	call newline
	mov al,[drivetmp]
	mov byte[dirmsg+13],al
	mov si,dirmsg
	call print
	call newline
	mov ah,[fileinfoseg]
	mov al,[fileinfoseg+1]
	mov es,ax
	mov si,0
.dir.try:
	mov cx,12
	call newline
.dir.put:
	mov al,[es:si]
	cmp al,10h
	je .dir.dir ;是文件夹
	mov ah,0eh
	int 10h
	inc si
	loop .dir.put
.dir.lop:
	mov ax,es
	add ax,2h
	mov es,ax
	mov si,0
	mov al,[es:si]
	cmp al,0
	je .dir.end
	cmp al,0xe5 ;如果文件已被删除
	je .dir.lop
	jmp .dir.try
.dir.dir:
	mov si,isdir
	call print
	jmp .dir.lop
.dir.end:
	call newline
	jmp .dealover
.dealover:
	mov si,0
	;mov byte[inputdup],"                                              "
	call cleandup
.end:
	ret

cleandup: ;清空缓冲
	push si
.loop:
	cmp si,128
	je .end
	mov byte[inputdup+si],0
	inc si
	jmp .loop
.end:
	pop si
	ret