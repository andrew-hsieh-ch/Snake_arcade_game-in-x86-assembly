.model small
.386                 ; �g���D,�@��9�����d     

up      equ 1
down    equ 2
left    equ 4        ; �ΨӧP�_��V
right   equ 8

leng_0  equ 6
leng_1  equ 12       ; �Ψӳ]�w�C�Y�@�ӭ������D������
leng_2  equ 24
leng_3  equ 48       ; �ȷU��,�D���U��
leng_4  equ 75
leng_5  equ 100
leng_6  equ 150
leng_7  equ 200
leng_8  equ 255

dly01   equ 2000h    ; �D���ҩl�t��,�ȷU�C�t�׷U��
dly02   equ 50h      ; �Y�@�ӭ���,�t�ץ[�֪���,�ȷU���t�׷U��
dly03   equ 100h     ; �C�}9���A�t�ץ[�֪���,�ȷU���t�׷U��

.code
.startup

        push ds
        pop es
        mov stage,1        ; �ثe�O�Ĥ@��
brake:  lea si,num_01       ; si ���V�Ĥ@���a��

new_sta:push si
        mov al,stage
        push ax
        mov lengh,leng_0    ; �]�w�ҩl�D������
        mov direction,right 

        mov cx,25*80
        lea dx,num_09
        cmp dx,si
        jnz no_brk          ; �٨S�}��9��,�h���D
        pop ax
        pop si
        jmp brake           ; �}9���A�h���D�q�Ĥ@�}�l

no_brk: xor di,di			; ���_���M��
        call set2           ; �L�X���d�a��

        mov snake,11*80+40  ; �]�w�ҩl�y�� y=11 , x=40 ,�]�w�ҩl��m�D���Ϊ�

        call food0          ; ��ܭ���
again:  call snaked         ; ��ܳD��
        mov cx,speed
        call delay0         ; delay �@�q�ɶ�
        call read0          ; Ū������A�]�w�樫��V
        jc  exit0
        call walk0          ; ���e���@�B,�p�G����μ���ۤv�h���}
        jc  exit0           ; �p�G�Y�쭹���A�h���D���ץ[��,�A��ܷs������
        pop ax
        push ax
        cmp al,stage
        jz  again           ; �p�G�٨S�L���A�h���� again
        pop ax
        pop si
        add si,25*80        ; si ���V�U�@���a��
        xor ax,ax
        mov snake+2,ax     ; �M���D�� snake �Ҧ��y��

        jmp new_sta

exit0:  .exit


walk0:  push di
        push ax
        push si
        push cx
        push bx
        call del_end        ; �ˬd�D�����ײŦX��A���e���@�B���e�A���ڭn���h���@��

        cld
        mov cx,1800
        lea si,snake
        lea di,so_buf       ; �ǳƱN�D���y�Цs�J so_buf
re_mos: movsw
        mov ax,[si-2]
        or  ax,ax
        jz  move_ok
        loop re_mos         ; �N�D���y�Цs�J so_buf ���j��
        jmp move_o2
move_ok:mov cx,1            ; �O�_�������A�O�_���쨭�����
        loop re_mos
move_o2:
        mov ax,so_buf       ; ���X�ثe�Y���y�� => di
        mov di,ax
        and di,7fffh        ; �h���ΨӪ�ܳD�����W�ΤU�b�����줸�A�̰��줸�]0
        mov bl,direction         ; �e�i��V => al
        cmp bl,up
        jz  wk_up           ; �ˬd�e�i��V�A�i����D
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

wk_end: lea di,snake+2     ; �ǳƱN�D�����b�D�Y���᭱
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

save_os:mov bx,snake      ; ���X�D�Y�s��m�y��
        mov si,bx
        and si,7fffh
        call get_chr       ; ���X�s��m�y�ФW�A�O�_���F��
        or  al,al
        jz  no_thin
        cmp al,20h         ; �p�G�O�ťիh���D
        jz  no_thin
        cmp al,219         
        jz  has_c          ; ��������Φۤv������h���D
        test bx,8000h
        jz  dn_pic
        cmp al,223         ; �W
        jz  has_c          ; ��������Φۤv������h���D
        jmp chk_fo
dn_pic: cmp al,220         ; �U
        jz  has_c          ; ��������Φۤv������h���D
chk_fo: cmp al,31h
        jb  no_thin
        cmp al,39h         ; �p�G���O�����A�h���D
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

        inc stage          ; ���d�]�w���U�@��
        add speed,dly02*8
        sub speed,dly03
        cmp stage,10
        jnz no_thin
        mov stage,1
        jmp no_thin

last_x: call food0			
        sub speed,dly02    ; �t�ץ[��
        jmp no_thin

has_c:  stc					;carry=1
        jmp has_end
no_thin:clc					;�M��carry
has_end:pop bx
        pop cx
        pop si
        pop ax
        pop di
        ret					;aka pop ip

del_end:push di            ; �b�D�e�i�@�B���e�A�n���өI�s���Ƶ{��
        push si            ; �|�ˬd�D�����סA�O�_��ܪ�����
        push ax            ; ���������ܡA�N���|�h������
        push cx            ; �������ܡA�N�|�h�����ڤW���@��
        push bx
        cld
        xor bx,bx          ; bx �k 0 ,�ΨӰO���ثe�D������
        mov cx,1800
        lea si,snake
con05:  lodsw              ; Ū�D���䤤�@�I���y��
        or  ax,ax          ; �p�G�w��D���h���D
        jz  con03
        inc bx             ; �D�����ץ[ 1
        loop con05
con03:  mov cx,1
con04:  loop con05         ; �O���餺���D������ => bx
        cmp bl,lengh       ; ��ܪ��D�����׬O�_�ŦX�]�w������
        jz  del_en0        ; �p�G�O�A�h�h���A���D
        ja  del_en0
        jb  no_del         ; �_�h�D�����ʡA���D���}
        jmp no_del
		
del_en0:lea si,snake      ; �Ѧ���}�l�i��h��
        xor bh,bh
        shl bx,1
        add si,bx
        dec si
        dec si             ; si ���V���ڪ���m
        push si
        lodsw              ; ���X���ڮy�� => ax
        call del_cc        ; �H ax �ҫ����y�СA�i��ù��W���h��
        pop di
        xor ax,ax
        stosw              ; �i��O����W���h��
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
        call get_chr    ; ���X�ù��W���ڪ��Ϯ� => al
        mov bl,al
        cmp bl,219      
        pop ax
        push ax
        jnz erasq       ; �p�G���O���ܡA�N��u���@�b�r���A�i�����R�����ť�00�A�h���D
        test ax,8000h   ; �ˬd�̰��줸�O�_�� 0
        jz  del_dn      ; �O�h���D�R���U�b���A�_�h�R���W�b��
        mov al,220      ; �]�w�D���ϮסA�U�b��
        jmp erasq1
del_dn: mov al,223      ; �]�w�D���ϮסA�W�b��
        jmp erasq1
erasq:  mov al,00
erasq1: mov di,si
        call put_chr    ; �i��ù��W���h��
        pop ax
        pop bx
        pop di
        pop si
        ret

delay0: push cx
delay1: push cx         ; DELAY �@�q�ɶ�
delay2: loop delay2
        pop cx
        loop delay1
        pop cx
        ret

snaked: push bx         ; �� snake ���s�y�Ъ����e�A��ܳD��
        push ax
        push si
        push di
        lea si,snake    ; si ���V�����y��
sna_re: mov ax,[si]     ; ���X�D���y�СA�O�_������ 00
        or  ax,ax
        jz  sna_ov      ; �p�G�O�h���� sna_ov
        push ax
        push si
        and ax,7fffh    ; �̰��줸�] 0
        mov si,ax       ; �y�Эȩ�J si
        mov di,ax       ; �y�Эȩ�J di
        call get_chr    ; �� si �ҫ����y�Ш��X�r�� => AL
        mov bl,al
        pop si
        pop ax
        cmp bl,219      
        jz  sna_bl
        test ax,8000h   ; �ˬd�̰��줸�O�_�� 1�A�p�G�O 1�A�N��ϧά��W�b��
        jnz sna_n1      ; �O�W�b���h���D

                        ; �U
        cmp bl,223      
        jz  sna_up
        cmp bl,220      
        jz  sna_bl
        mov al,220
        jmp sna_oo
sna_n1:                 ; �W
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

food0:  mov al,'1'         ; ��ܭ���
        cmp lengh,leng_0
        jz  foods          ; �H�ثe���D�����סA�ӧP�_�����s��
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
        mov al,30h		;ascii : 0 , �k�s
		
foods:  push ax
foodb:  mov ah,2ch
        int 21h         ; ���X�t�ήɶ�
fooda:  cmp dh,20
        jb  foodx       ; ��Ƥp�� 20�h���D�A�_�h��20
        sub dh,20
        jmp fooda
foodx:  mov al,100
        mul dh          ; ��ƭ��H 100 => ax
        xor dh,dh
        add ax,dx       ; �A�[�W dl �ʤ���A�o�N�O�������w�Ʈy��
        mov di,ax
        call chk_cus    ; �ˬd�Ӯy�СA�O�_�O�Ū��A�p�G���O�h���s���y��
        jnc foodc       ; �p�G�O�Ū��A�N���D
        inc di
        call chk_cus    ; �y�Х[ 1 ����A�A�ˬd�@��
        jnc foodc
        inc di
        call chk_cus    ; �y�Х[ 1 ����A�A�ˬd�@��
        jnc foodc
        add di,158      ; �y�Х[ 158 �ݬO�_�j�� 2000�A�p�G�j��2000�A�N�2000
        cmp di,2000
        jb  foodd
        sub di,2000
foodd:  call chk_cus    ; �A�ˬd�@���y�Ц�m
        jnc foodc
        jc  foodb
foodc:  cmp di,81
        jb  foodb
        cmp di,80*25-1
        jnb foodb
        pop ax
        call put_chr    ; �b di �ҫ���m�A��J al �r���Adi=y*80+x�A�L�X����
        ret

put_chr:push es         ; �b di �ҫ����y�СA��J al �Ȧs���Ҧs����(�r��)
        push di         ; di �ݫ��V�y�� y*80+x
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

get_chr:push ds         ; �b�ù��W si �ҫ����y�СA���X�r���A��J al �Ȧs��
        push si         ; si �ݫ��V�y�� y*80+x
        push ax
        mov ax,0b800h
        mov ds,ax
        shl si,1
        pop ax
        lodsb
        pop si
        pop ds
        ret

chk_cus:push es         ; �ˬd di �ҫ����y�СA�O�_���Ū� '00' �� 20H
        push di
        push ax         ; di �ݫ��V�y�� y*80+x
        mov ax,0b800h
        mov es,ax       ; �p�G�O�Ū��A�h C �X�з|�Q�M���A�_�h c=1
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
        mov ah,01       ; Ū������
        int 16h
        jz  next0		; �S����
        xor ax,ax
        int 16h			; ������
        cmp ah,01h      ; Esc
        jz  next4
        cmp ah,44h      ; ���U F10 �i����
        jz  nex_st
        cmp ah,4eh      ; �� + �h�[�t
        jz  spd_add
        cmp ah,4ah      ; �� - �h��t
        jz  spd_sub
        cmp ah,48h      ; �W
        jnz next1
        cmp direction,up
        jz  next0
        cmp direction,down ;�n�A����@�����ઽ��mov, ���M�|�첾
        jz  next0
        mov direction,up
        jmp next0
next1:  cmp ah,50h      ; �U
        jnz next2
        cmp direction,up
        jz  next0
        cmp direction,down
        jz  next0
        mov direction,down
        jmp next0
next2:  cmp ah,4bh      ; ��
        jnz next3
        cmp direction,left
        jz  next0
        cmp direction,right
        jz  next0
        mov direction,left
        jmp next0
next3:  cmp ah,4dh      ; �k
        jnz next0
        cmp direction,left
        jz  next0
        cmp direction,right
        jz  next0
        mov direction,right
next0:  clc
        pop si
        pop ax
        ret					;����Ū����, �F��_��, �^�h�{��
		
		
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

set2    proc            ; di �ݫ��w�y�� y*80+x ��m�����e�Asi �ݫ��V����ܪ��r��
        push si
        push es         ; cx �ݫ��w byte ��
        push ax         ; �Ψӵe���d���a��
        push di
        push cx
        mov ax,0b800h	; print, 0b800h�O�ù��a�}
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