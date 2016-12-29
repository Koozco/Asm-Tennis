.8086

;for 8086

dane segment
	koniecGry db "Koniec Gry! * Game over!", 10, 13, "$"
	paletka dw  ?   ; wiersz gory paletki   
	wspX    dw  ?
	wspY    dw  ?   
	tmpX    dw  ?
	tmpY    dw  ?
	kolor   db  ?      
	vX      dw  ?
	vY      dw  ?   
	pilkaX  dw  ?
	pilkaY  dw  ?    
	iloczyn dw  ?
	gora    dw  ?
	dol     dw  ?
dane ends

stos segment stack
   	dw   256  dup(0)
stos ends

code segment
assume cs:code, ds:dane, ss:stos

koloruj:    
	push ax  
	push bx                 
	mov	ax, word ptr ds:[wspY]
	mov	bx, 320
	mul	bx    ; y*320
	mov di, ax 
	add	di, word ptr ds:[wspX]
	mov iloczyn, di
	mov	al, byte ptr ds:[kolor]
	mov	byte ptr es:[di], al  
	pop bx
	pop ax
	ret
    
rysujPaletke:
	push cx
	mov  cx, 24
	mov ax, word ptr ds:[paletka]
	it:  
	mov word ptr ds:[wspY], ax
	mov byte ptr ds:[kolor], 0Fh
	mov word ptr ds:[wspX], 1
	call koloruj            
	mov word ptr ds:[wspX], 2
	call koloruj             
	mov word ptr ds:[wspX], 3
	call koloruj
	inc ax     
	loop it  
	pop cx   
	ret    
      
rysujPilke:  
	mov byte ptr ds:[kolor], 0Ch
	push cx  
	mov ax, word ptr ds:[pilkaY]
	mov word ptr ds:[tmpY], ax
	mov ax, word ptr ds:[pilkaX]
	mov word ptr ds:[tmpX], ax
	mov cx, 3    
	col:        
	push cx
	mov cx, 3
	row:                
	mov ax, word ptr ds:[tmpY]
	mov word ptr ds:[wspY], ax
	mov ax, word ptr ds:[tmpX]
	mov word ptr ds:[wspX], ax
	add ax, 1
	mov word ptr ds:[tmpX], ax
	call koloruj
	loop row
	mov ax, word ptr ds:[tmpY]
	add ax, 1
	mov word ptr ds:[tmpY], ax
	mov ax, word ptr ds:[pilkaX]
	mov word ptr ds:[tmpX], ax
	pop cx
	loop col 
	pop cx  
	ret   
    
czekaj:
	xor cx, cx
	mov ah, 86h
	mov dx, 15000
	int 15h       
	ret
	
klawisz:
	xor ax, ax
	mov ah, 01h
	int 16h
	jz koniecKlawisz
	xor ax, ax
	int 16h 
	cmp ah, 01h ; escape
	je escape
	cmp ah, 048h ; up
	je  wGore
	cmp ah, 050h ; down
	je  wDol	
	koniecKlawisz:
	jmp rysuj
	escape:
	jmp koniec    
	
wGore:
	mov ax, word ptr ds:[paletka]
	sub ax, 3
	mov word ptr ds:[paletka], ax
	cmp ax, 0
	jg  rysowanie
	mov ax, 0
	mov word ptr ds:[paletka], ax
	jmp rysuj
wDol:                            
	mov ax, word ptr ds:[paletka]
	add ax, 3
	mov word ptr ds:[paletka], ax
	cmp ax, 176
	jl rysowanie
	mov ax, 176
	mov word ptr ds:[paletka], ax
	rysowanie:
    	jmp rysuj

wyczysc:
	mov cx, 0
	mov bx, 0
	mov dx, 63999
	mov ah, 06h
	mov al, 0
	int 10h
	ret	     
	
ruch:                 
	mov ax, word ptr ds:[pilkaX]
	add ax, vX
	mov word ptr ds:[pilkaX], ax 
	mov ax,  word ptr ds:[pilkaY]
	add ax, vY
	mov word ptr ds:[pilkaY], ax
	mov ax, word ptr ds:[pilkaX]
	cmp ax, 3
	je  granica
	cmp ax, 318
	jne  bezZmianyX
	call zmienX
	bezZmianyX:
	mov ax, word ptr ds:[pilkaY]
	cmp ax, 0
	jne  bezZmianyY
	call zmienY
	bezZmianyY:
	cmp ax, 198
	jne koniecRuchu
	call zmienY
	jmp koniecRuchu   
    
	zmienY:  
	mov bx, -1
	mov ax, word ptr ds:[vY]
	mul bx
	mov word ptr ds:[vY], ax   
	ret
	zmienX:         
	mov bx, -1
	mov ax, word ptr ds:[vX]
	mul bx
	mov word ptr ds:[vX], ax
	ret

	koniecRuchu:
	ret  
          
granica:
	mov ax, word ptr ds:[paletka]                
	sub ax, 2
	cmp ax, word ptr ds:[pilkaY]
	jg  koniec    
	mov ax, word ptr ds:[paletka] 
	add ax, 26 
	cmp ax, word ptr ds:[pilkaY]
	jl  koniec
	mov ax, word ptr ds:[paletka]
	add ax, 12
	cmp ax, word ptr ds:[pilkaY]
	jg  odbicieGora
	mov word ptr ds:[vY], 1
	jmp zmienX
	odbiciegora:
	mov word ptr ds:[vY], -1
	jmp zmienX
             
koniec:
	mov ax, 03h
	int 10h
	mov dx, offset koniecGry
	mov ah, 9
	int 21h
	mov ax,04c00h
	int 21h
                                                   
           
start:         
	mov ax, dane
	mov ds, ax

	;tryb graficzny
	mov ax, 13h
	int 10h  
	mov ax, 0a000h
	mov es, ax

	;inicjalizacja      
	mov vX, -1
	mov vY, -1
	mov kolor, 0Fh   
	mov pilkaX, 300
	mov pilkaY, 50
	mov paletka, 4          
		 
	glowna:
	call czekaj
	jmp klawisz
	rysuj:
	call ruch
	call wyczysc
	call rysujPaletke
	call rysujPilke  
	jmp glowna                        
                           
code ends

end start 
