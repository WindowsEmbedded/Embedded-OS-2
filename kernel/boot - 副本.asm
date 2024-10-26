

numsector equ 18 ;最大扇区
numheader equ 1  ;最大磁头
numcylind equ 10 ;最大柱面
bootseg equ 7c0h
bootinfoseg equ 7e0h ;boot信息地址
dataseg	equ			800h		; 软盘10扇区读入的地址          

;  org   0x7c00            


  jmp   entry     
nop  
  db    "EMBEDDED"   
  dw    512             
  db    1               
  dw    1            
  db    2         
  dw    224           
  dw    2880             
  db    0xf0             
  dw    9                 
  dw    18                
  dw    2                 
  dd    0                 
  dd    2880              
  db    0                 
  db    0                 
  db    0x29              
  dd    0xffffffff        
  db    "EMBEDDEDDOS"     
  db    "FAT16   "        
;  resb  18                



entry:
	mov	ax,bootseg
	mov	ds,ax
	mov	ax,dataseg
	mov	es,ax
	
	
	;mov si,testmsg
;	call print
	call floppyload
	call findloader
	
	mov ax,bootinfoseg
	mov es,ax
	mov byte[es:0],'A' ;A盘
	mov byte[es:1],0x00 ;驱动器号

	jmp far [loaderseg] ;跳转到loader
floppyload: ;读软盘
	call read1sector
	mov ax,es
	add ax,20h
	mov es,ax
	;读扇区
	inc byte[sector]
	cmp byte[sector],numsector+1
	jne floppyload
	mov byte[sector],1

	;读磁头
	inc byte[header]
	cmp byte[header],numheader+1
	jne floppyload
	mov byte[header],0

	;读柱面
	inc byte[cylind]
	cmp byte[cylind],numcylind+1
	jne floppyload
	
	ret
read1sector:
	;读一个扇区
	mov ch,[cylind]
	mov dh,[header]
	mov cl,[sector]
	mov di,0
.retry:
	mov ah,02h
	mov al,1
	mov bx,0
	mov dl,00h
	int 13h
	jnc .readok
	inc di
	mov ah,00h
	mov dl,00h
	cmp di,5 ;未成功超过5次就放弃
	jne .retry
.readok:
	ret
findloader: ;寻找loader
	mov ax,0a60h
	mov es,ax
	mov si,0
	mov cx,11
.cmp:
	mov al,[es:si]
	mov ah,[loaderbin+si]
	cmp al,ah
	jne .nextfile
	inc si
	loop .cmp
	mov ax,es
	add ax,1h
	mov es,ax
	mov cx,[es:10]
	sub ax,ax
.mul:
	add ax,20h
	loop .mul
	add ax,0be0h
	mov [loaderseg+2],al
	mov [loaderseg+3],ah
	ret
.nextfile:
	mov ax,es
	add ax,2h
	mov es,ax
	sub si,si
	mov al,[es:si]
	cmp al,0
	je .end
	mov cx,11
	jmp .cmp
.end: ;未找到文件
	call newline
	mov si,msg
	call print
	jmp $
newline:
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	ret

print:
  mov   al, [si]
  add   si, 1      
  cmp   al, 0

  je    .fin
  mov   ah, 0x0e      
  MOV   bx, 15       
  int   10h            
  jmp   print
.fin:
	ret

testmsg db "111111",0
msg:
  db    0x0a, 0x0a     
  db    "ERROR:Couldn't find loader.bin",0
  db    0x0a          
  db    0
loaderseg db 0,0,0,0
loaderbin db "LOADER  BIN"
cylind db 0
header db 0
sector db 1
  times 510-($-$$) db 0 
  db    0x55, 0xaa