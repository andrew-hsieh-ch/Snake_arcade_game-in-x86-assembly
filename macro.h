PrintChar macro chr  ;輸出字元
          mov ah,02h
          mov dl,chr
          int 21h
          endm

PrintStr macro string ;輸出字串
         mov ah,09h
         mov dx,offset string
         int 21h
         endm

GetChar macro         ;等待輸入
        mov ah,10h
        int 16h
        endm

SetMode macro mode    ;設定顯示模式
        mov ah,00h
        mov al,mode
        int 10h
        endm

SetColor macro color  ;設定背景色
         mov ah,0bh 
         mov bh,00h
         mov bl,color  
         int 10h
         endm

WrPixel macro col,row,color  ;寫入像點
        mov ah,0ch
        mov bh,00h
        mov al,color
        mov cx,col
        mov dx,row
        int 10h
        endm

SetCursor macro row,col  ;設定游標位置
          mov dh,row
          mov dl,col
          mov bx,00h
          mov ah,02h
          int 10h
          endm

SetChar	macro Char,type,times  ;寫入字元及屬性
	mov ah,09h
	mov al,Char
	mov bh,0
	mov bl,type
	mov cx,times
	int 10h
	endm

printstr13h macro str,atr,len,row,col,cursor_move  ;繪圖模式輸出字串
	    mov ax,ds
	    mov es,ax
            mov bp,offset str
	    mov ah,13h
	    mov al,cursor_move
            mov bh,00
	    mov bl,atr	    
            mov cx,len
	    mov dh,row
	    mov dl,col
	    int 10h
	    endm

MUS_RESET macro		;滑鼠重置		 	
	  mov ax,0000h
	  int 33h
	  endm

MUS_SHOW macro		;顯示滑鼠游標 
	 mov ax,0001h
	 int 33h
	 endm
			
MUS_HIND macro 		;隱藏滑鼠游標
	 mov ax,0002h
	 int 33h
	 endm
			
MUS_GET03 macro 	;取得滑鼠狀態與游標位置
	  mov ax,0003h
	  int 33h
	  endm
SET_MUS	macro	Col,Row	;設定滑鼠游標位置
	mov ax,0004h
	mov dx,Row
	mov cx,Col
	int 33h
	endm

MUS_range_x macro max,min	;設定滑鼠水平游標的範圍
	    mov ax,0007h
            mov dx,max
	    mov cx,min
	    int 33h
            endm

MUS_range_y macro max,min	;設定滑鼠垂直游標的範圍
       	    mov ax,0008h
	    mov dx,max
	    mov cx,min
            int 33h
	    endm
