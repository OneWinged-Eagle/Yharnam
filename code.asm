; *************************************************************************
; 32-bit Windows Hello World Application - MASM32 Example
; EXE File size: 2,560 Bytes
; Created by Visual MASM (http://www.visualmasm.com)
; *************************************************************************
     
.386					; Enable 80386+ instruction set
.model flat, stdcall	; Flat, 32-bit memory model (not used in 64-bit)
option casemap: none	; Case sensitive syntax

; *************************************************************************
; MASM32 proto types for Win32 functions and structures
; *************************************************************************  
;include c:\masm32\include\windows.inc
;include c:\masm32\include\user32.inc
;include c:\masm32\include\kernel32.inc

;extrn ExitProcess: PROC

; *************************************************************************
; MASM32 object libraries
; *************************************************************************  
;includelib c:\masm32\lib\user32.lib
;includelib c:\masm32\lib\kernel32.lib

; *************************************************************************
; Our data section. Here we declare our strings for our message box
; *************************************************************************
.data

; *************************************************************************
; Our executable assembly code starts here in the .code section
; *************************************************************************
.code

start:
	xor eax, eax
ASSUME FS:NOTHING
	mov eax, fs:[eax + 030H]
ASSUME FS:ERROR
	; ebp + 0 => base kernel
	; ebp + 4 => Export dir VA
	; ebp + 8 => Nb of functions
	; ebp + c => Nb of Names
	; ebp + 10 => Size "GetProcessAddress"
	; ebp + 14 => Addr string "GetProcessAddress"
	; ebp + 18 => Addr GetProcAddress
	; ebp + 1c => Addr LoadLibraryA
	; ebp + 20 => Addr MessageBoxA
	; ebp + 24 => addr title
	; ebp + 28 => msg
	
	push esp
	mov ebp, esp
	sub esp, 30h
	mov eax, [eax + 0Ch]			
	mov eax, [eax + 14h]			
	mov eax, [eax]				
	mov eax, [eax]				
	mov eax, [eax + 10h]			
	mov [ebp+0], eax				
	mov ebx, eax

	add ebx, [ebx+ 3ch]			
	mov ebx, [ebx+ 78h]
	add ebx, [ebp+0]
	mov [ebp+4], ebx
	
	; GetProcAddress
	;47657450 726f6341 64647265 73730000
	push 00007373h
	push 65726464h
	push 41636f72h
	push 50746547h
	mov [ebp+14h], esp

	; Taille de la string (14)
	mov edi, 14
	mov [ebp+10h], edi
	

	; Get
	mov edi, [esi + 14h]
	mov [ebp+08h], edi
	
	mov edi, [esi + 18h]
	mov [ebp+0ch], edi
	
	; Get AddressOfNames
	mov esi, [esi + 20h]
	; Add base kernel addr
	add esi, [ebp+0]
 	
 	xor ecx, ecx
	.WHILE ecx < [ebp + 0ch]
		mov esi, [ebp+4] ; Export dir addr
		; Get AddressOfNames
		mov esi, [esi + 20h]
		; Add base kernel addr
		add esi, [ebp+0]
		
		; Set edi on string to cmp
		mov edi, ecx
		shl edi, 2
		add esi, edi
		mov edi, [esi]
		add edi, [ebp+0]

		; Compare de la string
		push esi
		mov esi, [ebp + 14h]
		push ecx
		mov ecx, [ebp+10h]
		cld
		repe cmpsb
		pop ecx
  		jne WHILEEND
  		
		mov esi, [ebp+4] ; Export dir addr
		mov esi, [esi+24h]
		add esi, [ebp+0]
		movzx edi, WORD PTR [ecx * 2 + esi]
		mov esi, [ebp+4] ; Export dir addr
		mov esi, [esi+1ch]
		add esi, [ebp+0]
		mov edi, [edi * 4 + esi] ; RVA addr of GetProcessAddress
		add edi, [ebp+0]
		mov eax, edi
		mov [ebp+18h], edi
		jmp PROCADDROK
WHILEEND:		
		inc ecx
	.ENDW
	
PROCADDROK:
	; 4c6f6164 4c696272 61727941		
 	push 00000000h
 	push 41797261h
 	push 7262694ch
 	push 64616f4ch
 	push esp
 	push dword ptr [ebp+0]
 	call eax ; call GetProcAddress with LoadLibraryA
 	mov [ebp+1ch], eax
 	push 00006c6ch
 	push 642e3233h
 	push 72657355h
 	push esp
 	;push dword ptr [ebp+0]
 	call eax ; call LoadLibraryA with User32.dll
 	;4d657373 61676542 6f784100
 	push 0041786fh
 	push 42656761h
 	push 7373654dh
 	push esp
 	push eax
 	mov ebx, [ebp+18h]
 	call ebx
 	mov [ebp+20h], eax
 	
 	push 0041786fh
 	push 42656761h
 	push 7373654dh
 	mov [ebp+24], esp
 	mov [ebp+28], esp

 	; Call de MessageBoxA
 	push 00000000h
    mov edx, [ebp+24]
    push edx
    mov edx, [ebp+28]
    push edx
    push 00000000h
    call eax
	
	; When the message box has been closed, exit the app with exit code 0
	;push 0h
	;call ExitProcess

    ;invoke ExitProcess, 0
end start
