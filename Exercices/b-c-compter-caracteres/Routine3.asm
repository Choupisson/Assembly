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
Phrase     db    "Hello World",10,0
CounterPhrase         db            "The previous phrase contains %d characters",10,0

.DATA?
; variables non-initialisees (bss)

.CODE
Count PROC
    mov esi, [esp+4] 
    mov edi, esi
    loop_start:
        mov al, [esi]    
        test al, al      
        jz loop_end      
        inc esi          
        jmp loop_start   ;
    loop_end:
        sub esi, edi
        dec esi
        ret
Count ENDP
start:

    push offset Phrase
    call crt_printf
    push offset Phrase
    call Count
    push esi
    push offset CounterPhrase
    call crt_printf
    mov eax, 0
    invoke    ExitProcess,eax
end start