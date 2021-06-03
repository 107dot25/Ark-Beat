.386
.model flat,stdcall
option casemap:none
; include section
include windows.inc
include gdi32.inc
include user32.inc
include winmm.inc
include kernel32.inc
includelib user32.lib
includelib gdi32.lib
includelib kernel32.lib
includelib msvcrt.lib
includelib winmm.lib

fopen	proto c:dword,:dword
fgets	proto c:dword,:dword,:dword
fclose  proto c:dword
strcmp	proto c:dword,:dword
strcat  proto c:dword,:dword
strlen	proto c:dword
printf	proto c:dword,:vararg
atoi	proto c:ptr byte
feof    proto c:dword



.data
; intrf(interface):
;	0:start intrf;
;	1:music selection intrf;
;	2:gaming intrf;
;	3:(optional)in-game menu intrf
; end intrf
intrf	dd	2
ItemQueue1  dword   1000 dup(?)
ItemQueue2  dword   1000 dup(?)
filepath1   byte    "1.txt",0
filepath2   byte    "2.txt",0
FirstItem1  dword   0
FirstItem2  dword   0
nowItem     dword   0
buf1	    byte	65535 dup(?)
buf2	    byte	65535 dup(?)
fp1		    dword	?
fp2		    dword	?
mode	    byte	"rb",0	
szout	    byte	65535 dup(?)
refresh	    dword	50
frame       dword   0
charframe1  dword   0
charframe2  dword   0
score       dword   0
Combo       dword   0
ComboFlag   dword   0
ComboState  dword   -1
ItemSize    dword   0
paint_flag  dword   1
hit_frame   dword   3

IDB_BACKGROUND  equ       112
IDI_OBJECT      equ       111
IDI_ICON2       equ       113
IDI_TEXAS0      equ       123
IDI_TEXAS1      equ       124
IDI_TEXAS2      equ       125
IDI_TEXAS3      equ       126
IDI_TEXAS4      equ       127
IDI_TEXAS5      equ       128
IDI_TEXAS6      equ       129
IDI_AMIYA1      equ       130
IDI_AMIYA2      equ       131
IDI_AMIYA3      equ       132
IDI_AMIYA4      equ       133
IDI_AMIYA5      equ       134
IDI_AMIYA6      equ       135
IDI_ICONPer     equ       136
IDI_ICONGre     equ       137
IDI_ICONMis     equ       138

szMusicName		byte    "1.wav", 0 ; max_len is 260 bytes, '\0' included
szOpenFormat	byte    'open "%s" alias music', 0
szPlayMusic		byte    "play music", 0
szQueryTime		byte    "status music position", 0
szPrintNum		byte    "Current Position: %d", 0dh, 0ah, 0



szFailed        byte    "Can't Open the File",0ah,0
szScore         byte    "Score: %d",0ah,"Combo: %d",0
szScore1        byte    "11111",0
szFmt	        byte    '%d',0ah,0
szContent       byte    "this is first window",0
szWindowClass   byte    "New_Window",0
szTitle         byte    "Ark Dash",0
szButton	    byte	"Button",0
szButtonTitle	byte	"&Compare",0
szText	        byte	"Edit",0
szStatic	    byte	"Static",0
sztimertest     byte    "timer",0
sztimertest2    byte    "a%d",0ah,0
sztimertestc    byte    "a%s",0ah,0
szbackground    byte    "background.bmp",0
szobject        byte    "ship.bmp",0
szQueue         byte    "  %d",0ah,0

.data?
bmpbackground   dword   ?
bmpbackgroundf  dword   ?
bmpobject       dword   ?
bmpchar1        dword   ?
icoqueue2       dword   6 dup(?)
icoqueue1        dword   7 dup(?)
icohit          dword   7 dup(?)
szOpenMusic		byte    280 dup(?) ; len(szMusicName):260 + len(szOpenFormat):18 + '\0':1 + 1(reduntant)
szRecvTime		byte    32 dup(?)
recvLen			dword   32
hInstance       dword   ?   ;main process handle
hManinHwnd      dword   ?   ;main window handle


.code
; initQueue : load beatmap file
initQueue  proc
    local max1:dword
    local max2:dword
    push eax
    push edx
    push ebx
    invoke fopen, offset filepath1, offset mode
	mov fp1, eax
	invoke fopen, offset filepath2, offset mode
	mov fp2, eax
	mov esi, 0
	xor eax,eax
	.while eax ==0
		xor ebx,ebx
		mov buf1, bl
		invoke fgets, offset buf1, 1024, fp1
		invoke atoi, offset buf1
		mov ItemQueue1[esi*4], eax
        
		inc esi
		invoke feof, fp1
    .endw
    mov ItemQueue1[esi*4], 0FFFFFFFFH
    mov max1, esi
	mov esi, 0
	xor eax,eax
	.while eax ==0
		xor ebx,ebx
		mov buf2, bl
		invoke fgets, offset buf2, 1024, fp2
		invoke atoi, offset buf2
		mov ItemQueue2[esi*4], eax
        ;mov max2, eax
		inc esi
		invoke feof, fp2
    .endw
    mov ItemQueue2[esi*4], 0FFFFFFFFH
    mov max2, esi
    
    mov ebx, max1
    sub ebx, max2
    .if ebx > 0
        mov eax, max1
        mov ItemSize, eax
    .else
        mov eax, max2
        mov ItemSize, eax
    .endif
    invoke printf,offset szQueue, ItemSize
    pop ebx
    pop edx
    pop eax
    ret
initQueue endp

;start_music : play the music
start_music		proc
	invoke wsprintf, offset szOpenMusic, offset szOpenFormat, offset szMusicName
	invoke	printf, offset sztimertestc, offset szOpenMusic
	invoke mciSendString, offset szOpenMusic, NULL, 0, NULL
	invoke	printf, offset sztimertest2, eax
	invoke mciSendString, offset szPlayMusic, NULL, 0, NULL
	invoke	printf, offset sztimertest2, eax
	ret
start_music		endp

;get_music_pos : get music position
get_music_pos	proc
	invoke mciSendString, offset szQueryTime, offset szRecvTime, 32, NULL ; get time position in milliseconds
	invoke atoi, offset szRecvTime ; convert time string to int -> eax
	ret
get_music_pos	endp

; init_on_create : necessary initializations on create
init_on_create	proc stdcall hWnd:dword
	invoke initQueue

	invoke  CreateWindowEx,NULL,offset szStatic, offset szScore,WS_CHILD or WS_VISIBLE,\
	280,0,80,40,hWnd,110,hInstance,NULL
	;invoke  SetWindowLongA, 
	invoke  LoadImage, hInstance, IDI_OBJECT,IMAGE_ICON,64,64, NULL
	mov bmpobject, eax

	;load amiya
	invoke  LoadImage, hInstance, IDI_AMIYA1,IMAGE_ICON,256,256, NULL
	mov icoqueue2, eax
	invoke  LoadImage, hInstance, IDI_AMIYA2,IMAGE_ICON,256,256,NULL
	mov icoqueue2+20, eax
	invoke  LoadImage, hInstance, IDI_AMIYA3,IMAGE_ICON,256,256,NULL
	mov icoqueue2+16, eax
	invoke  LoadImage, hInstance, IDI_AMIYA4,IMAGE_ICON,256,256,NULL
	mov icoqueue2+12, eax
	invoke  LoadImage, hInstance, IDI_AMIYA5,IMAGE_ICON,256,256,NULL
	mov icoqueue2+8, eax
	invoke  LoadImage, hInstance, IDI_AMIYA6,IMAGE_ICON,256,256,NULL
	mov icoqueue2+4, eax
	;load texas
	invoke  LoadImage, hInstance, IDI_TEXAS0,IMAGE_ICON,256,256, NULL
	mov icoqueue1, eax
	invoke  LoadImage, hInstance, IDI_TEXAS1,IMAGE_ICON,256,256,NULL
	mov icoqueue1+4, eax
	invoke  LoadImage, hInstance, IDI_TEXAS2,IMAGE_ICON,256,256,NULL
	mov icoqueue1+24, eax
	invoke  LoadImage, hInstance, IDI_TEXAS3,IMAGE_ICON,256,256,NULL
	mov icoqueue1+20, eax
	invoke  LoadImage, hInstance, IDI_TEXAS4,IMAGE_ICON,256,256,NULL
	mov icoqueue1+16, eax
	invoke  LoadImage, hInstance, IDI_TEXAS5,IMAGE_ICON,256,256,NULL
	mov icoqueue1+12, eax
	invoke  LoadImage, hInstance, IDI_TEXAS6,IMAGE_ICON,256,256,NULL
	mov icoqueue1+8, eax
	;load hit icon: perfect, great, miss
	invoke  LoadImage, hInstance, IDI_ICONGre,IMAGE_ICON,256,256,NULL
	mov icohit, eax
	invoke  LoadImage, hInstance, IDI_ICONMis,IMAGE_ICON,256,256,NULL
	mov icohit+4, eax
	invoke  LoadImage, hInstance, IDI_ICONPer,IMAGE_ICON,256,256,NULL
	mov icohit+8, eax

	;load background image
	invoke  LoadBitmap, hInstance,IDB_BACKGROUND
	mov bmpbackground, eax
	
	;set refresh timer
	invoke	SetTimer,hWnd,1006,refresh,NULL
	;playing music
	invoke start_music
	ret
init_on_create	endp

; refresh_on_timer : refresh the window according to music position
refresh_on_timer	proc stdcall hWnd:dword, hStMsg:dword
push ebx
	push eax
	push edx
	invoke get_music_pos
	;trans music_pos to frame: frame = music_pos/5
	xor edx, edx
	mov ebx, 5
	div ebx
	mov frame, eax
	;invoke	printf, offset sztimertest
	;check the first object to draw in the upper case
	mov ebx, FirstItem1
	mov eax, ItemQueue1[ebx*4]
	add eax, 550
	.if eax < frame
	   INC FirstItem1
	.endif
	;check the first object to draw in the lower case
	mov ebx, FirstItem2
	mov eax, ItemQueue2[ebx*4]
	add eax, 550
	.if eax < frame
	   INC FirstItem2
	.endif
	pop edx
	pop eax
	pop ebx
	
	;set score and combo
	invoke  wsprintf,offset szScore1,offset szScore, score, Combo
	invoke  SetDlgItemText,hWnd,110,offset szScore1
	invoke  wsprintf,offset sztimertest,offset sztimertest2, frame
	;remove redundant WM_PAINT in the message queue(maybe don't need)
	remove_paint:
	invoke  PeekMessageA, hStMsg, NULL, 0,0,PM_REMOVE or PM_QS_PAINT
	cmp eax,0
	jnz remove_paint
	;invalid window to invoke paint event
	invoke  InvalidateRect,hWnd,NULL,FALSE
	ret
refresh_on_timer	endp

; drawobject_up : draw object in the upper case
drawobject_up              proc    stdcall hWnd:dword, x:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC

        push eax
        invoke  BeginPaint,hWnd,addr @stPs
        
        mov @hDc,eax
        ;invoke  CreateCompatibleDC, @hDc
        ;mov @hhDc,eax
        mov eax, x
        add eax, 600
        sub eax, frame
        invoke  DrawIconEx, @hDc,eax,85, bmpobject, 64,64,0,NULL,DI_NORMAL
        ;invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
        pop eax
        ret
drawobject_up endp

; drawobject_down : draw object in the lower case
drawobject_down              proc    stdcall hWnd:dword, x:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC
        push eax
        invoke  BeginPaint,hWnd,addr @stPs
        
        mov @hDc,eax
        ;invoke  CreateCompatibleDC, @hDc
        ;mov @hhDc,eax
        mov eax, x
        add eax, 600
        sub eax, frame
        invoke  DrawIconEx, @hDc,eax,170, bmpobject, 64,64,0,NULL,DI_NORMAL
        ;invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
            
        pop eax
        ret
drawobject_down endp

; drawobject_hit : draw hit icon : perfect, great, miss
drawobject_hit            proc    stdcall hWnd:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC
        local   @x:dword
        local   @ratio:dword

        push eax
        push ebx
        invoke  BeginPaint,hWnd,addr @stPs
        cmp ComboState, -1
        jz  not_drawhit
        mov @hDc,eax
        invoke  CreateCompatibleDC, @hDc
        mov @hhDc,eax
        mov ebx,hit_frame
        mov eax,5
        mul ebx
        mov ebx,250
        sub ebx,eax
        mov @x,ebx
        sub ebx,100
        mov @ratio,ebx

        mov eax, ComboState
        mov ebx, 4
        mul ebx
        invoke  DrawIconEx, @hDc,@x,95, icohit[eax], @ratio,@ratio,0,NULL,DI_NOMIRROR or DI_NORMAL
        invoke  DeleteDC, @hhDc
        .if hit_frame > 0
            sub hit_frame, 1
        .endif
        not_drawhit:
        invoke  EndPaint,hWnd,addr @stPs
        pop ebx
        pop eax
        ret
drawobject_hit endp

; drawobject_char1 : draw character in the upper case
drawobject_char2             proc    stdcall hWnd:dword, x:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC

        push eax
        push ebx
        invoke  BeginPaint,hWnd,addr @stPs
        
        mov @hDc,eax
        invoke  CreateCompatibleDC, @hDc
        mov @hhDc,eax
        mov eax, charframe2
        mov ebx, 4
        mul ebx
        invoke  DrawIconEx, @hDc,20,125, icoqueue2[eax], 150,150,0,NULL,DI_NOMIRROR or DI_NORMAL
        .if charframe2 > 0
            sub charframe2, 1
        .endif
        invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
        pop ebx
        pop eax
        ret
drawobject_char2 endp

; drawobject_char2 : draw character in the lower case
drawobject_char1             proc    stdcall hWnd:dword, x:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC

        push eax
        push ebx
        invoke  BeginPaint,hWnd,addr @stPs
        
        mov @hDc,eax
        invoke  CreateCompatibleDC, @hDc
        mov @hhDc,eax
        mov eax, charframe1
        mov ebx, 4
        mul ebx
        invoke  DrawIconEx, @hDc,50,45, icoqueue1[eax], 120,120,0,NULL,DI_NOMIRROR or DI_NORMAL
        .if charframe1 > 1
            sub charframe1, 1
        .endif
        invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
        pop ebx
        pop eax
        ret
drawobject_char1 endp

; drawbackgroundf : draw full background
drawbackgroundf	proc    stdcall hWnd:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC
        push eax
        invoke  BeginPaint,hWnd,addr @stPs
        mov @hDc,eax
        invoke  CreateCompatibleDC,@hDc
        mov @hhDc,eax
        invoke  SelectObject,@hhDc,bmpbackground
        mov     bmpbackgroundf,eax
        invoke  BitBlt ,@hDc,0,0,640,360,@hhDc,0,0,SRCCOPY
        invoke  SelectObject,@hhDc,bmpbackgroundf
        invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
        pop eax
        ret
drawbackgroundf endp

; drawbackground : draw part of the background
drawbackground	proc    stdcall hWnd:dword
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @hDc:HDC
        local   @hhDc:HDC
        push eax
        invoke  BeginPaint,hWnd,addr @stPs
        mov @hDc,eax

        invoke  CreateCompatibleDC,@hDc
        mov @hhDc,eax
        invoke  SelectObject,@hhDc,bmpbackground
        mov   bmpbackgroundf,eax
        ;invoke  printf,offset sztimertest2, eax
        invoke  BitBlt,@hDc,0,50,640,150,@hhDc,0,50,SRCCOPY
        invoke  BitBlt,@hDc,0,200,640,100,@hhDc,0,200,SRCCOPY
        invoke  SelectObject,@hhDc,bmpbackgroundf
        invoke  DeleteDC, @hhDc
        invoke  EndPaint,hWnd,addr @stPs
        pop eax
        ret
drawbackground	endp

; draw_intrf_start : draw start interface
draw_intrf_start	proc stdcall hWnd:dword
	ret
draw_intrf_start	endp

; draw_intrf_music : draw music selection interface
draw_intrf_music	proc stdcall hWnd:dword
	ret
draw_intrf_music	endp

; draw_intrf_game : draw game interface
draw_intrf_game	proc stdcall hWnd:dword
	.if frame == 0
		invoke  drawbackgroundf, hWnd ; draw full background when init
	.else
		invoke  drawbackground, hWnd
		invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_char1, hWnd, ItemQueue1[edi*4]
		invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_char2 ,hWnd, ItemQueue1[edi*4]
		push edx
		push eax
		; draw object in the upper case
		mov edi, FirstItem1 
		mov eax, ItemQueue1[edi*4]
		
	check_object_up:         
		cmp eax, frame
		jg end_check_up

		invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_up, hWnd, ItemQueue1[edi*4]
		inc edi
		mov eax, ItemQueue1[edi*4]
		push eax
		pop eax
		jmp check_object_up
		;.endw
	end_check_up:
		; draw object in the lower case
		mov edi, FirstItem2
		mov eax, ItemQueue2[edi*4]
		;.while eax<=frame
	check_object_down:
        cmp eax, frame
		jg end_check_down
		invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_down, hWnd, ItemQueue2[edi*4]

		inc edi
		mov eax, ItemQueue2[edi*4]
		push eax
		;invoke  printf, offset szFmt, eax
		pop eax
		jmp check_object_down
		;.endw
	end_check_down:
		; draw hit icon
		invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_hit, hWnd
		pop eax
		pop edx
	.endif
	ret
draw_intrf_game	endp

; getscore1 : compute score in the upper case
getscore1	proc  stdcall hWnd:dword
	push eax
	push ebx   
	push edx
	mov charframe1, 6
	mov ebx, FirstItem1
	mov edx, ItemQueue1[ebx*4]
	mov eax, frame
	sub  eax, edx
	mov ebx, eax
	mov eax, 500
	cmp eax, ebx
	jb Fu
	sub eax, ebx
	jmp end_fu
Fu: 
	sub ebx, eax
	mov eax, ebx
end_fu:
	.if eax <= 20
		mov ebx, score
		add ebx, 10
		mov score, ebx
		inc FirstItem1
		inc Combo
		mov ComboState, 2
		;处理Perfect
	.elseif eax <= 50
		mov ebx, score
		add ebx, 5
		mov score, ebx
		inc FirstItem1
		inc Combo
		mov ComboState, 1
		;处理Great
	.else
		mov Combo, 0
		mov ComboState, 0
	.endif
	;invoke  wsprintf, offset szCombo1, offset szCombo, Combo
	;invoke  SetDlgItemText,hWnd,111,offset szCombo1
	pop edx
	pop ebx
	pop eax
	ret
getscore1	endp

; getscore2 : compute score in the lower case
getscore2	proc  stdcall hWnd:dword
	push eax
	push ebx   
	push edx
	mov charframe2, 5
	mov ebx, FirstItem2
	mov edx, ItemQueue2[ebx*4]
	mov eax, frame
	sub  eax, edx
	mov ebx, eax
	mov eax, 500
	cmp eax, ebx
	jb Fu2
	sub eax, ebx
	jmp end_fu2
Fu2: 
	sub ebx, eax
	mov eax, ebx
end_fu2:    
	.if eax <= 20
		mov ebx, score
		add ebx, 10
		mov score, ebx
		inc FirstItem2
		inc Combo
		mov ComboState, 2
		;处理Perfect
	.elseif eax <= 50
		mov ebx, score
		add ebx, 5
		mov score, ebx
		inc FirstItem2
		inc Combo
		mov ComboState, 1
		;处理Great
	.else
		mov Combo, 0
		mov ComboState, 0
	.endif
	;invoke  wsprintf, offset szCombo1, offset szCombo, Combo
	;invoke  SetDlgItemText,hWnd,111,offset szCombo1
	pop edx
	pop ebx
	pop eax
	ret
getscore2	endp

goto_intrf_music	proc
	ret
goto_intrf_music	endp

switch_music_prev	proc
	ret
switch_music_prev	endp

switch_music_next	proc
	ret
switch_music_next	endp

goto_intrf_game		proc
	ret
goto_intrf_game		endp

goto_intrf_start	proc
	ret
goto_intrf_start	endp

play_music_showcase	proc
	ret
play_music_showcase	endp

goto_intrf_menu		proc
	ret
goto_intrf_menu		endp

_WindowCallbackProc	proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
	local   @stMsg:MSG
	
	mov eax, uMsg
	
	.if eax == WM_PAINT
		; start intrf
		.if intrf == 0
			invoke draw_intrf_start, hWnd
		; music selection intrf
		.elseif intrf == 1
			invoke draw_intrf_music, hWnd
		; game intrf
		.elseif intrf == 2
			invoke draw_intrf_game, hWnd
		; in-game menu intrf
		;.elseif intrf == 3
		;	invoke draw_intrf_menu
		.endif

	.elseif eax == WM_CREATE
		invoke init_on_create, hWnd
		
	.elseif eax == WM_COMMAND
	
	.elseif eax == WM_KEYDOWN
		mov ebx, wParam
		; start intrf
		.if intrf == 0
			; quit game: Esc
			;;.if ebx == VK_ESCAPE
			;; may be implemented 10000 years later
			; go to music intrf: press any key
			invoke goto_intrf_music
		; music selection intrf
		.elseif intrf == 1
			; previous song: Q/A/LeftArrow
			.if (ebx == 'Q') || (ebx == 'A') || (ebx == VK_LEFT)
				invoke switch_music_prev
			; next song: E/D/RightArrow
			.elseif (ebx == 'E') || (ebx == 'D') || (ebx == VK_RIGHT)
				invoke switch_music_next
			; go to game intrf: Enter
			.elseif ebx == VK_RETURN
				invoke goto_intrf_game
			; return to start intrf: Esc
			.elseif ebx == VK_ESCAPE
				invoke goto_intrf_start
			; music showcase: Space
			.elseif ebx == VK_SPACE
				invoke play_music_showcase
			.endif
		; gaming intrf
		.elseif intrf == 2
			; up track hit: F/D/S
			.if (ebx == 'F') || (ebx == 'D') || (ebx == 'S')
				invoke getscore1, hWnd
			; down track hit: J/K/L
			.elseif (ebx == 'J') || (ebx == 'K') || (ebx == 'L')
				invoke getscore2, hWnd
			.elseif ebx == VK_ESCAPE
				invoke goto_intrf_menu
			.endif
		; in-game intrf
		;.elseif intrf == 3
		;	; return to game intrf: Esc
		;	.if ebx == VK_ESCAPE
		;		invoke recover_intrf_game
		;	; quit current game: Enter
		;	.elseif ebx == VK_RETURN
		;		invoke goto_intrf_music
		;	.endif
		.endif
	.elseif eax == WM_TIMER
		invoke refresh_on_timer, hWnd, addr @stMsg
	
	.elseif eax == WM_CLOSE
		invoke  DestroyWindow,hManinHwnd
        invoke  PostQuitMessage,NULL
		
	.else
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
	.endif
	xor eax, eax
	ret
_WindowCallbackProc endp

;定义wMain函数
_wMain      proc    
    local   @stWndClass:WNDCLASSEX
    local   @stMsg:MSG
    local   @hDc:dword
    local   @hhDc:dword
    invoke  GetModuleHandle,NULL
    mov hInstance,eax
    invoke  RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
;注册窗口类
    invoke  LoadCursor,0,IDC_ARROW
    mov @stWndClass.hCursor,eax
    push    hInstance
    pop     @stWndClass.hInstance
    mov     @stWndClass.cbSize,sizeof  WNDCLASSEX
    mov     @stWndClass.style,CS_HREDRAW or CS_VREDRAW
    mov     @stWndClass.lpfnWndProc,offset  _WindowCallbackProc
    mov     @stWndClass.hbrBackground,COLOR_WINDOW + 1
    mov     @stWndClass.lpszClassName,offset  szWindowClass
    invoke  RegisterClassEx,addr    @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szWindowClass,offset szTitle,\
			WS_OVERLAPPEDWINDOW,\
			100,100,640,360,\
			NULL,NULL,hInstance,NULL
		mov	hManinHwnd,eax
		invoke	ShowWindow,hManinHwnd,SW_SHOWNORMAL
		invoke	UpdateWindow,hManinHwnd
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
            ;invoke	UpdateWindow,hManinHwnd
		.endw
		ret

_wMain      endp

start:
	call _wMain
	invoke ExitProcess, NULL
end start