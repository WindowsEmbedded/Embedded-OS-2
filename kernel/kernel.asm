;org 0xc200
;org 0x3500
jmp near start
;testmsg db "hello world",'$'
inputdup times 128 db 0
welcomemsg db "Welcome to Embedded OS v0.2",0dh,0ah,0
prompt db ">>>",0
unknownmsg db "Unknown command",0dh,0ah,0
vercmdmsg db "v0.1",0dh,0ah,0

vercom db "ver"
clscom db "cls"
echocom db "echo"
start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x3500
	
	mov si,welcomemsg
	call print
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
	cmp byte[inputdup],"                                               " ;判断是否输入
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
	jne .unknowncmd
	inc si
	loop .nextcom3s
	jmp .echo
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