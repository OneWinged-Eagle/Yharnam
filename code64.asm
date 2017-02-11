
extrn ExitProcess: PROC

.data

.code

main proc
	local kernelBase:QWORD
	local exportDir:QWORD
	local nbFunctions:QWORD
	local nbNames:QWORD
	local getProcAddr:QWORD
	local loadLibAddr:QWORD

	local getProcS[16]:BYTE
	local loadLibS[16]:BYTE
	local user32S[16]:BYTE
	local msgBoxS[16]:BYTE

	local yhaS[16]:BYTE
	local msgYhaS[16]:BYTE

	;--------------------------------------------------
	; 
	; 	- Get Kernel Base
	;
	;--------------------------------------------------

	xor rax, rax
	; Get PEB
	mov rax, gs:[eax+60h]
	; PEB_LDR_DATA
	mov rax, [rax+18h]
	; InMemoryOrderModuleList, first entry
	mov rax, [rax+20h]
	; Second entry
	mov rax, [rax]
	; Third entry (Kernel32)
	mov rax, [rax]
	; Get base addr
	mov rax, [rax+20h]

	mov kernelBase, rax
	mov rbx, rax

	;--------------------------------------------------
	; 
	; 	- Get Export Dir
	;
	;--------------------------------------------------

	; New exe addr (DOS HEADER)
	add bx, WORD PTR [rbx+3ch]
	; Export Dir RVA addr
	mov ebx, DWORD PTR [rbx+88h]
	; Add KernelBase
	add rbx, kernelBase
	mov exportDir, rbx

	;--------------------------------------------------
	; 
	; 	- Nb functions
	;	- Nb Names
	;
	;--------------------------------------------------

	; Nb functions
	xor rdi, rdi
	mov edi, DWORD PTR [rbx+14h]
	mov nbFunctions, rdi

	; Nb Names
	xor rdi, rdi
	mov edi, DWORD PTR [rbx+18h]
	mov nbNames, rdi

	;--------------------------------------------------
	; 
	; 	- Find GetProcAddress
	;
	;--------------------------------------------------
	
	; String "GetProcAddress"
	lea rdi, getProcS
	mov DWORD PTR [rdi], 50746547h
	mov DWORD PTR [rdi+04h], 41636f72h
	mov DWORD PTR [rdi+08h], 65726464h
	mov DWORD PTR [rdi+0ch], 00007373h
	
	xor rcx, rcx
LOOPB:
	; Get AddressOfNames addr
	mov rsi, exportDir
	mov esi, DWORD PTR [rsi+20h]		; AddressOfNames
	add rsi, kernelBase

	; Get addr of name to cmp
	mov rdi, rcx
	shl rdi, 2
	add rsi, rdi
	mov edi, DWORD PTR [rsi]
	add rdi, kernelBase

	; Cmp name with "GetProcAddress"
	lea rsi, getProcS
	push rcx
	mov rcx, 14
	cld
	repe cmpsb
	pop rcx

	; If not equal go to next name
	jne LOOPNEXT

	; If equal, Get addr of functions with AddressOfNameOrdinales
	mov rsi, exportDir
	mov esi, [rsi+24h]
	add rsi, kernelBase
	xor rdi, rdi
	mov di, WORD PTR [rcx * 2 + rsi]	; Ordinal in rdi
	
	mov rsi, exportDir
	mov esi, [rsi+1ch]					; AddressOfFunctions
	add rsi, kernelBase

	mov edi, DWORD PTR [rdi * 4 + rsi]
	add rdi, kernelBase
	mov getProcAddr, rdi
	jmp ADDRPROCOK

LOOPNEXT:
	; next name
	inc rcx
	cmp rcx, nbFunctions
	jne LOOPB

ADDRPROCOK:

	;--------------------------------------------------
	; 
	; 	- Find "LoadLibraryA" with GetProcAddress
	;
	;--------------------------------------------------

	lea rdi, loadLibS
	mov [rdi], DWORD PTR 64616f4ch
	mov [rdi+4h], DWORD PTR 7262694ch
	mov [rdi+8h], DWORD PTR 41797261h
	mov [rdi+0ch], DWORD PTR 00000000h

	sub rsp,28h
	mov rcx, kernelBase
	lea rdx, loadLibS
	mov rdi, getProcAddr
	call rdi
	;call GetProcAddress
	add	rsp, 28h
	mov loadLibAddr, rax
	
	;--------------------------------------------------
	; 
	; 	- Load user32.dll with LoadLibraryA
	;
	;--------------------------------------------------

	lea rdi, user32S
	mov [rdi], DWORD PTR 72657355h
	mov [rdi+4h], DWORD PTR 642e3233h
	mov [rdi+8h], DWORD PTR 00006c6ch

	;sub rsp,28h
	lea rcx, user32S
	call rax
	;add rsp,28h

	;--------------------------------------------------
	; 
	; 	- Find "MessageBoxA" with GetProcAddress
	;
	;--------------------------------------------------

	lea rdi, msgBoxS
	mov [rdi], DWORD PTR 7373654dh
	mov [rdi+4h], DWORD PTR 42656761h
	mov [rdi+8h], DWORD PTR 0041786fh

	;sub rsp,28h
	mov rcx, rax
	lea rdx, msgBoxS
	mov rax, getProcAddr
	call rax
	;add rsp,28h

	;--------------------------------------------------
	; 
	; 	- Call MessageBoxA
	;
	;--------------------------------------------------

	; Build title "Yharnam"
	lea rdi, yhaS
	mov [rdi], DWORD PTR 72616859h
	mov [rdi+4h], DWORD PTR 006d616eh

	; Build msg "Infected !"
	; 496e6665 63746564 20210000
	lea rdi, msgYhaS
	mov [rdi], DWORD PTR 65666e49h
	mov [rdi+4h], DWORD PTR 64657463h
	mov [rdi+8h], DWORD PTR 00002120h

	;sub rsp,28h
	mov rcx, 0
	lea rdx, msgYhaS
	lea r8, yhaS
	mov r9d, 0
	call rax
	add rsp,28h

	mov ecx, 0
	call ExitProcess
	
main endp

END
