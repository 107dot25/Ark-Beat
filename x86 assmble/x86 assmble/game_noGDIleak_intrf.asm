.386
.model flat,stdcall
option casemap:none
; include section
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
strcmp	proto c:dword,:dword
strcat  proto c:dword,:dword
strlen	proto c:dword
printf	proto c:dword,:vararg
atoi	proto c:ptr byte
feof    proto c:dword
goto_intrf_music proto stdcall
.data
; resources
IDI_GAMEICO		equ		  101
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
IDI_Mission     equ       139
IDB_STARTBKGND	equ		  143
IDB_MUSICBKGND	equ		  144
IDI_ICONSTOP    equ       146

; intrf(interface):
;	0:start intrf;
;	1:music selection intrf;
;	2:game intrf;
;	3:(optional)in-game menu intrf
; end intrf
intrf	dd	0

; music selection intrf elements var
maxMusicNum		dword	500
dirNameLen		dword	128
cntMusic		dword	0
frontMusicId	dword	0
; musicExist:
;	0:music not exist
;	1:music exists;
; end musicExist
musicExist		dword	0
; clipExist:
;	0:clip not exist
;	1:clip exists;
; end clipExist
clipExist		dword	0
; noteExist:
;	-1:.ark2 not exist
;	0:.ark1 not exist
;	1:note exists;
; end musicExist
noteExist		dword	0
; music selection intrf elements string
szMusicDir		byte	"music\*", 0
szFilePath		byte	"music\%s\%s", 0
szFileFormat	byte	"%s", 0
szCurDir		byte	".", 0
szParDir		byte	"..", 0
szMP3Ext		byte	"%s.mp3", 0
szWAVExt		byte	"%s.wav", 0
szClipExt		byte	"%s.clip.mp3", 0
szCoverExt		byte	"%s.ico", 0
szNoteExt1		byte	"%s.ark1", 0
szNoteExt2		byte	"%s.ark2", 0
szDefaultCoverPath byte "assets\defaultcover.ico", 0
szVINYLPath		byte	"assets\VINYL.ico", 0
szQuitMesg		byte	"Get some rest?",0
szQuitTitle		byte	"Doctor, you can't rest now!",0
szFileMissMesg	byte	"I may have underestimated this operation's difficulty...", 0
szMusicNotFound byte	".wav or .mp3 file of this song is not found", 0
szClipNotFound	byte	".clip.mp3 file of this song is not found", 0
szNote1NotFound	byte	".ark1 file of this song is not found", 0
szNote2NotFound	byte	".ark2 file of this song is not found", 0
szMusicTitleFormat	byte	"  %s  ", 0
szMusicSelectFont	byte	"Microsoft Yahei", 0

; game intrf elements var
FirstItem1  	dword   0
FirstItem2  	dword   0
nowItem     	dword   0
mode	    	byte	"rb", 0	
refresh	    	dword	16
frame       	dword   0
charframe1  	dword   0
charframe2  	dword   0
score       	dword   0
Combo       	dword   0
ComboFlag   	dword   0
ComboState  	dword   -1
ItemSize1   	dword   0
ItemSize2   	dword   0
paint_flag  	dword   1
hit_frame   	dword   0
end_pos			dword	-1
isend       	dword   0
gamePause       dword   0
musicStop		dword   0
enableUpperKey	dword	1
enableLowerKey	dword	1
szGameScoreFont	byte	"OCR-A", 0

; music
szOpenFormat	byte    'open "%s"', 0
szPlayFormat	byte    'play "%s" from 0', 0
szStopFormat	byte    'stop "%s"', 0
szCloseFormat	byte    'close "%s"', 0
szPauseFormat   byte    'pause "%s"',0
szResumeFormat  byte    'resume "%s"',0
szRepeatFormat	byte	'play "%s" repeat', 0
szQTimeFormat	byte    'status "%s" position', 0
szQModeFormat	byte	'status "%s" mode', 0
szPrintNum		byte    "Current Position: %d", 0dh, 0ah, 0
szStoppedStr	byte	"stopped", 0

; game intrf elements string
szHitPath		byte	"assets\hit_music.wav", 0
szMissPath		byte	"assets\miss_music.wav", 0
szAccompPath	byte	"assets\mission_accomplished.wav", 0
szFailed        byte    "Can't Open the File",0ah,0
szScoreFormat   byte    " SCORE: %d ", 0ah, " COMBO: %d ", 0
;szFmt	        byte    '%d',0ah,0
;szContent       byte    "this is first window",0
szWindowClass   byte    "New_Window",0
szTitle         byte    "Ark Dash",0
;szButton	    byte	"Button",0
;szButtonTitle	byte	"&Compare",0
;szText	        byte	"Edit",0
;szStatic	    byte	"Static",0

; test
sztimertest     byte    "timer",0
sztimertest2    byte    "a%d",0ah,0
sztimertestc    byte    "@%c",0ah,0
sztimertests    byte    "@@%s",0ah,0
;szbackground    byte    "background.bmp",0
;szobject        byte    "ship.bmp",0
szQueue         byte    "Q%d",0ah,0

.data?
; start intrf elements
bmpstartbkgnd	dword 	?
bmpstartbkgndf	dword	?

; music selection intrf elements
bmpmusicbkgnd	dword	?
bmpmusicbkgndf	dword	?
musicList		byte	128*500 dup(?)	; maxMusicNum * dirNameLen
szMusicName		byte	280 dup(?)
szMusicPath		byte	280 dup(?) ;"music\Yunomi; 鬼頭明里 - 恋のうた (feat. 由崎司)\Yunomi; 鬼頭明里 - 恋のうた (feat. 由崎司).wav", 0 ; max_len is 260 bytes, '\0' included
szSnatchPath	byte	280 dup(?) ;"music\Yunomi; 鬼頭明里 - 恋のうた (feat. 由崎司)\Yunomi; 鬼頭明里 - 恋のうた (feat. 由崎司).clip.mp3", 0 ; max_len is 260 bytes, '\0' included
szCoverPath		byte	280 dup(?)
szCoverPathL	byte	280 dup(?)
szCoverPathR	byte	280	dup(?)
szNotePath1		byte	280 dup(?)
szNotePath2		byte	280 dup(?)
szMusicTitle	byte	280	dup(?)
hVINYL			dword	?
hDefaultCover	dword	?

; game intrf elements
ItemQueue1  	dword   1000 dup(?)
ItemQueue2  	dword   1000 dup(?)
hFile1		    dword	?
hFile2		    dword	?
noteBuf1	    byte	65535 dup(?)
noteBuf2	    byte	65535 dup(?)
;szout	    	byte	65535 dup(?)
bmpbackground   dword   ?
bmpbackgroundf  dword   ?
icoobject       dword   ?
bmpchar1        dword   ?
icoqueue2       dword   6 dup(?)
icoqueue1       dword   7 dup(?)
icohit          dword   7 dup(?)
icomission      dword   ?
icostop         dword   ?
szScoreText     byte    30 dup (?)

; music
szOpenMusic		byte    280 dup(?) ; len(szMusicName):260 + len(szOpenFormat):18 + '\0':1 + 1(reduntant)
szPlayMusic		byte    280 dup(?)
szStopMusic		byte    280 dup(?)
szPauseMusic    byte    280 dup(?)
szResumeMusic   byte    280 dup(?)
szCloseMusic	byte    280 dup(?)
szRepeatMusic	byte	280 dup(?)
szQueryTime		byte    280 dup(?)
szRecvTime		byte    32 dup(?)
szQueryMode		byte	280 dup(?)
szRecvMode		byte	32 dup(?)
szOpenHit		byte    280 dup(?)
szPlayHit		byte    280 dup(?)
szStopHit		byte    280 dup(?)
szCloseHit		byte    280 dup(?)
szOpenMiss		byte    280 dup(?)
szPlayMiss		byte    280 dup(?)
szStopMiss		byte    280 dup(?)
szCloseMiss		byte    280 dup(?)
szOpenAccomp	byte    280 dup(?)
szPlayAccomp	byte    280 dup(?)
szStopAccomp	byte    280 dup(?)
szCloseAccomp	byte    280 dup(?)
;recvLen			dword   32

; window
hInstance       dword   ?   ;main process handle
hManinHwnd      dword   ?   ;main window handle
hhDc			HDC		?	;double buffer HDC handle

.code
; initQueue : load beatmap file
initQueue  proc
    push eax
    push edx
    push ebx
	push ecx
    invoke fopen, offset szNotePath1, offset mode
	mov hFile1, eax
	invoke fopen, offset szNotePath2, offset mode
	mov hFile2, eax
	mov esi, 0
	xor eax,eax
	.while eax ==0
		xor ebx,ebx
		mov noteBuf1, bl
		invoke fgets, offset noteBuf1, 1024, hFile1
		invoke atoi, offset noteBuf1
		mov ItemQueue1[esi*4], eax
        
		inc esi
		invoke feof, hFile1
    .endw
    mov ItemQueue1[esi*4], 0FFFFFFFFH
    mov ItemSize1, esi
	mov esi, 0
	xor eax,eax
	.while eax ==0
		xor ebx,ebx
		mov noteBuf2, bl
		invoke fgets, offset noteBuf2, 1024, hFile2
		invoke atoi, offset noteBuf2
		mov ItemQueue2[esi*4], eax
		inc esi
		invoke feof, hFile2
    .endw
    mov ItemQueue2[esi*4], 0FFFFFFFFH
    mov ItemSize2, esi
    
	mov score, 0
	mov Combo, 0
	mov ComboState, -1
	mov FirstItem1, 0
	mov FirstItem2, 0
    ;invoke printf,offset szQueue, ItemSize1
	;invoke printf,offset szQueue, ItemSize1
	pop ecx
    pop ebx
    pop edx
    pop eax
    ret
initQueue endp

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
	mov clipExist, 1
	mov noteExist, 1

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
		;invoke printf, offset sztimertests, offset szMusicPath
		invoke PathFileExists, offset szMusicPath
		.if eax == FALSE
			; check if .mp3 exists
			invoke wsprintf, offset szMusicName, offset szMP3Ext, @curMusic
			invoke wsprintf, offset szMusicPath, offset szFilePath, @curMusic, offset szMusicName
			;invoke printf, offset sztimertests, offset szMusicPath
			invoke PathFileExists, offset szMusicPath
			.if eax == FALSE
				; neither .wav nor .mp3 file is found
				;invoke MessageBox, NULL, offset szMusicNotFound, NULL, MB_OK
				mov musicExist, 0
			.endif
		.endif
		; check if .clip.mp3 exists
		invoke wsprintf, offset szMusicName, offset szClipExt, @curMusic
		invoke wsprintf, offset szSnatchPath, offset szFilePath, @curMusic, offset szMusicName
		invoke PathFileExists, offset szSnatchPath
		.if eax == FALSE
			; no .clip.mp3 file is found
			;invoke MessageBox, NULL, offset szClipNotFound, NULL, MB_OK
			mov clipExist, 0
		.endif
		; check if .ark1 or .ark2 exists
		invoke wsprintf, offset szMusicName, offset szNoteExt1, @curMusic
		invoke wsprintf, offset szNotePath1, offset szFilePath, @curMusic, offset szMusicName
		invoke PathFileExists, offset szNotePath1
		.if eax == FALSE
			; no .ark1 file is found
			;invoke MessageBox, NULL, offset szNote1NotFound, NULL, MB_OK
			mov noteExist, 0
		.else
			invoke wsprintf, offset szMusicName, offset szNoteExt2, @curMusic
			invoke wsprintf, offset szNotePath2, offset szFilePath, @curMusic, offset szMusicName
			invoke PathFileExists, offset szNotePath2
			.if eax == FALSE
				; no .ark2 file is found
				;invoke MessageBox, NULL, offset szNote2NotFound, NULL, MB_OK
				mov noteExist, -1
			.endif
		.endif
	.endif
	ret
get_all_path_by_idx	endp

; get_ico_path_by_idx: prepares szIconPath for display
get_ico_path_by_idx	proc	stdcall pos:dword
	local	@idx:dword
	local	@curMusic:dword

	.if pos == 0
		; left icon
		invoke get_pre_id, frontMusicId
		mov @idx, eax
		; get filename without extension
		mov eax, @idx
		mul dirNameLen
		add eax, offset musicList
		mov @curMusic, eax
		; check if .ico exists
		invoke wsprintf, offset szMusicName, offset szCoverExt, @curMusic
		invoke wsprintf, offset szCoverPathL, offset szFilePath, @curMusic, offset szMusicName
		invoke PathFileExists, offset szCoverPathL
		.if eax == FALSE
			invoke wsprintf, offset szCoverPathL, offset szFileFormat, offset szDefaultCoverPath
		.endif
	.else
		; right icon
		invoke get_nxt_id, frontMusicId
		mov @idx, eax
		; get filename without extension
		mov eax, @idx
		mul dirNameLen
		add eax, offset musicList
		mov @curMusic, eax
		; check if .ico exists
		invoke wsprintf, offset szMusicName, offset szCoverExt, @curMusic
		invoke wsprintf, offset szCoverPathR, offset szFilePath, @curMusic, offset szMusicName
		invoke PathFileExists, offset szCoverPathR
		.if eax == FALSE
			invoke wsprintf, offset szCoverPathR, offset szFileFormat, offset szDefaultCoverPath
		.endif
	.endif
	ret
get_ico_path_by_idx endp

; set_snatch : set the path of snatch so that it could be played
set_snatch		proc
	invoke get_all_path_by_idx, frontMusicId
	ret
set_snatch		endp

; start_snatch : repeatitively play a snatch of music
start_snatch	proc
	.if clipExist == 1
		invoke wsprintf, offset szOpenMusic, offset szOpenFormat, offset szSnatchPath
		invoke wsprintf, offset szPlayMusic, offset szPlayFormat, offset szSnatchPath
		invoke wsprintf, offset szRepeatMusic, offset szRepeatFormat, offset szSnatchPath
		invoke wsprintf, offset szStopMusic, offset szStopFormat, offset szSnatchPath
		invoke wsprintf, offset szCloseMusic, offset szCloseFormat, offset szSnatchPath
		invoke mciSendString, offset szOpenMusic, NULL, 0, NULL
		;invoke printf, offset sztimertest2, eax
		invoke printf, offset sztimertests, offset szOpenMusic
		invoke mciSendString, offset szRepeatMusic, NULL, 0, NULL
	.endif
	ret
start_snatch	endp

; end_snatch : stop and close the snatch of music
end_snatch		proc
	.if clipExist == 1
		invoke mciSendString, offset szStopMusic, NULL, 0, NULL
		invoke mciSendString, offset szCloseMusic, NULL, 0, NULL
	.endif
	ret
end_snatch		endp

; start_music : play the music
start_music		proc
	invoke wsprintf, offset szOpenMusic, offset szOpenFormat, offset szMusicPath
	invoke wsprintf, offset szPlayMusic, offset szPlayFormat, offset szMusicPath
	invoke wsprintf, offset szStopMusic, offset szStopFormat, offset szMusicPath
	invoke wsprintf, offset szPauseMusic, offset szPauseFormat, offset szMusicPath
	invoke wsprintf, offset szResumeMusic, offset szResumeFormat, offset szMusicPath
	invoke wsprintf, offset szCloseMusic, offset szCloseFormat, offset szMusicPath
	invoke wsprintf, offset szQueryTime, offset szQTimeFormat, offset szMusicPath
	invoke wsprintf, offset szQueryMode, offset szQModeFormat, offset szMusicPath

	invoke mciSendString, offset szOpenMusic, NULL, 0, NULL
	invoke printf, offset sztimertest2,eax
	invoke printf, offset sztimertests, offset szOpenMusic
	invoke mciSendString, offset szPlayMusic, NULL, 0, NULL

	invoke wsprintf, offset szOpenHit, offset szOpenFormat, offset szHitPath
	invoke wsprintf, offset szPlayHit, offset szPlayFormat, offset szHitPath
	invoke wsprintf, offset szStopHit, offset szStopFormat, offset szHitPath
	invoke wsprintf, offset szCloseHit, offset szCloseFormat, offset szHitPath

	invoke wsprintf, offset szOpenMiss, offset szOpenFormat, offset szMissPath
	invoke wsprintf, offset szPlayMiss, offset szPlayFormat, offset szMissPath
	invoke wsprintf, offset szStopMiss, offset szStopFormat, offset szMissPath
	invoke wsprintf, offset szCloseMiss, offset szCloseFormat, offset szMissPath

	invoke wsprintf, offset szOpenAccomp, offset szOpenFormat, offset szAccompPath
	invoke wsprintf, offset szPlayAccomp, offset szPlayFormat, offset szAccompPath
	invoke wsprintf, offset szStopAccomp, offset szStopFormat, offset szAccompPath
	invoke wsprintf, offset szCloseAccomp, offset szCloseFormat, offset szAccompPath

	invoke mciSendString, offset szOpenHit, NULL, 0, NULL
	invoke mciSendString, offset szOpenMiss, NULL, 0, NULL
	invoke mciSendString, offset szOpenAccomp, NULL, 0, NULL
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

; hit_music : play hit music
hit_music	proc
	; test open
	
	;.if eax == 265
	;	invoke mciSendString, offset szStopHit, NULL, 0, NULL
	;	invoke mciSendString, offset szCloseHit, NULL, 0, NULL
	;	invoke mciSendString, offset szOpenHit, NULL, 0, NULL
	;.endif
	;invoke printf, offset sztimertest2, eax
	;invoke mciSendString, offset szStopHit, NULL, 0, NULL
	invoke mciSendString, offset szPlayHit, NULL, 0, NULL

	ret
hit_music	endp

; miss_music : play miss music
miss_music	proc
	; test open
	
	;.if eax == 265
	;	invoke mciSendString, offset szStopHit, NULL, 0, NULL
	;	invoke mciSendString, offset szCloseHit, NULL, 0, NULL
	;	invoke mciSendString, offset szOpenHit, NULL, 0, NULL
	;.endif
	;invoke printf, offset sztimertest2, eax
	;invoke mciSendString, offset szStopHit, NULL, 0, NULL
	invoke mciSendString, offset szPlayMiss, NULL, 0, NULL
	;invoke printf, offset sztimertest2, eax

	ret
miss_music	endp

accomp_music proc
	invoke mciSendString, offset szPlayAccomp, NULL, 0, NULL
	ret
accomp_music endp

; end_music : stop and close all(main, miss, hit and accomp) music
end_music	proc
	invoke mciSendString, offset szStopMiss, NULL, 0, NULL
	invoke mciSendString, offset szCloseMiss, NULL, 0, NULL
	invoke mciSendString, offset szStopMusic, NULL, 0, NULL
	invoke mciSendString, offset szCloseMusic, NULL, 0, NULL
	invoke mciSendString, offset szStopHit, NULL, 0, NULL
	invoke mciSendString, offset szCloseHit, NULL, 0, NULL
	invoke mciSendString, offset szStopAccomp, NULL, 0, NULL
	invoke mciSendString, offset szCloseAccomp, NULL, 0, NULL
	ret
end_music	endp

; init_on_create : necessary initializations on create
init_on_create	proc stdcall hWnd:dword
	local	@hbmp:HBITMAP
	local   @stPs:PAINTSTRUCT
	local   @hDc:HDC

	; draw scoreboard
	;invoke  CreateWindowEx,NULL,offset szStatic, offset szScore,WS_CHILD or WS_VISIBLE,\
	;280,0,80,40,hWnd,110,hInstance,NULL
	
	; start intrf elements
	;load start background
	invoke	LoadBitmap, hInstance, IDB_STARTBKGND
	mov bmpstartbkgnd, eax

	; music selection intrf elements
	;load music selection background
	invoke 	LoadBitmap, hInstance, IDB_MUSICBKGND
	mov bmpmusicbkgnd, eax

	; game intrf elements
	;load hit object
	invoke  LoadImage, hInstance, IDI_OBJECT,IMAGE_ICON,64,64, NULL
	mov icoobject, eax
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
	;load mission accomplished
	invoke  LoadImage, hInstance, IDI_Mission,IMAGE_ICON,256,256,NULL
	mov icomission, eax

	invoke  LoadImage, hInstance,offset szVINYLPath,IMAGE_ICON,256,256, LR_LOADFROMFILE
	mov hVINYL, eax
	;load stop icon
	invoke LoadImage, hInstance, IDI_ICONSTOP,IMAGE_ICON,256,256,NULL
	mov icostop, eax

	;load background image
	invoke  LoadBitmap, hInstance,IDB_BACKGROUND
	mov bmpbackground, eax
	invoke  BeginPaint,hWnd,addr @stPs   
    mov @hDc,eax
	invoke  CreateCompatibleDC, NULL
    mov hhDc,eax
	invoke	CreateCompatibleBitmap,@hDc,640,360
	mov @hbmp,eax
	invoke	SelectObject, hhDc, @hbmp
	invoke  EndPaint,hWnd,addr @stPs
	;invoke  InvalidateRect,hWnd,NULL,FALSE



	;set refresh timer
	invoke	SetTimer,hWnd,1006,refresh,NULL
	ret
init_on_create	endp

; drawobject_hit : draw hit icon : perfect, great, miss
drawobject_hit            proc    
        local   @stPs:PAINTSTRUCT
        local   @stRect:RECT
        local   @x:dword
        local   @ratio:dword

        push eax
        push ebx
        cmp ComboState, -1
        jz  not_drawhit
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
        invoke  DrawIconEx, hhDc,@x,95, icohit[eax], @ratio,@ratio,0,NULL,DI_NOMIRROR or DI_NORMAL
        .if hit_frame > 0
            sub hit_frame, 1
        .endif
        not_drawhit:
        pop ebx
        pop eax
        ret
drawobject_hit endp
; refresh_on_timer : refresh the window according to music position
refresh_on_timer	proc stdcall hWnd:dword, hStMsg:dword
    push ebx
	push eax
	push edx
	.if musicStop == 1
		jmp remove_paint
	.endif
	invoke check_music_end

	.if eax == 0
		; music stopped
		mov musicStop, 1
		.if gamePause == 0
			invoke	accomp_music
		.endif
	.else
		invoke get_music_pos
		;trans music_pos to frame: frame = music_pos/5
		xor edx, edx
		mov ebx, 5
		div ebx
		mov frame, eax
		;check the first object to draw in the upper case
		mov ebx, FirstItem1
		mov eax, ItemQueue1[ebx*4]
		add eax, 560
		.if eax < frame
			.if ebx < ItemSize1
				INC FirstItem1
				mov	hit_frame,3
				mov ComboState,0
				mov Combo,0
				invoke miss_music
			.endif
		.endif
		;check the first object to draw in the lower case
		mov ebx, FirstItem2
		mov eax, ItemQueue2[ebx*4]
		add eax, 580
		.if eax < frame
			.if ebx <ItemSize2
				INC FirstItem2
				mov ComboState,0
				mov Combo,0
				invoke miss_music
				mov	hit_frame,3
			.endif
		.endif
	.endif
	;set score and combo
	;invoke  wsprintf,offset szScore1,offset szScore, score, Combo
	;invoke  SetDlgItemText,hWnd,110,offset szScore1
	;invoke  wsprintf,offset sztimertest,offset sztimertest2, frame
	;remove redundant WM_PAINT in the message queue(maybe don't need)
	;.if isend == 1
	;    jmp refresh_on_timer_end
	;.endif
	remove_paint:
	invoke  PeekMessageA, hStMsg, NULL, 0,0,PM_REMOVE or PM_QS_PAINT
	cmp eax,0
	jnz remove_paint
	;invalid window to invoke paint event
	invoke  InvalidateRect,hWnd,NULL,FALSE
	pop edx
	pop eax
	pop ebx
;refresh_on_timer_end:
	ret
refresh_on_timer	endp

; drawobject_up : draw object in the upper case
drawobject_up              proc   stdcall x:dword
        push eax

        mov eax, x
        add eax, 608
        sub eax, frame
        invoke  DrawIconEx, hhDc,eax,85, icoobject, 64,64,0,NULL,DI_NORMAL

        pop eax
        ret
drawobject_up endp

; drawobject_down : draw object in the lower case
drawobject_down             proc   stdcall x:dword
        push eax

        mov eax, x
        add eax, 608
        sub eax, frame
        invoke  DrawIconEx, hhDc,eax,170, icoobject, 64,64,0,NULL,DI_NORMAL
            
        pop eax
        ret
drawobject_down endp

drawendingmark              proc  
        push eax
     
		.if end_pos < 165
			add end_pos, 2
			invoke  DrawIconEx, hhDc,end_pos,20, icomission, 256,256,0,NULL,DI_NORMAL
		.else
			add end_pos, 2
			invoke  DrawIconEx, hhDc,165,20, icomission, 256,256,0,NULL,DI_NORMAL
			.if end_pos > 255
				invoke goto_intrf_music
			.endif
        .endif
        pop eax
        ret
drawendingmark endp
;draw stop icon
draw_stopmenu proc 
	invoke  DrawIconEx, hhDc,192,40,icostop,256,256,0,NULL,DI_NOMIRROR or DI_NORMAL
	ret
draw_stopmenu endp

; drawobject_char2 : draw character in the lower case
drawobject_char2             proc   
        push eax
        push ebx

        mov eax, charframe2
        mov ebx, 4
        mul ebx
        invoke  DrawIconEx, hhDc,40,125, icoqueue2[eax], 150,150,0,NULL,DI_NOMIRROR or DI_NORMAL
        .if charframe2 > 0
            sub charframe2, 1
        .endif
        pop ebx
        pop eax
        ret
drawobject_char2 endp

; drawobject_char1 : draw character in the upper case
drawobject_char1             proc    

        push eax
        push ebx

        mov eax, charframe1
        mov ebx, 4
        mul ebx
        invoke  DrawIconEx, hhDc,75,45, icoqueue1[eax], 120,120,0,NULL,DI_NOMIRROR or DI_NORMAL
        .if charframe1 > 1
            sub charframe1, 1
        .endif
        pop ebx
        pop eax
        ret
drawobject_char1 endp

; draw_music_display : draw the music display section
draw_music_display	proc 
	local	@lhsId:dword
	local	@rhsId:dword
	local	@curMusic:dword
	local	@mainIco:dword
	local	@leftIco:dword
	local	@rightIco:dword
	local	@rect:RECT
	local	@color:COLORREF
	local	@longFont:LOGFONT
	local	@hNewFont:dword
	local	@hOldFont:dword

	; get left cover path
	invoke get_ico_path_by_idx, 0
	; get right cover path
	invoke get_ico_path_by_idx, 1

	invoke  LoadImage, hInstance,offset szCoverPath,IMAGE_ICON,256,256, LR_LOADFROMFILE
	mov @mainIco, eax
	invoke  LoadImage, hInstance,offset szCoverPathL,IMAGE_ICON,256,256, LR_LOADFROMFILE
	mov @leftIco, eax
	invoke  LoadImage, hInstance,offset szCoverPathR,IMAGE_ICON,256,256, LR_LOADFROMFILE
	mov @rightIco, eax
	
	invoke  DrawIconEx, hhDc,192,20, @mainIco, 256,256,0,NULL,DI_NOMIRROR or DI_NORMAL
	invoke  DrawIconEx, hhDc,192,20, hVINYL, 256,256,0,NULL,DI_NOMIRROR or DI_NORMAL
	invoke  DrawIconEx, hhDc,20,200, @leftIco, 128,128,0,NULL,DI_NOMIRROR or DI_NORMAL
	invoke  DrawIconEx, hhDc,20,200, hVINYL, 128,128,0,NULL,DI_NOMIRROR or DI_NORMAL
	invoke  DrawIconEx, hhDc,492,200, @rightIco, 128,128,0,NULL,DI_NOMIRROR or DI_NORMAL
	invoke  DrawIconEx, hhDc,492,200, hVINYL, 128,128,0,NULL,DI_NOMIRROR or DI_NORMAL

	invoke	DestroyIcon, @mainIco
	invoke	DestroyIcon, @leftIco
	invoke	DestroyIcon, @rightIco

	; get filename without extension
	mov eax, frontMusicId
	mul dirNameLen
	add eax, offset musicList
	mov @curMusic, eax

	mov	@rect.left, 150
	mov	@rect.top, 280
	mov	@rect.right, 490
	mov	@rect.bottom, 330

	; set text color
	mov	eax, 604A3Bh
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
	invoke	DrawText, hhDc, @curMusic, -1, addr @rect, DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX
	;invoke	printf, offset sztimertest2, eax
	
	; delete used font
	invoke SelectObject, hhDc, @hOldFont
	invoke DeleteObject, @hNewFont
	ret
draw_music_display 	endp

; draw_intrf_start : draw start interface
draw_intrf_start	proc stdcall hWnd:dword
	local	@hDc:HDC
	local	@thDc:HDC
	local	@stPs:PAINTSTRUCT
	
	push eax
	invoke BeginPaint, hWnd, addr @stPs
	mov @hDc, eax
	invoke CreateCompatibleDC, NULL
	mov @thDc, eax
	invoke SelectObject, @thDc, bmpstartbkgnd
	mov bmpstartbkgndf, eax
	invoke BitBlt, hhDc, 0, 0, 640, 360, @thDc, 0, 0, SRCCOPY
	invoke BitBlt, @hDc, 0, 0, 640, 360, hhDc, 0, 0, SRCCOPY
	invoke SelectObject, @thDc, bmpstartbkgndf
	invoke DeleteDC, @thDc
	invoke EndPaint, hWnd, addr @stPs
	pop eax
	ret
draw_intrf_start	endp

; draw_intrf_music : draw music selection interface
draw_intrf_music	proc stdcall hWnd:dword
	local	@hDc:HDC
	local	@thDc:HDC
	local	@stPs:PAINTSTRUCT

	push eax
	invoke BeginPaint, hWnd, addr @stPs
	mov @hDc, eax
	invoke CreateCompatibleDC, NULL
	mov @thDc, eax
	; draw background to buffer hhDc
	invoke SelectObject, @thDc, bmpmusicbkgnd
	mov bmpmusicbkgndf, eax
	invoke BitBlt, hhDc, 0, 0, 640, 360, @thDc, 0, 0, SRCCOPY

	; draw music selection section
	invoke draw_music_display

	; draw to current window
	invoke BitBlt, @hDc, 0, 0, 640, 360, hhDc, 0, 0, SRCCOPY
	invoke SelectObject, @thDc, bmpmusicbkgndf
	invoke DeleteDC, @thDc
	invoke EndPaint, hWnd, addr @stPs
	pop eax
	ret
draw_intrf_music	endp

; draw_intrf_game : draw game interface
draw_intrf_game	proc stdcall hWnd:dword
	local	@hDc:HDC
	local	@thDc:HDC
	local   @stPs:PAINTSTRUCT
	local	@rect:RECT
	local	@color:COLORREF
	local	@longFont:LOGFONT
	local	@hNewFont:dword
	local	@hOldFont:dword
	;local	@len:dword
   ; .if isend == 1
	;    jmp draw_intrf_game_end
	;.endif

	;invoke  drawbackground, hWnd
	invoke  BeginPaint,hWnd,addr @stPs
	mov @hDc,eax
	invoke  CreateCompatibleDC,NULL
	mov @thDc,eax
	invoke  SelectObject,@thDc,bmpbackground
	mov bmpbackgroundf,eax
	;invoke  BitBlt,hhDc,0,50,640,250,@thDc,0,50,SRCCOPY
	invoke  BitBlt,hhDc,0,0,640,360,@thDc,0,0,SRCCOPY

	mov	@rect.left, 270
	mov	@rect.top, 0
	mov	@rect.right, 370
	mov	@rect.bottom, 60
	;invoke	strlen, offset szScoreText
	;mov		@len, eax

	; set text color
	;mov eax, 8E7367h
	mov	eax, 604A3Bh
	mov @color, eax
	invoke	SetTextColor, hhDc, @color

	; set text font
	invoke RtlZeroMemory, addr @longFont, sizeof LOGFONT
	mov @longFont.lfCharSet, GB2312_CHARSET
	mov @longFont.lfHeight, -15
	mov @longFont.lfQuality, PROOF_QUALITY
	mov @longFont.lfWeight, FW_MEDIUM
	;mov @longFont.lfItalic, TRUE
	invoke wsprintf, addr @longFont.lfFaceName, offset szGameScoreFont
	invoke CreateFontIndirect, addr @longFont
	mov @hNewFont, eax
	invoke SelectObject, hhDc, @hNewFont
	mov @hOldFont, eax

	invoke  wsprintf,offset szScoreText,offset szScoreFormat, score, Combo
	invoke	DrawText, hhDc, offset szScoreText, -1, addr @rect, DT_CENTER or DT_NOPREFIX

	; delete used font
	invoke SelectObject, hhDc, @hOldFont
	invoke DeleteObject, @hNewFont

	invoke  drawobject_char1
	invoke  drawobject_char2
	push edx
	push eax
	; draw object in the upper case
	mov edi, FirstItem1 
	mov eax, ItemQueue1[edi*4]
	
	push edi
	; draw mission accomplished

	mov edx, ItemSize1
	.if FirstItem1 >= edx
	    mov edx, ItemSize2
	    .if FirstItem2 >= edx
	        jmp iflabel1
		.endif
	.endif
	jmp iflabelend
	
iflabel1:   
        push ecx
        ;invoke printf,offset szQueue, FirstItem1
		pop ecx
        mov edx, ItemQueue1[edi*4]
	    add edx, 2000
		.if edx < frame
		    mov edi, FirstItem2
			mov edx, ItemQueue2[edi*4]
			add edx, 2000
			.if edx < frame
			    ;invoke  InvalidateRect,hWnd,NULL,FALSE
			
				inc isend
				jmp draw_intrf_game_end
			.endif
		.endif

iflabelend:
		
		pop edi
check_object_up: 
	    mov eax, ItemQueue1[edi*4]
		cmp eax, frame
		ja end_check_up

		;invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_up, ItemQueue1[edi*4]
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
		ja end_check_down
		;invoke  InvalidateRect,hWnd,NULL,FALSE
		invoke  drawobject_down, ItemQueue2[edi*4]

		inc edi
		mov eax, ItemQueue2[edi*4]
		push eax
		pop eax
		jmp check_object_down
		;.endw
end_check_down:
		
draw_intrf_game_end:
		;draw end icon
		.if musicStop == 1
			.if end_pos == -1
					mov end_pos,0
			.endif
			invoke drawendingmark
		.else
			; draw hit icon
			invoke  drawobject_hit
			;draw stop menu
			.if gamePause == 1
				invoke draw_stopmenu
			 .endif
		.endif
		;invoke  BitBlt,@hDc,0,50,640,250,hhDc,0,50,SRCCOPY
		invoke  BitBlt,@hDc,0,0,640,360,hhDc,0,0,SRCCOPY
		invoke  SelectObject,@thDc,bmpbackgroundf
        invoke  DeleteDC, @thDc
        invoke  EndPaint,hWnd,addr @stPs
		pop eax
		pop edx

   ret
draw_intrf_game	endp

switch_game_pause proc  
	.if gamePause == 0
		mov gamePause, 1
	.else 
		mov gamePause, 0
	.endif
	.if gamePause ==1
		invoke mciSendString,offset szPauseMusic, NULL, 0, NULL
	.else
		invoke mciSendString,offset szResumeMusic, NULL, 0, NULL
	.endif
	ret
switch_game_pause endp

; getscore1 : compute score in the upper case
getscore1	proc  
	push eax
	push ebx   
	push edx
	mov charframe1, 6
	mov ebx, FirstItem1
	mov edx, ItemQueue1[ebx*4]
	mov eax, frame
	sub  eax, edx
	mov ebx, eax
	mov eax, 470
	cmp eax, ebx
	jb Fu
	sub eax, ebx
	jmp end_fu
Fu: 
	sub ebx, eax
	mov eax, ebx
end_fu:
	.if eax <= 25
		mov ebx, score
		add ebx, 10
		mov score, ebx
		push eax
		mov eax, ItemSize1
		.if FirstItem1 < eax
			inc FirstItem1
		.endif
		pop eax
		inc Combo
		mov ComboState, 2
		;invoke	hit_music
		;处理Perfect
	.elseif eax <= 50
		mov ebx, score
		add ebx, 5
		mov score, ebx
		inc FirstItem1
		inc Combo
		mov ComboState, 1
		;invoke	hit_music
		;处理Great
	.else
		;mov Combo, 0
		mov ComboState, -1
		;invoke miss_music
	.endif
	;invoke  wsprintf, offset szCombo1, offset szCombo, Combo
	;invoke  SetDlgItemText,hWnd,111,offset szCombo1
	pop edx
	pop ebx
	pop eax
	ret
getscore1	endp

; getscore2 : compute score in the lower case
getscore2	proc  
	push eax
	push ebx   
	push edx
	mov charframe2, 5
	mov ebx, FirstItem2
	mov edx, ItemQueue2[ebx*4]
	mov eax, frame
	sub  eax, edx
	mov ebx, eax
	mov eax, 490
	cmp eax, ebx
	jb Fu2
	sub eax, ebx
	jmp end_fu2
Fu2: 
	sub ebx, eax
	mov eax, ebx
end_fu2:    
	.if eax <= 25
		mov ebx, score
		add ebx, 10
		mov score, ebx
		push eax
		mov eax, ItemSize2
		.if FirstItem2 < eax
			inc FirstItem2
		.endif
		pop eax
		inc Combo
		mov ComboState, 2
		;invoke	hit_music
		;处理Perfect
	.elseif eax <= 50
		mov ebx, score
		add ebx, 5
		mov score, ebx
		inc FirstItem2
		inc Combo
		mov ComboState, 1
		;invoke	hit_music
		;处理Great
	.else

		;mov Combo, 0
		mov ComboState, -1
		;invoke	miss_music
	.endif
	;invoke  wsprintf, offset szCombo1, offset szCombo, Combo
	;invoke  SetDlgItemText,hWnd,111,offset szCombo1
	pop edx
	pop ebx
	pop eax
	ret
getscore2	endp

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

goto_intrf_music	proc
	.if intrf == 2
		invoke end_music
	.endif
	mov intrf, 1
	invoke get_music_list
	invoke set_snatch
	; auto play current music snatch
	invoke start_snatch
	ret
goto_intrf_music	endp

switch_music_prev	proc
	invoke get_pre_id, frontMusicId
	mov frontMusicId, eax
	invoke printf, offset sztimertest2, frontMusicId
	invoke set_snatch
	ret
switch_music_prev	endp

switch_music_next	proc
	invoke get_nxt_id, frontMusicId
	mov frontMusicId, eax
	invoke printf, offset sztimertest2, frontMusicId
	invoke set_snatch
	ret
switch_music_next	endp

goto_intrf_game		proc
	mov intrf, 2
	mov gamePause, 0
	mov musicStop, 0
	mov end_pos, -1
	invoke initQueue
	; playing music
	invoke start_music
	ret
goto_intrf_game		endp

goto_intrf_start	proc
	mov intrf, 0
	ret
goto_intrf_start	endp

; replay_music_showcase : replay current snatch
replay_music_showcase	proc
	.if clipExist == 0
		invoke MessageBox, NULL, offset szClipNotFound, offset szFileMissMesg, MB_OK
	.else
		invoke end_snatch
		invoke start_snatch
	.endif
	ret
replay_music_showcase	endp

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
			.if ebx == VK_ESCAPE
				invoke MessageBox, hWnd, offset szQuitMesg, offset szQuitTitle, MB_OKCANCEL
				.if eax == IDOK
					invoke SendMessage, hWnd, WM_CLOSE, NULL, NULL
				.endif
			; go to music intrf: press any key except Esc
			.else
				invoke goto_intrf_music
			.endif
		; music selection intrf
		.elseif intrf == 1
			; previous song: Q/A/LeftArrow
			.if (ebx == 'A') || (ebx == VK_LEFT)
				; end old snatch
				invoke end_snatch
				; change music
				invoke switch_music_prev
				; start new snatch
				invoke start_snatch
			; next song: E/D/RightArrow
			.elseif (ebx == 'D') || (ebx == VK_RIGHT)
				; end old snatch
				invoke end_snatch
				; change music
				invoke switch_music_next
				; start new snatch
				invoke start_snatch
			; go to game intrf: Enter
			.elseif ebx == VK_RETURN
				.if musicExist == 0
					invoke MessageBox, NULL, offset szMusicNotFound, offset szFileMissMesg, MB_OK
				.elseif noteExist == 0
					invoke MessageBox, NULL, offset szNote1NotFound, offset szFileMissMesg, MB_OK
				.elseif noteExist == -1
					invoke MessageBox, NULL, offset szNote2NotFound, offset szFileMissMesg, MB_OK
				.else
					invoke end_snatch
					invoke goto_intrf_game
				.endif
			; return to start intrf: Esc
			.elseif ebx == VK_ESCAPE
				invoke end_snatch
				invoke goto_intrf_start
			; music showcase replay: Space
			.elseif ebx == VK_SPACE
				invoke replay_music_showcase
			.endif
		; gaming intrf
		.elseif intrf == 2
			; up track hit: F/D/S
			.if (ebx == 'F') || (ebx == 'D') || (ebx == 'S')
				.if enableUpperKey == 1
					invoke getscore1
					mov	hit_frame,3
					invoke hit_music
					mov enableUpperKey, 0
				.endif
			; down track hit: J/K/L
			.elseif (ebx == 'J') || (ebx == 'K') || (ebx == 'L')
				.if enableLowerKey == 1
					invoke getscore2
					mov	hit_frame,3
					invoke hit_music
					mov enableLowerKey, 0
				.endif
				
			.elseif ebx == VK_RETURN
				.if gamePause == 1
					invoke goto_intrf_music
				.endif
			.elseif ebx == VK_ESCAPE
				invoke switch_game_pause
			.endif
		.endif
	.elseif eax == WM_KEYUP
		mov ebx ,wParam
		.if intrf == 2
			.if (ebx == 'F') || (ebx == 'D') || (ebx == 'S')
				.if enableUpperKey == 0
					mov enableUpperKey, 1
				.endif
			.elseif (ebx == 'J') || (ebx == 'K') || (ebx == 'L')
				.if enableLowerKey == 0
					mov enableLowerKey, 1
				.endif
			.endif
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