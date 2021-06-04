.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc
include user32.inc
include winmm.inc
include kernel32.inc
include shlwapi.inc
includelib user32.lib
includelib gdi32.lib
includelib kernel32.lib
includelib msvcrt.lib
includelib winmm.lib
includelib shlwapi.lib

fopen	proto c:dword,:dword
fgets	proto c:dword,:dword,:dword
fclose  proto c:dword
fprintf proto c:dword,:dword,:vararg
fflush	proto c:dword
strcmp	proto c:dword,:dword
strcat  proto c:dword,:dword
strlen	proto c:dword
printf	proto c:dword,:vararg
atoi	proto c:ptr byte
feof    proto c:dword
get_music_list	proto stdcall
draw_upper_button   proto  stdcall : dword
draw_lower_button   proto  stdcall : dword
.data
;resources
IDI_GAMEICO		 equ	101
IDI_UPPERICON1   equ    105
IDI_UPPERICON2   equ    106
IDI_LOWERICON1   equ    107
IDI_LOWERICON2   equ    108
IDB_BACKGROUND	 equ	109
; intrf(interface):
;	0:start intrf;
;	1:record intrf;
; end intrf
intrf	dd	0
refresh dword  60
frame   dword  0
; start intrf elements var
maxMusicNum		dword	500
dirNameLen		dword	128
cntMusic		dword	0
frontMusicId	dword	0
; musicExist:
;	0:music not exist
;	1:music exists
; end musicExist
musicExist		dword	0
; noteExist:
;	0:note not exist
;	1:note or part of note exists
; end noteExist
noteExist		dword	0
mode	    	byte	"wb", 0	
; start intrf elements string
szMusicDir		byte	"music\*", 0
szFilePath		byte	"music\%s\%s", 0
szFileFormat	byte	"%s", 0
szRecordFormat	byte	0ah,"%d", 0
szRecordFormatF	byte	"%d", 0
szCurDir		byte	".", 0
szParDir		byte	"..", 0
szMP3Ext		byte	"%s.mp3", 0
szWAVExt		byte	"%s.wav", 0
szCoverExt		byte	"%s.ico", 0
szNoteExt1		byte	"%s.ark1", 0
szNoteExt2		byte	"%s.ark2", 0
szDefaultCoverPath byte "assets\defaultcover.ico", 0
szVINYLPath		byte	"assets\VINYL.ico", 0
szQuitMesg		byte	"Leave Skadi alone?",0
szQuitTitle		byte	"I'm used to fighting alone.",0
szRewriteMesg	byte	".ark file(s) already exist, rewrite?", 0
szRewriteTitle	byte	"Be careful.", 0
szMusicMissMesg byte	".wav or .mp3 file of this song is not found", 0
szMusicMissTitle	byte	"Sing me a song, oh torturous nightmare.", 0
szMusicEndMesg	byte	"Record completed", 0
szMusicEndTitle	byte	"By your command.", 0
szMusicTitleFormat	byte	"  %s  ", 0
szMusicSelectFont	byte	"Microsoft Yahei", 0
; music
szOpenFormat	byte    'open "%s"', 0
szPlayFormat	byte    'play "%s" from 0', 0
szStopFormat	byte    'stop "%s"', 0
szCloseFormat	byte    'close "%s"', 0
;szPauseFormat   byte    'pause "%s"',0
;szResumeFormat  byte    'resume "%s"',0
;szRepeatFormat	byte	'play "%s" repeat', 0
szQTimeFormat	byte    'status "%s" position', 0
szQModeFormat	byte	'status "%s" mode', 0
;szPrintNum		byte    "Current Position: %d", 0dh, 0ah, 0
szStoppedStr	byte	"stopped", 0

;record intrf
upperState      dword		0
lowerState      dword		0
upperButton     dword		2 dup(?)
lowerButton     dword		2 dup(?)
enableUpperKey	dword		1
enableLowerKey	dword		1
musicStop		dword		0
firstNote1      dword		1
firstNote2      dword		1
; window
szWindowClass   byte    "New_Window",0
szTitle         byte    "Skadi's Workshop",0

.data?
; start intrf elements
bmpstartbkgnd	dword 	?
bmpstartbkgndf	dword	?
musicList		byte	128*500 dup(?)
szMusicName		byte	280 dup(?)
szMusicPath		byte	280 dup(?)
szMusicTitle	byte	280	dup(?)
szCoverPath		byte	280 dup(?)
szNotePath1		byte	280 dup(?)
szNotePath2		byte	280 dup(?)
hVINYL			dword	?
hDefaultCover	dword	?
; music
szOpenMusic		byte    280 dup(?) ; len(szMusicName):260 + len(szOpenFormat):18 + '\0':1 + 1(reduntant)
szPlayMusic		byte    280 dup(?)
szStopMusic		byte    280 dup(?)
;szPauseMusic    byte    280 dup(?)
;szResumeMusic   byte    280 dup(?)
szCloseMusic	byte    280 dup(?)
;szRepeatMusic	byte	280 dup(?)
szQueryTime		byte    280 dup(?)
szRecvTime		byte    32 dup(?)
szQueryMode		byte	280 dup(?)
szRecvMode		byte	32 dup(?)
;notefile
hFile1		    dword	?
hFile2		    dword	?
; test
sztimertest     byte    "timer",0
sztimertest2    byte    "a%d",0ah,0
sztimertestc    byte    "@%c",0ah,0
sztimertests    byte    "@@%s",0ah,0
;szbackground    byte    "background.bmp",0
;szobject        byte    "ship.bmp",0
szQueue         byte    "Q%d",0ah,0

; window
hInstance       dword   ?   ;main process handle
hManinHwnd      dword   ?   ;main window handle
hhDc			HDC		?	;double buffer HDC handle

.code
; get_pre_id : get pre(frontMusicId)
get_pre_id		proc	stdcall frontMusic:dword
	.if frontMusic == 0
		mov eax, cntMusic
		mov frontMusic, eax
	.else
		dec frontMusic
	.endif
	mov eax, frontMusic
	ret
get_pre_id		endp

; get_nxt_id : get nxt(frontMusicId)
get_nxt_id		proc	stdcall frontMusic:dword
	mov eax, frontMusic
	sub eax, cntMusic
	.if eax == 0
		mov frontMusic, 0
	.else
		inc frontMusic
	.endif
	mov eax, frontMusic
	ret
get_nxt_id		endp

; get_all_path_by_idx : set the values of szMusicPath, szSnatchPath and szCoverPath
get_all_path_by_idx	proc	stdcall frontMusic:dword
	local	@curMusic:dword

	; all files detected in default
	mov musicExist, 1
	mov noteExist, 0

	; get filename without extension
	mov eax, frontMusic
	mul dirNameLen
	add eax, offset musicList
	mov @curMusic, eax
	; check if .ico exists
	invoke wsprintf, offset szMusicName, offset szCoverExt, @curMusic
	invoke wsprintf, offset szCoverPath, offset szFilePath, @curMusic, offset szMusicName
	invoke PathFileExists, offset szCoverPath
	.if eax == FALSE
		; use default cover if no cover found
		invoke wsprintf, offset szCoverPath, offset szFileFormat, offset szDefaultCoverPath
	.endif
	; check if frontMusic == frontMusicId, s.t. only top music will be warned
	mov eax, frontMusic
	sub eax, frontMusicId
	.if eax == 0
		; check if .wav exists
		invoke wsprintf, offset szMusicName, offset szWAVExt, @curMusic
		;invoke printf, offset sztimertests, offset szMusicName
		invoke wsprintf, offset szMusicPath, offset szFilePath, @curMusic, offset szMusicName
		invoke printf, offset sztimertests, offset szMusicPath
		invoke PathFileExists, offset szMusicPath
		.if eax == FALSE
			; check if .mp3 exists
			invoke wsprintf, offset szMusicName, offset szMP3Ext, @curMusic
			invoke wsprintf, offset szMusicPath, offset szFilePath, @curMusic, offset szMusicName
			invoke printf, offset sztimertests, offset szMusicPath
			invoke PathFileExists, offset szMusicPath
			.if eax == FALSE
				; neither .wav nor .mp3 file is found
				;invoke MessageBox, NULL, offset szMusicNotFound, NULL, MB_OK
				mov musicExist, 0
			.endif
		.endif
		; check if .ark1 or .ark2 exists
		invoke wsprintf, offset szMusicName, offset szNoteExt1, @curMusic
		invoke wsprintf, offset szNotePath1, offset szFilePath, @curMusic, offset szMusicName
		invoke wsprintf, offset szMusicName, offset szNoteExt2, @curMusic
		invoke wsprintf, offset szNotePath2, offset szFilePath, @curMusic, offset szMusicName
		invoke PathFileExists, offset szNotePath1
		.if eax == TRUE
			; no .ark1 file is found
			;invoke MessageBox, NULL, offset szNote1NotFound, NULL, MB_OK
			mov noteExist, 1
		.else
			invoke PathFileExists, offset szNotePath2
			.if eax == TRUE
				; no .ark2 file is found
				;invoke MessageBox, NULL, offset szNote2NotFound, NULL, MB_OK
				mov noteExist, 1
			.endif
		.endif
	.endif
	ret
get_all_path_by_idx	endp

; set_music : set the path of music so that it could be played
set_music		proc
	invoke get_all_path_by_idx, frontMusicId
	ret
set_music		endp

; start_music : play the music
start_music		proc
	invoke wsprintf, offset szOpenMusic, offset szOpenFormat, offset szMusicPath
	invoke wsprintf, offset szPlayMusic, offset szPlayFormat, offset szMusicPath
	invoke wsprintf, offset szStopMusic, offset szStopFormat, offset szMusicPath
	invoke wsprintf, offset szCloseMusic, offset szCloseFormat, offset szMusicPath
	invoke wsprintf, offset szQueryTime, offset szQTimeFormat, offset szMusicPath
	invoke wsprintf, offset szQueryMode, offset szQModeFormat, offset szMusicPath

	invoke mciSendString, offset szOpenMusic, NULL, 0, NULL
	invoke printf, offset sztimertest2,eax
	invoke printf, offset sztimertests, offset szOpenMusic
	invoke mciSendString, offset szPlayMusic, NULL, 0, NULL
	ret
start_music		endp

; get_music_pos : get music position
get_music_pos	proc
	invoke mciSendString, offset szQueryTime, offset szRecvTime, 32, NULL ; get time position in milliseconds
	invoke atoi, offset szRecvTime ; convert time string to int -> eax
	ret
get_music_pos	endp

; check_music_end : eax = 0 if music is stopped
check_music_end	proc
	invoke RtlZeroMemory, offset szRecvMode, 32
	invoke mciSendString, offset szQueryMode, offset szRecvMode, 32, NULL ; get music mode and check if "stopped"
	;invoke printf, offset sztimertests, offset szRecvMode
	invoke strcmp, offset szRecvMode, offset szStoppedStr
	ret
check_music_end	endp

; end_music : stop and close music
end_music	proc
	invoke mciSendString, offset szStopMusic, NULL, 0, NULL
	invoke mciSendString, offset szCloseMusic, NULL, 0, NULL
	ret
end_music	endp

; init_on_create : necessary initializations on create
init_on_create	proc stdcall hWnd:dword
	local	@hbmp:HBITMAP
	local   @stPs:PAINTSTRUCT
	local   @hDc:HDC
	invoke  LoadImage, hInstance, IDI_UPPERICON1,IMAGE_ICON,256,256, NULL
	mov upperButton, eax
	invoke  LoadImage, hInstance, IDI_UPPERICON2,IMAGE_ICON,256,256, NULL
	mov upperButton+4, eax
	invoke  LoadImage, hInstance, IDI_LOWERICON1,IMAGE_ICON,256,256, NULL
	mov lowerButton, eax
	invoke  LoadImage, hInstance, IDI_LOWERICON2,IMAGE_ICON,256,256, NULL
	mov lowerButton+4, eax
	invoke get_music_list
	invoke set_music

	invoke  LoadBitmap, hInstance,IDB_BACKGROUND
	mov bmpstartbkgnd, eax
	invoke  BeginPaint,hWnd,addr @stPs   
    mov @hDc,eax
	invoke  CreateCompatibleDC, NULL
    mov hhDc,eax
	invoke	CreateCompatibleBitmap,@hDc,640,360
	mov @hbmp,eax
	invoke	SelectObject, hhDc, @hbmp
	invoke  EndPaint,hWnd,addr @stPs
	invoke	SetTimer,hWnd,1006,refresh,NULL
	invoke  InvalidateRect,hWnd,NULL,FALSE
	ret
init_on_create	endp

;init_note_file : inittialization of notefile
init_note_file proc
    push eax
    invoke fopen, offset szNotePath1, offset mode
    mov hFile1, eax
	invoke fopen, offset szNotePath2, offset mode
    mov hFile2, eax
	pop eax
    ret
init_note_file  endp

; draw_intrf_start : draw start interface
draw_intrf_start	proc stdcall hWnd:dword
	local	@hDc:HDC
	local	@thDc:HDC
	local	@stPs:PAINTSTRUCT
	local	@rect:RECT
	local	@color:COLORREF
	local	@longFont:LOGFONT
	local	@hNewFont:dword
	local	@hOldFont:dword
	local	@curMusic:dword

	push eax
	invoke BeginPaint, hWnd, addr @stPs
	mov @hDc, eax
	invoke CreateCompatibleDC, NULL
	mov @thDc, eax
	invoke SelectObject, @thDc, bmpstartbkgnd
	mov bmpstartbkgndf, eax
	invoke BitBlt, hhDc, 0, 0, 640, 360, @thDc, 0, 0, SRCCOPY

	; get filename without extension
	mov eax, frontMusicId
	mul dirNameLen
	add eax, offset musicList
	mov @curMusic, eax

	mov	@rect.left, 0
	mov	@rect.top, 290
	mov	@rect.right, 660
	mov	@rect.bottom, 340

	; set text color
	mov	eax, 4D2D27h
	mov @color, eax
	invoke	SetTextColor, hhDc, @color

	; set text font
	invoke RtlZeroMemory, addr @longFont, sizeof LOGFONT
	mov @longFont.lfCharSet, GB2312_CHARSET
	mov @longFont.lfHeight, -17
	mov @longFont.lfQuality, PROOF_QUALITY
	mov @longFont.lfWeight, FW_MEDIUM
	invoke wsprintf, addr @longFont.lfFaceName, offset szMusicSelectFont
	invoke CreateFontIndirect, addr @longFont
	mov @hNewFont, eax
	invoke SelectObject, hhDc, @hNewFont
	mov @hOldFont, eax

	invoke	wsprintf, offset szMusicTitle, offset szMusicTitleFormat, @curMusic
	invoke	DrawText, hhDc, @curMusic, -1, addr @rect, DT_CENTER or DT_SINGLELINE or DT_VCENTER
	;invoke	printf, offset sztimertest2, eax
	
	; delete used font
	invoke SelectObject, hhDc, @hOldFont
	invoke DeleteObject, @hNewFont

	invoke BitBlt, @hDc, 0, 0, 640, 360, hhDc, 0, 0, SRCCOPY
	invoke SelectObject, @thDc, bmpstartbkgndf
	invoke DeleteDC, @thDc
	invoke EndPaint, hWnd, addr @stPs
	pop eax
	ret
draw_intrf_start	endp


; draw_intrf_record : draw start interface
draw_intrf_record	proc stdcall hWnd:dword
	local	@hDc:HDC
	local	@thDc:HDC
	local	@stPs:PAINTSTRUCT
	invoke  BeginPaint,hWnd,addr @stPs
	mov @hDc,eax
	invoke CreateCompatibleDC, NULL
	mov @thDc, eax
	invoke SelectObject, @thDc, bmpstartbkgnd
	mov bmpstartbkgndf, eax
	invoke BitBlt, hhDc, 0, 0, 640, 360, @thDc, 0, 0, SRCCOPY

	invoke draw_upper_button, hWnd
	invoke draw_lower_button, hWnd

	invoke  BitBlt,@hDc,0,0,640,360,hhDc,0,0,SRCCOPY
	invoke	SelectObject, @thDc, bmpstartbkgndf
    invoke  EndPaint,hWnd,addr @stPs
	ret
draw_intrf_record	endp

get_music_list		proc
	local 	@hMusicDir:dword
	local	@ffd:WIN32_FIND_DATA
	local	@hDirName:dword
	local	@curMusic:dword

	mov cntMusic, 0
	invoke FindFirstFile, offset szMusicDir, addr @ffd
	mov @hMusicDir, eax
	.repeat
		.if @ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY
			mov eax, cntMusic
			mul dirNameLen
			add eax, offset musicList
			mov @curMusic, eax
			invoke wsprintf, @curMusic, offset szFileFormat, addr @ffd.cFileName
			invoke strcmp, @curMusic, offset szCurDir
			.if eax == 0
				jmp dir_not_accept
			.endif
			invoke strcmp, @curMusic, offset szParDir
			.if eax == 0
				jmp dir_not_accept
			.endif
			invoke printf, offset sztimertests, addr @ffd.cFileName
			inc cntMusic
dir_not_accept:
		.endif
		invoke FindNextFile, @hMusicDir, addr @ffd
	.until eax == 0
	invoke FindClose, @hMusicDir
	dec cntMusic
	;invoke printf, offset sztimertests, offset musicList
	;invoke printf, offset sztimertest2, cntMusic
	ret
get_music_list		endp

; goto_intrf_start : goto start intrf
goto_intrf_start	proc
	mov intrf, 0
	invoke end_music
	invoke get_music_list
	invoke set_music 
	ret
goto_intrf_start	endp

; goto_intrf_record : goto record intrf
goto_intrf_record	proc
	mov intrf, 1
	mov musicStop, 0
	mov firstNote1, 1
	mov firstNote2, 1
	invoke init_note_file
	invoke start_music
	ret
goto_intrf_record	endp

; switch_music_prev : switch to previous music
switch_music_prev	proc
	invoke get_pre_id, frontMusicId
	mov frontMusicId, eax
	invoke printf, offset sztimertest2, frontMusicId
	invoke set_music
	ret
switch_music_prev	endp

; switch_music_next : switch to next music
switch_music_next	proc
	invoke get_nxt_id, frontMusicId
	mov frontMusicId, eax
	invoke printf, offset sztimertest2, frontMusicId
	invoke set_music
	ret
switch_music_next	endp

; restart_record : restart the record process
restart_record		proc
	invoke end_music
	mov musicStop, 0
	mov firstNote1, 1
	mov firstNote2, 1
	invoke init_note_file
	invoke start_music
	ret
restart_record		endp

; record_upper_track : record the upper track to .ark1
record_upper_track	proc
    push eax
    mov eax, frame
    sub eax, 490
	cmp	eax, 0
	jng	not_record_upper
	.if	firstNote1 == 1
		invoke fprintf, hFile1,offset szRecordFormatF, eax
		invoke fflush, hFile1
		mov firstNote1, 0
	.else
		invoke fprintf, hFile1, offset szRecordFormat, eax
		invoke fflush, hFile1
	.endif
not_record_upper:
	pop eax
	ret
record_upper_track	endp

; draw_upper_button : draw the upper button
draw_upper_button   proc  stdcall hWnd:dword
	local   @hhDc:HDC
	.if upperState == 1
		invoke DrawIconEx, hhDc,140,100, upperButton+4, 128,128,0,NULL,DI_NORMAL
	.else 
		invoke DrawIconEx, hhDc,140,100, upperButton, 128,128,0,NULL,DI_NORMAL
	.endif
	ret
draw_upper_button   endp 
; record_lower_track : record the lower track to .ark2
record_lower_track	proc
	push eax
    mov eax, frame
	sub eax, 470
	cmp eax, 0
	jng not_record_lower
	.if	firstNote2 == 1
		invoke fprintf, hFile2,offset szRecordFormatF, eax
		invoke fflush, hFile2
		mov firstNote2, 0
	.else
		invoke fprintf, hFile2, offset szRecordFormat, eax
		invoke fflush, hFile2
	.endif
not_record_lower:
	pop eax
	ret
record_lower_track	endp

; draw_lower_button : draw the lower button
draw_lower_button   proc  stdcall hWnd:dword
	local   @hhDc:HDC
	.if lowerState == 1
		invoke DrawIconEx, hhDc,360,100, lowerButton+4, 128,128,0,NULL,DI_NORMAL
	.else 
		invoke DrawIconEx, hhDc,360,100, lowerButton, 128,128,0,NULL,DI_NORMAL
	.endif
	ret
draw_lower_button   endp 

refresh_on_timer	proc stdcall hWnd:dword
	push ebx
	push eax
	push edx
	.if musicStop == 1
		jmp remove_paint
	.endif
	invoke check_music_end
	.if	eax == 0
		mov musicStop, 1
		invoke MessageBox, hWnd, offset szMusicEndMesg, offset szMusicEndTitle, MB_OK
		invoke fclose, hFile1
		invoke fclose, hFile2
		invoke goto_intrf_start
	.endif
	invoke get_music_pos
	;trans music_pos to frame: frame = music_pos/5
	xor edx, edx
	mov ebx, 5
	div ebx
	mov frame, eax
remove_paint:

	invoke  InvalidateRect,hWnd,NULL,FALSE
	pop edx
	pop eax
	pop ebx
	ret
refresh_on_timer	endp

_WindowCallbackProc	proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
	local   @stMsg:MSG
	
	mov eax, uMsg
	
	.if eax == WM_PAINT
		.if intrf == 0
			invoke draw_intrf_start, hWnd
		.elseif intrf == 1
			invoke draw_intrf_record, hWnd
		.endif

	.elseif eax == WM_CREATE
		invoke init_on_create, hWnd
	.elseif eax == WM_COMMAND
	.elseif eax == WM_KEYUP
		mov ebx ,wParam
		.if intrf == 1
			.if (ebx == 'F') || (ebx == 'D') || (ebx == 'S')
				.if enableUpperKey == 0
					mov upperState, 0
					mov enableUpperKey, 1
				.endif
			.elseif (ebx == 'J') || (ebx == 'K') || (ebx == 'L')
				.if enableLowerKey == 0
					mov lowerState, 0
					mov enableLowerKey, 1
				.endif
			.endif
		.endif
	.elseif eax == WM_KEYDOWN
		mov ebx, wParam
		; start intrf
		.if intrf == 0
			; quit record : Esc
			.if ebx == VK_ESCAPE
				invoke MessageBox, hWnd, offset szQuitMesg, offset szQuitTitle, MB_OKCANCEL
				.if eax == IDOK
					invoke SendMessage, hWnd, WM_CLOSE, NULL, NULL
				.endif
			; goto record intrf : Space
			.elseif ebx == VK_SPACE
				.if musicExist == 1
					.if noteExist == 1
						invoke MessageBox, hWnd, offset szRewriteMesg, offset szRewriteTitle, MB_OKCANCEL
						.if eax == IDOK
							invoke goto_intrf_record
						.endif
					.else
						invoke goto_intrf_record
					.endif
				.else
					invoke MessageBox, hWnd, offset szMusicMissMesg, offset szMusicMissTitle, MB_OK
				.endif
			; previous music : W
			.elseif ebx == 'W'
				invoke switch_music_prev
			; next music : S
			.elseif ebx == 'S'
				invoke switch_music_next
			.endif
		; record intrf
		.elseif intrf == 1
			; restart music play & record : Backspace
			.if ebx == VK_BACK
				invoke restart_record
			; goto start intrf : Esc
			.elseif ebx == VK_ESCAPE
				invoke goto_intrf_start
			; upper track record : F/D/S
			.elseif (ebx == 'F') || (ebx == 'D') || (ebx == 'S')
				.if enableUpperKey == 1
					mov upperState, 1
					invoke record_upper_track
					mov enableUpperKey, 0
				.endif
			; lower track record : J/K/L
			.elseif (ebx == 'J') || (ebx == 'K') || (ebx == 'L')
				.if enableLowerKey == 1
					mov lowerState, 1
					invoke record_lower_track
					mov enableLowerKey, 0
				.endif
			.endif
		.endif

	.elseif eax == WM_TIMER
		invoke	refresh_on_timer, hWnd
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
	invoke  LoadImage, hInstance, IDI_GAMEICO,IMAGE_ICON,256,256,NULL
	mov		@stWndClass.hIcon, eax
    invoke  RegisterClassEx,addr    @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szWindowClass,offset szTitle,\
		WS_OVERLAPPEDWINDOW xor WS_THICKFRAME,\
		450,220,660,402,\
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