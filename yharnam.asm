    
.386					; Enable 80386+ instruction set
.model flat, stdcall	; Flat, 32-bit memory model (not used in 64-bit)
option casemap: none	; Case sensitive syntax

; *************************************************************************
; MASM32 proto types for Win32 functions and structures
; *************************************************************************  
include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\masm32rt.inc

; *************************************************************************
; MASM32 object libraries
; *************************************************************************  
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.data
	strTitle		db "Bare Bone",0
 	strMessage	db "Hello World!",0
 	
	pathTargetL		db		"Path target",0

;
; Struct url
;


; *************************************************************************
; Our executable assembly code starts here in the .code section
; *************************************************************************
.code

CheckExe proc Path:PTR BYTE
	local FileInfo:SHFILEINFO
	
	; SI SHGFI_EXETYPE => eax type d'exe 
	invoke SHGetFileInfo, Path, FILE_ATTRIBUTE_NORMAL, ADDR FileInfo, SIZEOF FileInfo, SHGFI_EXETYPE
	; Si eax = 0. Le fichier n'est pas un exe
	; Sinon dans eax, le type d'exe
 	;invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK
	ret
CheckExe endp

; ---------------------------------------------------------
;
; ---------------------------------------------------------
WinMain proc
	; Destination pour le path
	local buff[128]:byte

	; WIN API
	invoke GetCurrentDirectory, 128, ADDR buff
	
	; Rajoute "\*" au path
	invoke StrLen, ADDR buff
	lea edi, buff
	add edi, eax
	mov DWORD PTR [edi], 00002A5Ch

	; Affiche le buffer et la taille avant rajout de "\*"
	invoke MessageBox, 0, ADDR buff, ADDR pathTargetL, MB_OK	
	;invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK
	
	ret
WinMain endp

start:
	invoke WinMain
    ;invoke ExitProcess, 0
end start
