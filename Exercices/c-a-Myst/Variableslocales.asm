.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
; variables initialisees
Ks     db    "K = %d",10,0
Is		 db    "I = %d",10,0
Ns		 db    "N = %d",10,0
Jss		 db		 "J = %d",10,0
Ls		 db		 "L = %d",10,0

.CODE
Myst PROC
	push ebp
	mov ebp, esp
	sub esp, 16
	mov dword PTR [ebp-16], 1
	mov dword PTR [ebp-12], 1
	mov dword PTR [ebp-8], 3
	loop_start:
		mov esi, [ebp-8]
		cmp esi, [ebp+8]
		jg end_loop
		mov esi, [ebp-16]
		add esi, [ebp-12]
		mov dword PTR [ebp-4], esi
		mov esi, [ebp-12]
		mov dword PTR [ebp-16], esi
		mov esi, [ebp-4]
		mov dword PTR [ebp-12], esi
		mov esi, [ebp-8]
		inc esi
		mov dword PTR [ebp-8], esi
		jmp loop_start
	end_loop:
		mov eax, [ebp-12]
		mov esp, ebp
		pop ebp
		ret
Myst ENDP
start:
	push 15
	call Myst
	push eax
	push offset Ks
	call crt_printf
	mov eax, 0
	  	invoke	ExitProcess,eax
end start
