.model small
.386                 ; 貪食蛇,共有9個關卡     

up      equ 1
down    equ 2
left    equ 4        ; 用來判斷方向
right   equ 8

leng_0  equ 6
leng_1  equ 12       ; 用來設定每吃一個食物的蛇身長度
leng_2  equ 24
leng_3  equ 48       ; 值愈高,蛇身愈長
leng_4  equ 75
leng_5  equ 100
leng_6  equ 150
leng_7  equ 200
leng_8  equ 255

dly01   equ 2000h    ; 蛇的啟始速度,值愈低速度愈快
dly02   equ 50h      ; 吃一個食物,速度加快的數,值愈高速度愈快
dly03   equ 100h     ; 每破9關，速度加快的數,值愈高速度愈快

.code
.startup

        push ds
        pop es
        mov stage,1        ; 目前是第一關
brake:  lea si,num_01       ; si 指向第一關地圖

new_sta:push si
        mov al,stage
        push ax
        mov lengh,leng_0    ; 設定啟始蛇身長度
        mov direction,right 

        mov cx,25*80
        lea dx,num_09
        cmp dx,si
        jnz no_brk          ; 還沒破第9關,則跳躍
        pop ax
        pop si
        jmp brake           ; 破9關，則跳躍從第一開始

no_brk: xor di,di			; 神奇的清空
        call set2           ; 印出關卡地圖

        mov snake,11*80+40  ; 設定啟始座標 y=11 , x=40 ,設定啟始位置蛇身形狀

        call food0          ; 顯示食物
again:  call snaked         ; 顯示蛇身
        mov cx,speed
        call delay0         ; delay 一段時間
        call read0          ; 讀取按鍵，設定行走方向
        jc  exit0
        call walk0          ; 往前走一步,如果撞牆或撞到自己則跳開
        jc  exit0           ; 如果吃到食物，則身蛇長度加長,再顯示新的食物
        pop ax
        push ax
        cmp al,stage
        jz  again           ; 如果還沒過關，則跳至 again
        pop ax
        pop si
        add si,25*80        ; si 指向下一關地圖
        xor ax,ax
        mov snake+2,ax     ; 清除蛇身 snake 所有座標

        jmp new_sta

exit0:  .exit


walk0:  push di
        push ax
        push si
        push cx
        push bx
        call del_end        ; 檢查蛇身長度符合後，往前走一步之前，尾巴要先去掉一格

        cld
        mov cx,1800
        lea si,snake
        lea di,so_buf       ; 準備將蛇身座標存入 so_buf
re_mos: movsw
        mov ax,[si-2]
        or  ax,ax
        jz  move_ok
        loop re_mos         ; 將蛇身座標存入 so_buf 的迴圈
        jmp move_o2
move_ok:mov cx,1            ; 是否有食物，是否撞到身體或牆
        loop re_mos
move_o2:
        mov ax,so_buf       ; 取出目前頭部座標 => di
        mov di,ax
        and di,7fffh        ; 去除用來表示蛇身為上或下半部的位元，最高位元設0
        mov bl,direction         ; 前進方向 => al
        cmp bl,up
        jz  wk_up           ; 檢查前進方向，進行跳躍
        cmp bl,down
        jz  wk_dn
        cmp bl,left
        jz  wk_lf
        jmp wk_rg

wk_up:  test ax,8000h       
        jz  wk_up1
        sub di,80           
        mov snake,di       
        jmp wk_end
wk_up1: or  ax,8000h       
        mov snake,ax       
        jmp wk_end

wk_dn:  test ax,8000h
        jz  wk_dn1
        mov snake,di
        jmp wk_end
wk_dn1: add ax,80
        or  ax,8000h
        mov snake,ax
        jmp wk_end

wk_lf:  sub ax,1
        mov snake,ax
        jmp wk_end

wk_rg:  add ax,1
        mov snake,ax
        jmp wk_end

wk_end: lea di,snake+2     ; 準備將蛇身接在蛇頭的後面
        lea si,so_buf
        mov cx,1800
        cld
re_save:movsw
        mov ax,[si-2]
        or  ax,ax
        jz  save_ok
        loop re_save
        jmp save_os
save_ok:mov cx,1
        loop re_save

save_os:mov bx,snake      ; 取出蛇頭新位置座標
        mov si,bx
        and si,7fffh
        call get_chr       ; 取出新位置座標上，是否有東西
        or  al,al
        jz  no_thin
        cmp al,20h         ; 如果是空白則跳躍
        jz  no_thin
        cmp al,219         
        jz  has_c          ; 撞到牆壁或自己的身體則跳躍
        test bx,8000h
        jz  dn_pic
        cmp al,223         ; 上
        jz  has_c          ; 撞到牆壁或自己的身體則跳躍
        jmp chk_fo
dn_pic: cmp al,220         ; 下
        jz  has_c          ; 撞到牆壁或自己的身體則跳躍
chk_fo: cmp al,31h
        jb  no_thin
        cmp al,39h         ; 如果不是食物，則跳躍
        ja  no_thin

        cmp al,31h
        jnz last_1
        mov lengh,leng_1
        jmp last_x
last_1: cmp al,32h
        jnz last_2
        mov lengh,leng_2
        jmp last_x
last_2: cmp al,33h
        jnz last_3
        mov lengh,leng_3
        jmp last_x
last_3: cmp al,34h
        jnz last_4
        mov lengh,leng_4
        jmp last_x
last_4: cmp al,35h
        jnz last_5
        mov lengh,leng_5
        jmp last_x
last_5: cmp al,36h
        jnz last_6
        mov lengh,leng_6
        jmp last_x
last_6: cmp al,37h
        jnz last_7
        mov lengh,leng_7
        jmp last_x
last_7: cmp al,38h
        jnz last_8
        mov lengh,leng_8
        jmp last_x
last_8: cmp al,39h
        jnz no_thin

        inc stage          ; 關卡設定為下一關
        add speed,dly02*8
        sub speed,dly03
        cmp stage,10
        jnz no_thin
        mov stage,1
        jmp no_thin

last_x: call food0			
        sub speed,dly02    ; 速度加快
        jmp no_thin

has_c:  stc					;carry=1
        jmp has_end
no_thin:clc					;清除carry
has_end:pop bx
        pop cx
        pop si
        pop ax
        pop di
        ret					;aka pop ip

del_end:push di            ; 在蛇前進一步之前，要先來呼叫此副程式
        push si            ; 會檢查蛇身長度，是否顯示的夠長
        push ax            ; 不夠長的話，就不會去除尾巴
        push cx            ; 夠長的話，就會去除尾巴上的一格
        push bx
        cld
        xor bx,bx          ; bx 歸 0 ,用來記錄目前蛇身長度
        mov cx,1800
        lea si,snake
con05:  lodsw              ; 讀蛇身其中一點的座標
        or  ax,ax          ; 如果已到蛇尾則跳躍
        jz  con03
        inc bx             ; 蛇身長度加 1
        loop con05
con03:  mov cx,1
con04:  loop con05         ; 記憶體內的蛇身長度 => bx
        cmp bl,lengh       ; 顯示的蛇身長度是否符合設定的長度
        jz  del_en0        ; 如果是，則去尾，跳躍
        ja  del_en0
        jb  no_del         ; 否則蛇尾不動，跳躍離開
        jmp no_del
		
del_en0:lea si,snake      ; 由此行開始進行去尾
        xor bh,bh
        shl bx,1
        add si,bx
        dec si
        dec si             ; si 指向尾巴的位置
        push si
        lodsw              ; 取出尾巴座標 => ax
        call del_cc        ; 以 ax 所指的座標，進行螢幕上的去尾
        pop di
        xor ax,ax
        stosw              ; 進行記憶體上的去尾
no_del: pop bx
        pop cx
        pop ax
        pop si
        pop di
        ret

del_cc: push si
        push di
        push bx
        push ax
        and ax,7fffh    
        mov si,ax       
        call get_chr    ; 取出螢幕上尾巴的圖案 => al
        mov bl,al
        cmp bl,219      
        pop ax
        push ax
        jnz erasq       ; 如果不是的話，代表只有一半字元，可直接刪除為空白00，則跳躍
        test ax,8000h   ; 檢查最高位元是否為 0
        jz  del_dn      ; 是則跳躍刪除下半部，否則刪除上半部
        mov al,220      ; 設定蛇尾圖案，下半部
        jmp erasq1
del_dn: mov al,223      ; 設定蛇尾圖案，上半部
        jmp erasq1
erasq:  mov al,00
erasq1: mov di,si
        call put_chr    ; 進行螢幕上的去尾
        pop ax
        pop bx
        pop di
        pop si
        ret

delay0: push cx
delay1: push cx         ; DELAY 一段時間
delay2: loop delay2
        pop cx
        loop delay1
        pop cx
        ret

snaked: push bx         ; 依 snake 內存座標的內容，顯示蛇身
        push ax
        push si
        push di
        lea si,snake    ; si 指向食物座標
sna_re: mov ax,[si]     ; 取出蛇身座標，是否為尾端 00
        or  ax,ax
        jz  sna_ov      ; 如果是則跳至 sna_ov
        push ax
        push si
        and ax,7fffh    ; 最高位元設 0
        mov si,ax       ; 座標值放入 si
        mov di,ax       ; 座標值放入 di
        call get_chr    ; 自 si 所指的座標取出字元 => AL
        mov bl,al
        pop si
        pop ax
        cmp bl,219      
        jz  sna_bl
        test ax,8000h   ; 檢查最高位元是否為 1，如果是 1，代表圖形為上半部
        jnz sna_n1      ; 是上半部則跳躍

                        ; 下
        cmp bl,223      
        jz  sna_up
        cmp bl,220      
        jz  sna_bl
        mov al,220
        jmp sna_oo
sna_n1:                 ; 上
        cmp bl,220     
        jz  sna_up
        cmp bl,223      
        jz  sna_bl
        mov al,223
        jmp sna_oo
sna_up: mov al,219
        jmp sna_oo
sna_bl: mov al,bl
sna_oo: call put_chr
        inc si
        inc si
        jmp sna_re
sna_ov: pop di
        pop si
        pop ax
        pop bx
        ret

food0:  mov al,'1'         ; 顯示食物
        cmp lengh,leng_0
        jz  foods          ; 以目前的蛇身長度，來判斷食物編號
        inc al
        cmp lengh,leng_1
        jz  foods
        inc al
        cmp lengh,leng_2
        jz  foods
        inc al
        cmp lengh,leng_3
        jz  foods
        inc al
        cmp lengh,leng_4
        jz  foods
        inc al
        cmp lengh,leng_5
        jz  foods
        inc al
        cmp lengh,leng_6
        jz  foods
        inc al
        cmp lengh,leng_7
        jz  foods
        inc al
        cmp lengh,leng_8
        jz  foods
        mov al,30h		;ascii : 0 , 歸零
		
foods:  push ax
foodb:  mov ah,2ch
        int 21h         ; 取出系統時間
fooda:  cmp dh,20
        jb  foodx       ; 秒數小於 20則跳躍，否則減20
        sub dh,20
        jmp fooda
foodx:  mov al,100
        mul dh          ; 秒數乘以 100 => ax
        xor dh,dh
        add ax,dx       ; 再加上 dl 百分秒，這就是食物的預備座標
        mov di,ax
        call chk_cus    ; 檢查該座標，是否是空的，如果不是則重新取座標
        jnc foodc       ; 如果是空的，就跳躍
        inc di
        call chk_cus    ; 座標加 1 之後，再檢查一次
        jnc foodc
        inc di
        call chk_cus    ; 座標加 1 之後，再檢查一次
        jnc foodc
        add di,158      ; 座標加 158 看是否大於 2000，如果大於2000，就減掉2000
        cmp di,2000
        jb  foodd
        sub di,2000
foodd:  call chk_cus    ; 再檢查一次座標位置
        jnc foodc
        jc  foodb
foodc:  cmp di,81
        jb  foodb
        cmp di,80*25-1
        jnb foodb
        pop ax
        call put_chr    ; 在 di 所指位置，放入 al 字元，di=y*80+x，印出食物
        ret

put_chr:push es         ; 在 di 所指的座標，放入 al 暫存器所存的值(字元)
        push di         ; di 需指向座標 y*80+x
        push ax
        push ax
        mov ax,0b800h
        mov es,ax
        shl di,1
        pop ax
        stosb
        mov al,07h
        stosb
        pop ax
        pop di
        pop es
        ret

get_chr:push ds         ; 在螢幕上 si 所指的座標，取出字元，放入 al 暫存器
        push si         ; si 需指向座標 y*80+x
        push ax
        mov ax,0b800h
        mov ds,ax
        shl si,1
        pop ax
        lodsb
        pop si
        pop ds
        ret

chk_cus:push es         ; 檢查 di 所指的座標，是否為空的 '00' 或 20H
        push di
        push ax         ; di 需指向座標 y*80+x
        mov ax,0b800h
        mov es,ax       ; 如果是空的，則 C 旗標會被清除，否則 c=1
        shl di,1
        mov al,00
        scasb
        jz  is_00
        dec di
        mov al,20h
        scasb
        jz  is_00
        stc
        jmp no_00
is_00:  clc
no_00:  pop ax
        pop di
        pop es
        ret

read0:  push ax
        push si
        mov ah,01       ; 讀取按鍵
        int 16h
        jz  next0		; 沒按鍵
        xor ax,ax
        int 16h			; 等按鍵
        cmp ah,01h      ; Esc
        jz  next4
        cmp ah,44h      ; 按下 F10 可跳關
        jz  nex_st
        cmp ah,4eh      ; 按 + 則加速
        jz  spd_add
        cmp ah,4ah      ; 按 - 則減速
        jz  spd_sub
        cmp ah,48h      ; 上
        jnz next1
        cmp direction,up
        jz  next0
        cmp direction,down ;要再比較一次不能直接mov, 不然會位移
        jz  next0
        mov direction,up
        jmp next0
next1:  cmp ah,50h      ; 下
        jnz next2
        cmp direction,up
        jz  next0
        cmp direction,down
        jz  next0
        mov direction,down
        jmp next0
next2:  cmp ah,4bh      ; 左
        jnz next3
        cmp direction,left
        jz  next0
        cmp direction,right
        jz  next0
        mov direction,left
        jmp next0
next3:  cmp ah,4dh      ; 右
        jnz next0
        cmp direction,left
        jz  next0
        cmp direction,right
        jz  next0
        mov direction,right
next0:  clc
        pop si
        pop ax
        ret					;結束讀按鍵, 東西復原, 回去程式
		
		
nex_st: inc stage
        jmp next0
		
next4:  stc
        pop si
        pop ax
        ret
spd_add:sub speed,dly02
        jmp next0
spd_sub:add speed,dly02
        jmp next0

set2    proc            ; di 需指定座標 y*80+x 位置的內容，si 需指向欲顯示的字串
        push si
        push es         ; cx 需指定 byte 數
        push ax         ; 用來畫關卡的地圖
        push di
        push cx
        mov ax,0b800h	; print, 0b800h是螢幕地址
        mov es,ax
        shl di,1        ; di=di*2
        mov al,07h
setp2:  movsb
        stosb
        loop setp2
        pop cx
        pop di
        pop ax
        pop es
        pop si
        ret
set2    endp

.data

direction    db  ?
lengh   db  ?
stage   db  ?
snake   dw  1800 dup(0)
so_buf  dw  1800 dup(0)
speed   dw  dly01

num_01  db  ' STAGE 01 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219


		
num_02  db  ' STAGE 02 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_03  db  ' STAGE 03 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
		
num_04	db  ' STAGE 04 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_05  db  ' STAGE 05 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_06  db  ' STAGE 06 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_07  db  ' STAGE 07 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_08  db  ' STAGE 08 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
		
num_09  db  ' STAGE 09 '
        db  219,78 dup(223),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(0),219
        db  219,78 dup(220),219
end									;2019.01.02 Andy